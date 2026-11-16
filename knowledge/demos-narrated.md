# nvim config: narrated demo videos

Snapshot: `main` @ `5188f2d` (2026-11-16), the merge of PR #19
(https://github.com/iklobato/iklobato-nvim-config-python/pull/19). Written by the session that
built the narrated videos (2026-11-15 to 2026-11-16). Verified by rendering every tape, reading
frames of every step, transcribing every final mp4 with whisper-cli, and the commands quoted
below. Not read or changed: the GIF tapes c1, c3, c8, and the perf work on `perf/faster-boot-ty`.
Facts rot; re-check a number or a line ref before acting on it.

## Status at a glance
- **Done:** a 70.8 s trailer and 6 narrated chapters (c2, c4, c5, c6, c7, c9) with voice, title
  and end cards, zoom and background music, in `docs/demos/narrated/`; a new tests GIF
  `docs/demos/workflows/c9-run-tests.gif`; the README links the trailer and each narrated
  chapter. Merged to `main` as PR #19 (`5188f2d`).
- **Discovered:** the env `OPENROUTER_API_KEY` is a management key and cannot call models; VHS
  needs 15 fps for the timing to hold; which-key confuses an `on_key` keycast in three ways;
  this ffmpeg has no `drawtext`. Details under Gotchas.
- **Next steps:** (1) the user checks the trailer plays on GitHub and decides on an inline
  player (a manual upload, see What is left); (2) PR #18 (`perf/faster-boot-ty`) now conflicts
  with `main` and needs a rebase; (3) decide whether to delete the inference key `nvim-demos`.
- **What is left:** an inline video player at the top of the README; narrated versions of the
  GIF chapters c1 (open a project), c3 (write code) and c8 (git) were not planned; the Lyria
  terms for public use were not checked.
- **Monitor:** the key box pixel place is hard-coded in `polish.py` (see Contracts); the
  inference key has no expiry and about 3.69 USD left of its 8 USD limit.

## What exists (all on `main`)
| Path | What it is |
|---|---|
| `docs/demos/keycast.lua` | Key box loaded by every tape: key caps, command name, fixed 46x5 cells, bottom right |
| `docs/demos/narrated/narrate.py` | Voice: one `openai/gpt-audio` call (voice `cedar`) per chapter, checked, redone whole |
| `docs/demos/narrated/align.py` | Places each spoken line at its step; writes an mp4 (voice + silent video), no subtitles |
| `docs/demos/narrated/polish.py` | Title card, zoom per step, key box pasted back, end card, music ducked under the voice |
| `docs/demos/narrated/test_align.py`, `test_polish.py` | 9 tests: placement, cut choice, zoom easing, title length |
| `docs/demos/narrated/<chapter>.tape`, `.json`, `.silent.mp4`, `.mp4` | Keys, script with timing/zoom/cards, silent render, final video |
| `docs/demos/narrated/trailer.json` | No tape: `clips` lists `[chapter, start, end]` cuts of the silent chapters |
| `docs/demos/narrated/music.mp3` | One Lyria track (92 s, 2.2 MB) used by every video |
| `docs/demos/workflows/c9-run-tests.tape`, `.gif` | Short muted tests GIF in the style of c1..c8 |
| `docs/decisions/2026-11-15-narrated-videos-pro.md` | The 21 decisions behind the series (audience, format, voice, budget) |
| `docs/DEVELOPMENT.md`, section "Narrated videos" | The commands to rebuild a chapter |

Chapters: c2 moving around + basic Vim, c4 fixing warnings in an old file, c5 debugging Python,
c6 debugging Django live + an error lost in asyncio, c7 API and database, c9 running and
debugging tests. Each script talks about the developer problem, not the key; the key box names
the keys. Final videos, measured 2026-11-16 with `ffprobe` and the file size:
```
trailer            70.8 s  3.56 MB
c2-move-around     82.6 s  3.51 MB
c4-fix-warnings    56.8 s  2.28 MB
c5-debug-python    92.1 s  3.40 MB
c6-debug-django    64.6 s  3.79 MB
c7-api-and-db      56.0 s  2.33 MB
c9-run-tests       59.4 s  2.98 MB
```
`PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 python3 -m pytest -q docs/demos/narrated` -> `9 passed`.

## How a chapter is made (order matters)
1. Demo project: `bash tests/fixtures/monorepo.sh /tmp/demo`. Tapes run the live config in
   `~/.config/nvim` (whatever branch it is on), not the repo the tape sits in.
2. Write `<chapter>.json` `sentences`: one line per step, about the problem, no contraction with
   an apostrophe.
3. Write the tape: `Set Framerate 15`, every `Wait` inside `Hide`, hidden cursor moves end with a
   hidden `Sleep 2.2s` so the old key box fades, one `# step N` comment per sentence, each step
   ends with a `Sleep`. Render a draft and read its frames before paying for a voice.
4. Voice: `OPENROUTER_API_KEY=<inference key> python3 -I narrate.py <chapter>.json voice.wav`.
5. Measure each spoken line (`align.LineSplitter.spans`), then set the last `Sleep` of each step
   to `max(2.0, line + 0.9 - visible time already in the step)` (typing is 150 ms per key).
6. Render, then measure the onsets: `polish.BoxWatcher(...).spans(silent.mp4)` lists when the key
   box shows; a step starts when its box appears. A step without a key is computed from the step
   before it.
7. Add `focus` (null or `[center_x, center_y, zoom]` in 1400x820 pixels; keep the subject out of
   the key box corner) and `cards` (`label`, `title` up to 32 chars, `problem`, `before`, `after`).
8. `align.py`, then `polish.py` (commands in `docs/DEVELOPMENT.md`). Check that whisper hears
   every line and that frames of each zoom show the subject.
- Tapes that change demo files (c4 squeezes spacing, c9 adds a bug with `sed`) restore them with
  `git -C /tmp/demo checkout -- <file>` in their hidden end. c6 and c7 start Django and stop it
  with `pkill` at the end.

## Contracts between files (change both sides together)
- Key box size and place: `keycast.lua` `BOX_WIDTH = 46`, `BOX_HEIGHT = 5`, anchored bottom right
  -> `polish.py` `BOX_X, BOX_Y, BOX_W, BOX_H = 801, 542, 541, 166` and
  `PROBE_X, PROBE_Y, PROBE_W = 815, 548, 515`. Measured from a frame by the box background color
  `#17171A`; measure again after any change to the box or to `docs/demos/settings.tape`.
- Onsets: step times move by up to about 1 s between two renders of the same tape (one c5 step
  measured 13.88, 14.00 and 13.92 s). Always measure on the render that ships.
- Voice: `narrate.py` `VOICE = "cedar"`. Every video of the series must use the same model and
  voice (`~/.claude/rules/tts.md`); the trailer and all chapters use cedar.
- Trailer clips point at times inside the chapter silent videos: re-rendering a chapter can move
  them; cut each clip just before its key press or the trailer loses the key box.

## Gotchas (all measured in this session)
**VHS**
- The default 50 fps drops frames at 1400x820: 21.7 s of action rendered to 8.92 s and 7.88 s;
  at 24 fps 16.44 / 17.84 s; at `Set Framerate 15` 21.24 / 21.44 s.
- `Hide` removes the hidden time from the video (5.76 s with a hidden 3 s, 8.68 s without), so
  waits of unknown length go inside `Hide`.
- A hidden wait longer than the 1.8 s box fade removes the key box from the video: after a key
  the viewer should see, wait at most about 1.2 s hidden.
- VHS `Output` paths containing `-` must be quoted. The mp4 reports 25 fps though it renders at 15.

**Key box (`keycast.lua`)**
- which-key replays keys: a leader sequence comes back as one `<t_..>` key with
  `typed=<Space>ba`; a plain prefix comes back key by key (`gg` logged as `<t_g>`, g, g, g).
  Both are dropped (multi-key `<t_..>`, and keys under 30 ms after a which-key trigger).
- which-key maps every prefix (`g`, `z`, `<Space>`) with desc `which-key-trigger`; the box skips
  that desc, or it thinks the command ended on its first key.
- Mapping output arrives with `typed == ""` (the `zv` after a debug step): ignored.
- A space typed into a prompt arrives as `<Space>`: it stays a character of the text chip, or the
  box overflows and cuts the last key.
- Prompts in cmdline mode do not repaint floats: `vim.cmd.redraw()` in mode `c`.

**ffmpeg (9.0.1, built without freetype)**
- No `drawtext`: cards are SVG templates rendered with `rsvg-convert`.
- Positional `crop=W:H:X:Y` fails ("Invalid too big or non positive size"); use
  `crop=w=..:h=..:x=..:y=..` with a height of at least 2.
- `-shortest` with a filter graph cut the last line; pad with `apad=whole_dur` and `tpad`.
- Without painting the box out (`drawbox`) before the zoom, a stretched copy of it slides across
  the frame while the zoom moves.

**Voice and alignment**
- whisper-cli word times are off by a few hundred ms: each cut goes in the longest real pause
  (`silencedetect`) within 0.4 s of the gap, or "breakpoints" was clipped into "points".
  Splitting a take at its longest pauses alone shifted the cuts by one sentence.
- The pyenv `whisper` is broken (`Numba needs NumPy 2.1 or less. Got NumPy 2.3.`): use
  `whisper-cli` with `~/.cache/whisper-cpp/ggml-base.en.bin`.
- gpt-audio sometimes runs away (802 s of audio for 227 words). `narrate.py` stops reading a
  reply past the longest allowed take (about 13 MB for 227 words); before that fix two runaway
  takes were billed in full, and the key limit does not stop a request already running.
- The first voice prompt ("verbatim text-to-speech engine, steady pace") sounded robotic to the
  user; the current `STYLE` asks for a relaxed developer talking to a friend.
- pytest needs `PYTEST_DISABLE_PLUGIN_AUTOLOAD=1` (a thinc plugin crashes otherwise).

**Neovim flows used by the tapes**
- The neotest output window does not close with `q` in VHS; `:close` does. Running
  `<leader>nd` from that window says "No tests found".
- The DAP locals panel is too narrow to show a value; c9 asks the REPL (`result` -> `8`).
- Live grep shows no preview pane at 1400x820, so no line may promise a preview.
- `pkill -f "manage.py runserver"` inside a Bash tool call kills that same shell (exit 144).

## Keys and cost (names only, never values)
- `OPENROUTER_API_KEY`, `OPENROUTER_TOKEN` and `OPENROUTER_API_TOKEN` in `~/.config/secrets.env`
  hold the same management key: `GET /api/v1/key` shows `is_management_key: True`, and
  `chat/completions` answers `{"error":{"message":"User not found.","code":401}}`.
- With the approval of the user an inference key named `nvim-demos` was created from it
  (`POST /api/v1/keys`), limit raised from 2 to 8 USD. Its value lives only in the session
  scratchpad, in no repo and no secrets file; a new session must create or receive a key.
- Spend on 2026-11-16: `{'limit': 8, 'usage': 4.30966795, 'expires_at': None}`. Good voice costs
  about 0.10 USD per minute; one Lyria track costs 0.08 USD (`google/lyria-3-pro-preview`, needs
  `"stream": true`, returns one mp3).

## Open risks
- PR #18 (`perf/faster-boot-ty`) reports `CONFLICTING DIRTY` after PR #19: both change
  `README.md`, `docs/DEVELOPMENT.md` and `knowledge/README.md`.
- Not verified: GitHub playing a committed mp4 in its file view. An inline player in the README
  needs the mp4 dragged into the GitHub web editor (user-attachments), a manual user step.
- The trailer must stay under 10 MB (GitHub free plan video limit); it is 3.56 MB now.

## How the work went (for context)
1. c5 re-timed at 15 fps; sync proven with a throwaway macOS `say` voice (never shipped); the
   real voice blocked by the management key.
2. Inference key created; first gpt-audio take (`marin`) judged robotic and too focused on keys.
3. Scripts rewritten around the problem; voice prompt made natural; marin and cedar compared.
4. New movement chapter c2; key box names Vim own commands; runaway takes capped.
5. Grill session (21 decisions) chose the audience (Python developers from VS Code), README
   trailer + chapters, cedar, cards, zoom, Lyria music, an 8 USD budget and a c5 pilot.
6. Pilot c5 approved; then c2, c4, c6, c7, c9, the tests GIF, the trailer and README links;
   pushed and merged as PR #19.

## Session log
- 2026-11-15: keycast shows mapping names; c5 re-timed at 15 fps; `narrate.py` and `align.py`
  written; voice blocked by the management key.
- 2026-11-15 to 2026-11-16: inference key created; cedar voice with a natural read; grill
  decisions; `polish.py` (cards, zoom, Lyria music); key box redesigned; chapters c2, c4, c5,
  c6, c7, c9, tests GIF, trailer, README links; PR #19 merged into `main` as `5188f2d`.
