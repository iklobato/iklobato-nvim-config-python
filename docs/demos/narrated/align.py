"""Put each narration line at the moment its step shows in the silent video.

narrate.py records one take for the whole chapter. whisper.cpp gives the time of every
spoken word; the words are matched to the script to find where each line is spoken, and
each cut is moved into the nearest real pause. Line i is then delayed so it starts LEAD
seconds before step i shows on screen. Writes <out>.srt and <out> (mp4, voice + video).

Usage: python3 -I align.py <chapter.json> <voice.wav> <silent.mp4> <out.mp4>
chapter.json: {"sentences": [one line per step], "onsets": [second each step shows]}
"""

import difflib
import json
import logging
import os
import re
import shlex
import sys
import tempfile
from dataclasses import dataclass

LEAD = 0.3  # the voice starts just before the key box, so the name lands with the keys
MIN_GAP = 0.25  # never let two lines touch
EDGE = 0.08  # breath kept around the first and last word
SNAP = 0.4  # how far from the word-time gap a real pause may sit
LATE_REPORT = 0.05
TAIL_HOLD = 1.0  # last frame held after the last line
MS_PER_SECOND = 1000
SECONDS_PER_MINUTE = 60
MINUTES_PER_HOUR = 60
HALVES = 2
ERROR_TAIL_CHARS = 800
REPORT_TEXT_CHARS = 48
WHISPER_RATE = "16000"
WHISPER_MODEL = os.path.expanduser("~/.cache/whisper-cpp/ggml-base.en.bin")
SILENCE_FILTER = "silencedetect=noise=-35dB:d=0.1"
ENCODE = (
    "-c:v",
    "libx264",
    "-pix_fmt",
    "yuv420p",
    "-crf",
    "20",
    "-c:a",
    "aac",
    "-b:a",
    "160k",
)


class ShellError(RuntimeError):
    pass


class AlignError(ValueError):
    pass


@dataclass(frozen=True)
class Span:
    start: float
    end: float

    def length(self) -> float:
        return self.end - self.start

    def middle(self) -> float:
        return (self.start + self.end) / HALVES


@dataclass(frozen=True)
class HeardWord:
    word: str
    span: Span


@dataclass(frozen=True)
class AlignJob:
    chapter: dict
    wav: str
    video: str
    out: str


@dataclass(frozen=True)
class Plan:
    lines: list
    spans: list
    placed: list
    onsets: list


@dataclass(frozen=True)
class MuxJob:
    wav: str
    video: str
    graph: str
    out: str


class Shell:
    def __init__(self, work: str) -> None:
        self._work = work

    def execute(self, args: list, log_name: str) -> str:
        log = self.path(log_name)
        command = shlex.join(args) + " > " + shlex.quote(log) + " 2>&1"
        status = os.system(command)
        with open(log) as handle:
            output = handle.read()
        if status != 0:
            raise ShellError("failed: %s\n%s" % (command, output[-ERROR_TAIL_CHARS:]))
        return output

    def path(self, name: str) -> str:
        return os.path.join(self._work, name)


class WordSplitter:
    def words(self, text: str) -> list:
        return re.sub(r"[^a-z0-9 ]", " ", text.lower()).split()


class WordTimes:
    """Every spoken word with its time, from whisper.cpp."""

    def __init__(self, shell: Shell, splitter: WordSplitter) -> None:
        self._shell = shell
        self._splitter = splitter

    def heard(self, wav: str) -> list:
        wav16, prefix = self._shell.path("voice16.wav"), self._shell.path("words")
        self._shell.execute(
            ["ffmpeg", "-y", "-i", wav, "-ar", WHISPER_RATE, "-ac", "1", wav16],
            "wav16.log",
        )
        whisper = [
            "whisper-cli",
            "-m",
            WHISPER_MODEL,
            "-f",
            wav16,
            "-ml",
            "1",
            "-sow",
            "-oj",
            "-of",
            prefix,
            "-np",
        ]
        self._shell.execute(whisper, "whisper.log")
        with open(prefix + ".json") as handle:
            segments = json.load(handle)["transcription"]
        return [
            HeardWord(
                word,
                Span(
                    seg["offsets"]["from"] / MS_PER_SECOND,
                    seg["offsets"]["to"] / MS_PER_SECOND,
                ),
            )
            for seg in segments
            for word in self._splitter.words(seg["text"])
        ]


class PauseFinder:
    def __init__(self, shell: Shell) -> None:
        self._shell = shell

    def pauses(self, wav: str) -> list:
        out = self._shell.execute(
            ["ffmpeg", "-i", wav, "-af", SILENCE_FILTER, "-f", "null", "-"],
            "silence.log",
        )
        starts = [float(value) for value in re.findall(r"silence_start: ([\d.]+)", out)]
        ends = [float(value) for value in re.findall(r"silence_end: ([\d.]+)", out)]
        return [Span(start, end) for start, end in zip(starts, ends)]


class LineMatcher:
    """Span of the matched words of each script line, from first word start to last word end."""

    def __init__(self, splitter: WordSplitter) -> None:
        self._splitter = splitter

    def spans(self, lines: list, heard: list) -> list:
        script = [
            (word, step)
            for step, line in enumerate(lines)
            for word in self._splitter.words(line)
        ]
        script_words, heard_words = (
            [word for word, _ in script],
            [item.word for item in heard],
        )
        matcher = difflib.SequenceMatcher(
            None, script_words, heard_words, autojunk=False
        )
        first, last = {}, {}
        for block in matcher.get_matching_blocks():
            for offset in range(block.size):
                step, span = script[block.a + offset][1], heard[block.b + offset].span
                first.setdefault(step, span.start)
                last[step] = span.end
        missing = [step for step in range(len(lines)) if step not in first]
        if missing:
            raise AlignError("no spoken words matched for lines %s" % missing)
        return [Span(first[step], last[step]) for step in range(len(lines))]


class CutChooser:
    """whisper.cpp word times are off by a few hundred ms: a cut half way through the gap
    clipped "breakpoints" into "points" on the next line, so cut in the longest real pause."""

    def cut(self, gap: Span, pauses: list) -> float:
        near = [
            pause
            for pause in pauses
            if pause.end > gap.start - SNAP and pause.start < gap.end + SNAP
        ]
        if not near:
            return gap.middle()
        return max(near, key=Span.length).middle()


class LineSplitter:
    def __init__(
        self, word_times: WordTimes, pause_finder: PauseFinder, matcher: LineMatcher
    ) -> None:
        self._word_times = word_times
        self._pause_finder = pause_finder
        self._matcher = matcher

    def spans(self, wav: str, lines: list, chooser: CutChooser) -> list:
        spoken = self._matcher.spans(lines, self._word_times.heard(wav))
        pauses = self._pause_finder.pauses(wav)
        gaps = [
            Span(spoken[step].end, spoken[step + 1].start)
            for step in range(len(lines) - 1)
        ]
        bounds = [max(0.0, spoken[0].start - EDGE)] + [
            chooser.cut(gap, pauses) for gap in gaps
        ]
        bounds.append(spoken[-1].end + EDGE)
        return [Span(bounds[step], bounds[step + 1]) for step in range(len(lines))]


class Placer:
    def plan(self, spans: list, onsets: list) -> list:
        placed, free_at = [], 0.0
        for span, onset in zip(spans, onsets):
            start = max(onset - LEAD, free_at, 0.0)
            placed.append(Span(start, start + span.length()))
            free_at = placed[-1].end + MIN_GAP
        return placed


class SrtWriter:
    def stamp(self, seconds: float) -> str:
        ms = int(round(seconds * MS_PER_SECOND))
        whole_seconds = ms // MS_PER_SECOND
        minutes = whole_seconds // SECONDS_PER_MINUTE
        hours = minutes // MINUTES_PER_HOUR
        clock = (
            hours,
            minutes % MINUTES_PER_HOUR,
            whole_seconds % SECONDS_PER_MINUTE,
            ms % MS_PER_SECOND,
        )
        return "%02d:%02d:%02d,%03d" % clock

    def write(self, path: str, plan: Plan) -> None:
        blocks = [
            "%d\n%s --> %s\n%s\n"
            % (number, self.stamp(span.start), self.stamp(span.end), line)
            for number, (line, span) in enumerate(zip(plan.lines, plan.placed), start=1)
        ]
        with open(path, "w") as out:
            out.write("\n".join(blocks))


class FilterGraph:
    """Cut each line out of the take, delay it to its slot, mix, pad voice and video to one length."""

    def build(self, plan: Plan, total: Span) -> str:
        parts = [
            "[0:a]atrim=%.3f:%.3f,asetpts=PTS-STARTPTS,adelay=%d:all=1[a%d]"
            % (span.start, span.end, int(slot.start * MS_PER_SECOND), step)
            for step, (span, slot) in enumerate(zip(plan.spans, plan.placed))
        ]
        inputs = "".join("[a%d]" % step for step in range(len(plan.spans)))
        mix = inputs + "amix=inputs=%d:normalize=0,apad=whole_dur=%.2f[voice]" % (
            len(plan.spans),
            total.end,
        )
        video = "[1:v]tpad=stop_mode=clone:stop_duration=%.2f[v]" % total.length()
        return ";".join(parts + [mix, video])


class Muxer:
    def __init__(self, shell: Shell) -> None:
        self._shell = shell

    def duration(self, path: str) -> float:
        probe = [
            "ffprobe",
            "-v",
            "error",
            "-show_entries",
            "format=duration",
            "-of",
            "csv=p=0",
            path,
        ]
        return float(self._shell.execute(probe, "probe.log").strip())

    def mux(self, job: MuxJob) -> None:
        inputs = ["ffmpeg", "-y", "-i", job.wav, "-i", job.video]
        maps = ["-filter_complex", job.graph, "-map", "[v]", "-map", "[voice]"]
        # no -shortest: with a filter graph it cut the last line; apad/tpad set the length
        self._shell.execute(
            inputs + maps + list(ENCODE) + ["-movflags", "+faststart", job.out],
            "mux.log",
        )


class Report:
    def __init__(self, log: logging.Logger) -> None:
        self._log = log

    def show(self, plan: Plan) -> None:
        for line, span, slot, onset in zip(
            plan.lines, plan.spans, plan.placed, plan.onsets
        ):
            late = slot.start - (onset - LEAD)
            note = ", %.2f s late" % late if late > LATE_REPORT else ""
            text = line[:REPORT_TEXT_CHARS]
            self._log.info(
                "%5.2f-%5.2f -> %5.2f (step %5.2f%s)  %s",
                span.start,
                span.end,
                slot.start,
                onset,
                note,
                text,
            )


class Aligner:
    def __init__(self, splitter: LineSplitter, placer: Placer, muxer: Muxer) -> None:
        self._splitter = splitter
        self._placer = placer
        self._muxer = muxer

    def align(self, job: AlignJob, srt: SrtWriter, report: Report) -> None:
        lines, onsets = job.chapter["sentences"], job.chapter["onsets"]
        if len(lines) != len(onsets):
            raise AlignError("%d lines but %d onsets" % (len(lines), len(onsets)))
        spans = self._splitter.spans(job.wav, lines, CutChooser())
        plan = Plan(lines, spans, self._placer.plan(spans, onsets), onsets)
        report.show(plan)
        srt.write(os.path.splitext(job.out)[0] + ".srt", plan)
        video_len = self._muxer.duration(job.video)
        total = Span(video_len, max(video_len, plan.placed[-1].end + TAIL_HOLD))
        self._muxer.mux(
            MuxJob(job.wav, job.video, FilterGraph().build(plan, total), job.out)
        )


class CompositionRoot:
    def launch(self, args: list) -> None:
        chapter_path, wav, video, out = args
        logging.basicConfig(level=logging.INFO, format="%(message)s")
        shell, splitter = Shell(tempfile.mkdtemp(prefix="align-")), WordSplitter()
        line_splitter = LineSplitter(
            WordTimes(shell, splitter), PauseFinder(shell), LineMatcher(splitter)
        )
        with open(chapter_path) as handle:
            job = AlignJob(json.load(handle), wav, video, out)
        Aligner(line_splitter, Placer(), Muxer(shell)).align(
            job, SrtWriter(), Report(logging.getLogger("align"))
        )


if __name__ == "__main__":
    CompositionRoot().launch(sys.argv[1:])
