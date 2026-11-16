"""Turn an aligned chapter (voice + video from align.py) into the final video.

Adds a title card, zooms on the part of the screen each step talks about, pastes
the key box back on top of the zoom (it sits in the corner and a zoom would cut it
out), adds an end card with the install command, and mixes low background music
that ducks under the voice.

Usage: python3 -I polish.py <chapter.json> <aligned.mp4> <music.mp3> <out.mp4>
chapter.json adds to the fields align.py reads:
  "cards": {"label", "title", "problem", "before", "after"}
  "focus": one entry per step: null (whole screen) or [center_x, center_y, zoom]
"""

import json
import logging
import os
import shlex
import sys
import tempfile
import textwrap
from dataclasses import dataclass
from xml.sax.saxutils import escape

FRAME_W = 1400
FRAME_H = 820
FPS = 25
HALF = 2
UPSCALE = (
    2  # zoompan lands on whole pixels: working at 2x keeps a slow zoom from shaking
)
ZOOM_MOVE = 0.8  # seconds a zoom takes to reach its new framing
TITLE_SECONDS = 3.5
END_SECONDS = 6.5
FADE = 0.4
MS_PER_SECOND = 1000
# the key box of docs/demos/keycast.lua (46x5 cells) on a 1400x820 frame, measured
BOX_X, BOX_Y, BOX_W, BOX_H = 801, 542, 541, 166
# a pixel row inside the box, above its border: all box background while it shows
PROBE_X, PROBE_Y, PROBE_W = 815, 548, 515
BOX_BG = (23, 23, 26)
# ffmpeg 9 refuses a 1-row crop of yuv420 video ("Invalid too big or non positive size")
PROBE_ROWS = 2
COLOR_SLACK = 6
RGB = 3
BOX_ROW_SHARE = 0.9
PROBE_CROP = "fps=%d,crop=w=%d:h=%d:x=%d:y=%d"
RAW_RGB = ("-f", "rawvideo", "-pix_fmt", "rgb24")
BOX_PAINT_OUT = "drawbox=x=%d:y=%d:w=%d:h=%d:color=%s:t=fill:enable='%s'"
EDITOR_BG = "0x0B0B0C"  # Terminal Noir background in docs/demos/settings.tape
# the Lyria track averages about -20 dB and the voice -21 dB: 0.4 (-8 dB) puts the
# music near -28 dB on the cards, and the sidechain pulls it further under the voice
MUSIC_GAIN = 0.4
MUSIC_FADE_IN = 1.5
MUSIC_FADE_OUT = 2.5
DUCK = "threshold=0.03:ratio=6:attack=15:release=350"
AUDIO_FORMAT = "aformat=sample_rates=48000:channel_layouts=stereo"
ERROR_TAIL_CHARS = 800
INSTALL = (
    "curl -fsSL https://raw.githubusercontent.com/iklobato/"
    "iklobato-nvim-config-python/main/scripts/install.sh | bash"
)
REPO = "github.com/iklobato/iklobato-nvim-config-python"
FONT = "JetBrainsMonoNL Nerd Font"

# Card layouts. Coordinates live in the markup: they are the design, not logic.
FRAME_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="1400" height="820">
<rect width="100%" height="100%" fill="#2A2A2E"/>
<rect x="24" y="24" width="1352" height="772" rx="10" fill="#0B0B0C"/>
<circle cx="39" cy="39" r="5" fill="#FF5F57"/>
<circle cx="54" cy="39" r="5" fill="#FEBC2E"/>
<circle cx="69" cy="39" r="5" fill="#28C840"/>
{body}
</svg>"""
TITLE_BODY = """<rect x="120" y="262" width="8" height="250" fill="#F5A623"/>
<text x="156" y="300" font-family="{font}" font-size="24" letter-spacing="3" fill="#F5A623">{label}</text>
<text x="156" y="380" font-family="{font}" font-size="60" font-weight="bold" fill="#F4F4F5">{title}</text>
<text x="156" y="412" font-family="{font}" font-size="30" fill="#A1A1AA">{problem}</text>"""
TITLE_LINE = '<tspan x="156" dy="1.45em">{}</tspan>'
END_BODY = """<text x="120" y="160" font-family="{font}" font-size="22" letter-spacing="3" fill="#A1A1AA">BEFORE  /  VS CODE</text>
<text x="120" y="172" font-family="{font}" font-size="28" fill="#A1A1AA">{before}</text>
<text x="120" y="340" font-family="{font}" font-size="22" letter-spacing="3" fill="#F5A623">HERE</text>
<text x="120" y="352" font-family="{font}" font-size="28" fill="#F4F4F5">{after}</text>
<text x="120" y="545" font-family="{font}" font-size="22" letter-spacing="3" fill="#F5A623">INSTALL</text>
<rect x="100" y="565" width="1200" height="64" rx="8" fill="#17171A" stroke="#F5A623"/>
<text x="124" y="605" font-family="{font}" font-size="17" fill="#F4F4F5">{install}</text>
<text x="120" y="700" font-family="{font}" font-size="24" fill="#A1A1AA">{repo}</text>"""
END_LINE = '<tspan x="120" dy="1.4em">{}</tspan>'
WRAP_TITLE_TEXT = 62
WRAP_END_TEXT = 70
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
    "-movflags",
    "+faststart",
)


class ShellError(RuntimeError):
    pass


@dataclass(frozen=True)
class Span:
    start: float
    end: float


@dataclass(frozen=True)
class Framing:
    center_x: float
    center_y: float
    zoom: float


@dataclass(frozen=True)
class PolishJob:
    chapter: dict
    aligned: str
    music: str
    out: str


@dataclass(frozen=True)
class Timeline:
    main: float

    def total(self) -> float:
        return TITLE_SECONDS + self.main + END_SECONDS


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


class SvgCard:
    """Cards drawn like the VHS window: same frame color, same font, orange accent."""

    def title(self, cards: dict) -> str:
        body = TITLE_BODY.format(
            font=FONT,
            label=escape(cards["label"].upper()),
            title=escape(cards["title"]),
            problem=self._lines(cards["problem"], TITLE_LINE, WRAP_TITLE_TEXT),
        )
        return FRAME_SVG.format(body=body)

    def end(self, cards: dict) -> str:
        body = END_BODY.format(
            font=FONT,
            before=self._lines(cards["before"], END_LINE, WRAP_END_TEXT),
            after=self._lines(cards["after"], END_LINE, WRAP_END_TEXT),
            install=escape("$ " + INSTALL),
            repo=escape(REPO),
        )
        return FRAME_SVG.format(body=body)

    def _lines(self, text: str, line: str, width: int) -> str:
        return "".join(line.format(escape(part)) for part in textwrap.wrap(text, width))


class CardPainter:
    def __init__(self, shell: Shell, svg: SvgCard) -> None:
        self._shell = shell
        self._svg = svg

    def paint(self, cards: dict) -> tuple:
        return self._png("title", self._svg.title(cards)), self._png(
            "end", self._svg.end(cards)
        )

    def _png(self, name: str, svg: str) -> str:
        source, png = self._shell.path(name + ".svg"), self._shell.path(name + ".png")
        with open(source, "w") as out:
            out.write(svg)
        self._shell.execute(["rsvg-convert", "-o", png, source], name + ".log")
        return png


class BoxWatcher:
    """When the key box shows: a row inside it is all box background only then."""

    def __init__(self, shell: Shell) -> None:
        self._shell = shell

    def spans(self, video: str) -> list:
        rows = self._probe(video)
        width = PROBE_W * RGB
        frame_bytes = width * PROBE_ROWS
        shown = [
            self._is_box(rows[frame * frame_bytes : frame * frame_bytes + width])
            for frame in range(len(rows) // frame_bytes)
        ]
        return self._runs(shown)

    def _probe(self, video: str) -> bytes:
        raw = self._shell.path("probe.rgb")
        crop = PROBE_CROP % (FPS, PROBE_W, PROBE_ROWS, PROBE_X, PROBE_Y)
        args = ["ffmpeg", "-y", "-i", video, "-vf", crop] + list(RAW_RGB) + [raw]
        self._shell.execute(args, "probe.log")
        with open(raw, "rb") as handle:
            return handle.read()

    def _is_box(self, row: bytes) -> bool:
        hits = sum(
            1
            for offset in range(0, len(row), RGB)
            if self._is_background(row[offset : offset + RGB])
        )
        return hits >= BOX_ROW_SHARE * PROBE_W

    def _is_background(self, pixel: bytes) -> bool:
        return all(
            abs(pixel[channel] - BOX_BG[channel]) <= COLOR_SLACK
            for channel in range(RGB)
        )

    def _runs(self, shown: list) -> list:
        edges = [
            frame for frame in range(1, len(shown)) if shown[frame] != shown[frame - 1]
        ]
        bounds = ([0] if shown and shown[0] else []) + edges
        if len(bounds) % HALF:
            bounds.append(len(shown))
        return [
            Span(bounds[edge] / FPS, bounds[edge + 1] / FPS)
            for edge in range(0, len(bounds), HALF)
        ]


class ZoomCurve:
    """One ffmpeg expression per value (center x, center y, zoom): each step eases from
    the framing of the step before to its own over ZOOM_MOVE seconds (smoothstep)."""

    def __init__(self, framings: list, onsets: list) -> None:
        self._framings = framings
        self._onsets = onsets

    def expression(self, field: str) -> str:
        values = [getattr(framing, field) for framing in self._framings]
        last = len(values) - 1
        expr = self._segment(values, last)
        for step in range(last - 1, -1, -1):
            expr = "if(lt(it,%.3f),%s,%s)" % (
                self._onsets[step + 1],
                self._segment(values, step),
                expr,
            )
        return expr

    def _segment(self, values: list, step: int) -> str:
        if step == 0 or values[step] == values[step - 1]:
            return "%.4f" % values[step]
        eased = "clip((it-%.3f)/%.3f,0,1)" % (self._onsets[step], ZOOM_MOVE)
        smooth = "(%s)*(%s)*(3-2*(%s))" % (eased, eased, eased)
        return "(%.4f+(%.4f)*%s)" % (
            values[step - 1],
            values[step] - values[step - 1],
            smooth,
        )


class FilterGraph:
    def video(self, curve: ZoomCurve, boxes: list, timeline: Timeline) -> list:
        enable = self._enable(boxes)
        box = (BOX_X, BOX_Y, BOX_W, BOX_H)
        return [
            "[0:v]fps=%d,setpts=PTS-STARTPTS,split[src][boxsrc]" % FPS,
            # the box is painted out before the zoom, or a stretched copy of it slides
            # past the pasted one while the zoom moves
            "[src]%s,%s,setsar=1[zoomed]"
            % (BOX_PAINT_OUT % (box + (EDITOR_BG, enable)), self._zoom(curve)),
            "[boxsrc]crop=w=%d:h=%d:x=%d:y=%d[box]" % (BOX_W, BOX_H, BOX_X, BOX_Y),
            "[zoomed][box]overlay=%d:%d:enable='%s'[boxed]" % (BOX_X, BOX_Y, enable),
            "[boxed]fade=t=in:d=%.2f,fade=t=out:st=%.2f:d=%.2f,format=yuv420p[main]"
            % (FADE, timeline.main - FADE, FADE),
        ] + self._cards()

    def _enable(self, boxes: list) -> str:
        shown = ["between(t,%.2f,%.2f)" % (span.start, span.end) for span in boxes]
        return "+".join(shown) or "0"

    def _cards(self) -> list:
        return [
            "[1:v]fps=%d,format=yuv420p,setsar=1,fade=t=out:st=%.2f:d=%.2f[title]"
            % (FPS, TITLE_SECONDS - FADE, FADE),
            "[2:v]fps=%d,format=yuv420p,setsar=1,fade=t=in:d=%.2f[end]" % (FPS, FADE),
            "[title][main][end]concat=n=3:v=1:a=0[v]",
        ]

    def _zoom(self, curve: ZoomCurve) -> str:
        upscale = "scale=%d:%d:flags=lanczos" % (FRAME_W * UPSCALE, FRAME_H * UPSCALE)
        return "%s,zoompan=z='%s':x='%s':y='%s':d=1:s=%dx%d:fps=%d" % (
            upscale,
            curve.expression("zoom"),
            "clip(%s*%d-iw/zoom/2,0,iw-iw/zoom)"
            % (curve.expression("center_x"), UPSCALE),
            "clip(%s*%d-ih/zoom/2,0,ih-ih/zoom)"
            % (curve.expression("center_y"), UPSCALE),
            FRAME_W,
            FRAME_H,
            FPS,
        )

    def audio(self, timeline: Timeline) -> list:
        total = timeline.total()
        return [
            "[0:a]%s,adelay=%d:all=1,apad=whole_dur=%.2f,asplit[voice][key]"
            % (AUDIO_FORMAT, int(TITLE_SECONDS * MS_PER_SECOND), total),
            "[3:a]%s,atrim=0:%.2f,afade=t=in:d=%.2f,afade=t=out:st=%.2f:d=%.2f,volume=%.2f[music]"
            % (
                AUDIO_FORMAT,
                total,
                MUSIC_FADE_IN,
                total - MUSIC_FADE_OUT,
                MUSIC_FADE_OUT,
                MUSIC_GAIN,
            ),
            "[music][key]sidechaincompress=%s[duck]" % DUCK,
            "[voice][duck]amix=inputs=2:normalize=0,atrim=0:%.2f[a]" % total,
        ]


class Polisher:
    def __init__(self, shell: Shell, painter: CardPainter, watcher: BoxWatcher) -> None:
        self._shell = shell
        self._painter = painter
        self._watcher = watcher

    def polish(self, job: PolishJob, graph: FilterGraph) -> None:
        timeline = Timeline(self._duration(job.aligned))
        curve = ZoomCurve(self._framings(job.chapter["focus"]), job.chapter["onsets"])
        boxes = self._watcher.spans(job.aligned)
        filters = graph.video(curve, boxes, timeline) + graph.audio(timeline)
        maps = ["-filter_complex", ";".join(filters), "-map", "[v]", "-map", "[a]"]
        args = ["ffmpeg", "-y"] + self._inputs(job) + maps + list(ENCODE) + [job.out]
        self._shell.execute(args, "mux.log")

    def _inputs(self, job: PolishJob) -> list:
        title, end = self._painter.paint(job.chapter["cards"])
        still = ["-loop", "1", "-framerate", str(FPS), "-t"]
        return (
            ["-i", job.aligned]
            + still
            + [str(TITLE_SECONDS), "-i", title]
            + still
            + [str(END_SECONDS), "-i", end]
            # no loop: a restart mid-video is a hard cut; the track ends on its own outro
            + ["-i", job.music]
        )

    def _framings(self, focus: list) -> list:
        whole = Framing(FRAME_W / HALF, FRAME_H / HALF, 1.0)
        return [Framing(*spot) if spot else whole for spot in focus]

    def _duration(self, path: str) -> float:
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
        return float(self._shell.execute(probe, "duration.log").strip())


class CompositionRoot:
    def launch(self, args: list) -> None:
        chapter_path, aligned, music, out = args
        logging.basicConfig(level=logging.INFO, format="%(message)s")
        shell = Shell(tempfile.mkdtemp(prefix="polish-"))
        with open(chapter_path) as handle:
            job = PolishJob(json.load(handle), aligned, music, out)
        polisher = Polisher(shell, CardPainter(shell, SvgCard()), BoxWatcher(shell))
        polisher.polish(job, FilterGraph())
        logging.getLogger("polish").info(
            "wrote %s (work files in %s)", out, shell.path("")
        )


if __name__ == "__main__":
    CompositionRoot().launch(sys.argv[1:])
