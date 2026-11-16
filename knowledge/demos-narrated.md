# nvim config: narrated demo videos

Snapshot: `feat/narrated-demos` @ `a6e5d63` (2026-11-16, earlier sections from 2026-11-15). Verified by rendering
`docs/demos/narrated/c5-debug-python.tape` twice, reading frames, and transcribing the final mp4.
The real voice was NOT generated (OpenRouter key broken, see below); the sync was proven with a
throwaway macOS `say` voice that was never kept as a deliverable.

## What exists
- `docs/demos/keycast.lua` now adds the mapping `desc` as a second line in the key box
  (`<Space>bc` / `Conditional breakpoint`). The workflow GIFs (c1..c8) load the same file, so a
  re-render of them picks this up too.
- `docs/demos/narrated/c5-debug-python.tape`: chapter 5 re-timed for a voice track.
- `docs/demos/narrated/c5-debug-python.json`: the 10 narration lines (English) and the second at
  which the step of each line shows on screen (`onsets`, measured from the rendered video).
- `docs/demos/narrated/c5-debug-python.silent.mp4`: the rendered silent video (51.96 s).
- `docs/demos/narrated/narrate.py`: the voice (one gpt-audio call per chapter, checked, retried
  whole). Rewritten from `~/gatik/drafts/secrets-roadmap-15-en/narr.py` to the immutable Python rules.
- `docs/demos/narrated/align.py` + `test_align.py` (5 tests): places each line of the take at its
  onset and writes the final mp4 (the `.srt` was removed on 2026-11-15: the player showed it). How to run: `../docs/DEVELOPMENT.md` "Narrated videos".
- Run the tests with `PYTEST_DISABLE_PLUGIN_AUTOLOAD=1`: without it the pyenv pytest crashes in
  a plugin (`ValueError: numpy.dtype size changed` from thinc).

## Gotchas (all measured 2026-11-15)
- **VHS default 50 fps drops frames at 1400x820**: a tape with 21.7 s of action rendered to
  8.92 s and 7.88 s on two runs. `Set Framerate 24`: 16.44 / 17.84 s. `Set Framerate 15`:
  21.24 / 21.44 s. Narrated tapes must use 15 fps or the voice cannot be placed.
- **`Hide` removes hidden time from the video** (`t: 5.76 s` with a hidden 3 s vs `nohide: 8.68 s`).
  So every `Wait+Screen` goes inside `Hide`: its length varies per run, and hidden it costs 0 s.
- Planned vs measured step starts for c5 differ by at most ~0.5 s (step 6: 35.5 planned, 35.12
  measured). Measure onsets from the video (orange box pixel at 698,598), do not trust the plan.
- **which-key replays a leader sequence**: `on_key` gets `key=<t_..> typed=<Space>ba` after the
  three single keys, so the old box showed `<Space>dk<Space>dk`. Mapping output (`zv` after a debug
  step) arrives with `typed == ""`. keycast now ignores both.
- **Prompts freeze floats**: during `Breakpoint condition:` (cmdline mode) the box stayed at
  `<Space>b` until `vim.cmd.redraw()` was added for mode `c`.
- Splitting one TTS take by "longest N-1 pauses" failed: in the `say` take every pause was
  0.24-0.31 s and the cut shifted by one sentence. Word times from `whisper-cli`
  (`~/.cache/whisper-cpp/ggml-base.en.bin`, `-ml 1 -sow -oj`), matched to the script with
  difflib, then snapped to the nearest real pause (`silencedetect`), gave clean cuts.
- The pyenv `whisper` (openai-whisper) is broken: `ImportError: Numba needs NumPy 2.1 or less.
  Got NumPy 2.3.` Use `whisper-cli` (whisper.cpp) instead.
- `ffmpeg -shortest` with a filter graph cut the last line; pad the audio with
  `apad=whole_dur` and the video with `tpad` instead.
- `pkill -f "manage.py runserver"` inside a Bash tool call kills that same shell (exit 144),
  because the pattern is in its own command line.

## Voice key (resolved 2026-11-15)
- `OPENROUTER_API_KEY` (and `OPENROUTER_TOKEN`, `OPENROUTER_API_TOKEN` in `~/.config/secrets.env`,
  same value) is a **management key**: `GET /api/v1/key` shows `is_management_key: True`, and
  `chat/completions` answers `{"error":{"message":"User not found.","code":401}}`. A management key
  cannot call models; it only creates keys.
- With the ok of the user, an inference key `nvim-demos` (limit 2 USD) was created with
  `POST /api/v1/keys` and kept only in the session scratchpad, not in any repo or secrets file.
  Next session: create a new one the same way, or add an inference key to `secrets.env`.
- First real take (gpt-audio, `marin`): `take 1 OK 45.1 s, recall 0.98 ratio 1.02`. After
  `align.py`, whisper-cli heard all 10 lines in order; line 6 lands 0.75 s after its step
  because line 5 runs long. Low-quality preview (700x410, crf 32) sent to the user for review.
- User feedback on that take: the voice must sound more natural, and the chapter must be about a
  situation a developer meets and how the config makes it faster, not a list of keys. So
  (2026-11-15, v2): the script tells one bug story (a total wrong for one loop value, no print
  calls), `STYLE` in `narrate.py` asks for a relaxed human read instead of a "verbatim TTS
  engine", and the tape Sleeps were sized from the measured length of each spoken line (longest
  of the marin and cedar takes + 0.7 s). Video 51.96 s -> 80.92 s. Two previews (marin, cedar)
  sent for the user to pick a voice; whisper heard all 11 lines in order in both, only line 0 is
  0.30 s late (it starts at 0). Order to follow for any chapter: script, voice, measure line
  lengths, size the tape Sleeps, render, measure onsets, align.
- Onsets: the orange box pixel at 698,598 marks every key step. The launch picker hides the box,
  and the DAP UI opening also lights that pixel (a 0.12 s blip), which is the onset of the
  "it stops" step. The outro onset is the `dt` box + 0.45 s typing + its 3 s Sleep.
- `crop=1:1:698:598` fails on ffmpeg 9 ("Invalid too big or non positive size"); use
  `crop=w=2:h=2:x=698:y=598`. The mp4 reports 25 fps even though the tape renders at 15.
- cedar take 1 failed the length check (802.5 s for 225 words, runaway) and was redone whole.

## v3 (2026-11-15): movement chapter, problem-first lines, cost cap
- User asked for a chapter on moving around the config with basic Vim commands, and for every
  line to talk about the problem, not the shortcut. New `c2-move-around.{tape,json}`
  (go to definition and back, open file by name, gg } j w L H, / and n, project grep, ciw + u).
  c5 lines rewritten the same way ("only when number is three, so the breakpoint gets a
  condition", not "Space B C adds...").
- `keycast.lua`: `BUILTIN_DESC` names the own commands of Vim (`gg` / "Top of file"); maparg is now
  also asked for 1-key mappings (`H` / "Line start"). which-key replays a plain prefix key by
  key (`gg` logged as `<t_g>`, g, g, g), so the box showed `gggg`; keys that arrive under 30 ms
  after the previous one once a `<t_..>` trigger was seen are now dropped.
- **Cost**: the inference key `nvim-demos` (limit 2 USD) ended at `usage: 3.52678515`; the
  limit does not stop a request already running. Two runaway takes (802 s of audio each) were
  read to the end before the length check. `narrate.py` now stops reading a reply once it
  passes the longest allowed take (`STREAM_BYTES_PER_PCM_BYTE`), about 13 MB for 227 words.
- Only cedar takes exist for v3 (marin hit 403 after the limit). Measured line lengths (s):
  c2 `10.69 7.09 3.35 5.03 9.54 5.65 7.36 7.21 7.29`, c5 `12.82 8.33 8.36 5.17 6.11 8.65 4.56
  2.70 3.51 3.59 5.21`. Videos: c2 71.04 s, c5 81.12 s; whisper heard every line in order.
- Onset detection that works: count orange pixels in `crop=w=400:h=160:x=500:y=520`; one pixel
  missed boxes whose text covered it. Each step must end with a Sleep of at least 2 s, or the
  box (1.8 s fade) runs into the next step and its text piles up.
- **Wrong line, not yet fixed**: c2 line 6 says "The preview shows each hit", but at 1400x820
  live grep shows no preview pane. Needs a new take (budget) or a config change.

## v4 (2026-11-15): pilot c5 with cards, zoom and music
- Plan: `docs/decisions/2026-11-15-narrated-videos-pro.md` (grill, 21 decisions: README gets a
  60-75 s trailer mp4 + the old c1..c8 GIFs with "watch with narration" links; 6 chapters;
  voice cedar; Lyria music; zoom; cards; key limit 8 USD; pilot c5 first).
- `polish.py`: title card, zoom per step (`focus` in the json), key box pasted back over the
  zoom, end card (before / here / install), music ducked under the voice. Pilot output:
  92.2 s, 3.4 MB, whisper heard all 11 lines over the music.
- Gotchas: this ffmpeg has no `drawtext` (no freetype), so cards are SVG via `rsvg-convert`.
  `crop=W:H:X:Y` positional fails on ffmpeg 9; use `crop=w=..:h=..:x=..:y=..` with h >= 2.
  Without painting the box out before the zoom (`drawbox`), a stretched copy of it slides
  across the frame while the zoom moves.
- which-key maps every prefix (`g`, `z`, `<Space>`) with desc `which-key-trigger`; keycast
  must skip that desc, or it thinks the command ended on its first key.
- Lyria on OpenRouter: `google/lyria-3-pro-preview`, needs `"stream": true`, returns one mp3
  (ID3, 44.1 kHz) of about 92 s, cost 0.08 USD. Track mean -20 dB, voice -21 dB, so the music
  gain is 0.4. The track lives only in the scratchpad so far.
- Key spend after the pilot: limit raised to 8 USD (`usage` 3.62 before Lyria).

## v5 (2026-11-16): all decided chapters, trailer, README
- Done and committed on `feat/narrated-demos` (not pushed): narrated c2, c4, c5, c6, c7, c9 and a
  70.8 s trailer (3.6 MB) in `docs/demos/narrated/*.mp4`; tests GIF `workflows/c9-run-tests.gif`;
  README links the trailer and each narrated chapter. Every final mp4 was transcribed with
  whisper-cli (all lines heard) and its frames read.
- Final sizes: c2 82.6 s / 3.5 MB, c4 56.8 s / 2.3 MB, c5 92.1 s / 3.4 MB, c6 64.6 s / 3.8 MB,
  c7 56.0 s / 2.3 MB, c9 59.4 s / 3.0 MB. OpenRouter key `nvim-demos`: `usage` 4.01 of 8 USD.
- Not verified: whether GitHub plays a committed mp4 inline. The README links the files; an
  inline player in the README needs the mp4 dragged into the GitHub web editor (user-attachments),
  which is a manual step for the user.
- Gotchas found this round:
  - which-key maps prefixes with desc `which-key-trigger`; typed `<Space>` inside a prompt must
    stay a character in the key box, or the box overflows.
  - neotest output window does not close with `q` in VHS; `:close` does. Running `<leader>nd`
    from that window says "No tests found".
  - A hidden wait longer than the 1.8 s box fade removes the key box from the video.
  - The DAP locals panel is too narrow to show a value; ask the REPL instead (c9 step 6).
  - Card title max 32 chars at 60 px; `polish.py` raises `CardError` past that.
  - Step times move by up to 1 s between renders: always measure onsets on the final render.
