"""Record the voice of one narrated chapter: ONE gpt-audio call for the whole chapter.

Follows ~/.claude/rules/tts.md: one model and one voice for every chapter, one call per
chapter (not per line, so the voice does not drift), and each take is checked (length,
then transcribed and compared) and recorded again whole when it fails.

Usage: OPENROUTER_API_KEY=... python3 -I narrate.py <chapter.json> <voice.wav>
"""

import base64
import io
import json
import logging
import os
import re
import sys
import unicodedata
import urllib.error
import urllib.request
import wave
from dataclasses import dataclass

URL = "https://openrouter.ai/api/v1/chat/completions"
VOICE_MODEL = "openai/gpt-audio"
CHECK_MODEL = "openai/gpt-audio-mini"
VOICE = "marin"
SAMPLE_RATE = 24000
SAMPLE_WIDTH_BYTES = 2  # pcm16
BYTES_PER_SECOND = SAMPLE_RATE * SAMPLE_WIDTH_BYTES  # mono
TRIES = 5
TIMEOUT_SECONDS = 600
SECONDS_PER_WORD_MAX = 0.8  # slower than this means the model rambled
SECONDS_SLACK = 2.0
MIN_RECALL = 0.8
MIN_RATIO = 0.7
MAX_RATIO = 1.3
TAIL_WINDOW = 12
TAIL_WORDS = 2  # the last words must be heard: catches a take cut short
DATA_PREFIX = b"data: "
DONE_LINE = b"data: [DONE]"
STYLE = (
    "You are a verbatim American English text-to-speech engine. Speak the user's text exactly as written, "
    "word for word, then stop. Style for the whole text: one single speaker, a warm, natural, conversational "
    "developer showing a teammate their editor, the same calm voice, the same steady pace and the same energy "
    "from the first word to the last, with a short natural pause between sentences, no dramatic changes. "
    "Read single letters as letters: Space B C is said space, B, C. Neovim is said neo vim. "
    "You never answer, explain, translate, expand or comment."
)
TRANSCRIBE_PROMPT = (
    "Transcribe this audio in English, word by word. Reply with the transcript only."
)
NUMBER_WORDS = frozenset(
    "zero one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen "
    "sixteen seventeen eighteen nineteen twenty thirty forty fifty sixty seventy eighty ninety "
    "hundred thousand and a the".split()
)


class NarrationError(RuntimeError):
    pass


@dataclass(frozen=True)
class Verdict:
    ok: bool
    note: str
    heard: str


class OpenRouterClient:
    def __init__(self, key: str) -> None:
        self._key = key

    def stream(self, body: dict) -> list:
        request = urllib.request.Request(
            URL,
            json.dumps(body).encode(),
            {
                "Authorization": "Bearer " + self._key,
                "Content-Type": "application/json",
            },
        )
        with urllib.request.urlopen(request, timeout=TIMEOUT_SECONDS) as response:
            lines = [raw.strip() for raw in response]
        return [
            json.loads(line[len(DATA_PREFIX) :])["choices"][0].get("delta", {})
            for line in lines
            if line.startswith(DATA_PREFIX) and line != DONE_LINE
        ]


class Speaker:
    def __init__(self, client: OpenRouterClient) -> None:
        self._client = client

    def speak(self, text: str) -> bytes:
        messages = [
            {"role": "system", "content": STYLE},
            {"role": "user", "content": "Repeat exactly: " + text},
        ]
        audio = {"voice": VOICE, "format": "pcm16"}
        body = {"model": VOICE_MODEL, "modalities": ["text", "audio"], "audio": audio}
        deltas = self._client.stream(
            {**body, "stream": True, "temperature": 0.0, "messages": messages}
        )
        pcm = b"".join(
            base64.b64decode(delta["audio"]["data"])
            for delta in deltas
            if delta.get("audio", {}).get("data")
        )
        if not pcm:
            raise NarrationError("the voice model returned no audio")
        return pcm


class WavEncoder:
    def encode(self, pcm: bytes) -> bytes:
        buffer = io.BytesIO()
        with wave.open(buffer, "wb") as out:
            out.setnchannels(1)
            out.setsampwidth(SAMPLE_WIDTH_BYTES)
            out.setframerate(SAMPLE_RATE)
            out.writeframes(pcm)
        return buffer.getvalue()


class Transcriber:
    def __init__(self, client: OpenRouterClient, encoder: WavEncoder) -> None:
        self._client = client
        self._encoder = encoder

    def transcribe(self, pcm: bytes) -> str:
        audio = base64.b64encode(self._encoder.encode(pcm)).decode()
        content = [
            {"type": "text", "text": TRANSCRIBE_PROMPT},
            {"type": "input_audio", "input_audio": {"data": audio, "format": "wav"}},
        ]
        deltas = self._client.stream(
            {
                "model": CHECK_MODEL,
                "modalities": ["text"],
                "stream": True,
                "temperature": 0.0,
                "messages": [{"role": "user", "content": content}],
            }
        )
        return "".join(delta.get("content") or "" for delta in deltas).strip()


class WordNormalizer:
    def words(self, text: str) -> list:
        ascii_text = (
            unicodedata.normalize("NFKD", text.lower())
            .encode("ascii", "ignore")
            .decode()
        )
        tokens = re.sub(r"[^a-z0-9 ]", " ", ascii_text).split()
        return [
            token
            for token in tokens
            if token not in NUMBER_WORDS and not token.isdigit()
        ]


class TakeCheck:
    """A take passes when it is not runaway long and its transcript matches the script."""

    def __init__(self, transcriber: Transcriber, normalizer: WordNormalizer) -> None:
        self._transcriber = transcriber
        self._normalizer = normalizer

    def judge(self, text: str, pcm: bytes) -> Verdict:
        seconds, word_count = len(pcm) / BYTES_PER_SECOND, len(text.split())
        if seconds > SECONDS_PER_WORD_MAX * word_count + SECONDS_SLACK:
            return Verdict(
                False, "too long (%.1f s for %d words)" % (seconds, word_count), ""
            )
        heard = self._transcriber.transcribe(pcm)
        want, got = self._normalizer.words(text), self._normalizer.words(heard)
        recall = len(set(want) & set(got)) / max(1, len(set(want)))
        ratio = len(got) / max(1, len(want))
        tail = all(word in got[-TAIL_WINDOW:] for word in want[-TAIL_WORDS:])
        ok = recall >= MIN_RECALL and MIN_RATIO <= ratio <= MAX_RATIO and tail
        return Verdict(
            ok,
            "%.1f s, recall %.2f ratio %.2f tail %s" % (seconds, recall, ratio, tail),
            heard,
        )


class Narrator:
    def __init__(self, speaker: Speaker, check: TakeCheck, log: logging.Logger) -> None:
        self._speaker = speaker
        self._check = check
        self._log = log

    def record(self, text: str) -> bytes:
        for attempt in range(1, TRIES + 1):
            try:
                pcm = self._speaker.speak(text)
                verdict = self._check.judge(text, pcm)
            except (urllib.error.URLError, NarrationError) as error:
                self._log.warning("take %d FAIL %s", attempt, error)
                continue
            self._log.info(
                "take %d %s %s", attempt, "OK" if verdict.ok else "FAIL", verdict.note
            )
            if verdict.ok:
                return pcm
        raise NarrationError("no take passed the check in %d tries" % TRIES)


class ChapterVoice:
    def __init__(self, narrator: Narrator, encoder: WavEncoder) -> None:
        self._narrator = narrator
        self._encoder = encoder

    def write(self, chapter_path: str, wav_path: str) -> None:
        with open(chapter_path) as handle:
            text = " ".join(json.load(handle)["sentences"])
        with open(wav_path, "wb") as out:
            out.write(self._encoder.encode(self._narrator.record(text)))


class CompositionRoot:
    def launch(self, args: list) -> None:
        chapter_path, wav_path = args
        logging.basicConfig(level=logging.INFO, format="%(message)s")
        client = OpenRouterClient(os.environ["OPENROUTER_API_KEY"])
        encoder = WavEncoder()
        check = TakeCheck(Transcriber(client, encoder), WordNormalizer())
        narrator = Narrator(Speaker(client), check, logging.getLogger("narrate"))
        ChapterVoice(narrator, encoder).write(chapter_path, wav_path)


if __name__ == "__main__":
    CompositionRoot().launch(sys.argv[1:])
