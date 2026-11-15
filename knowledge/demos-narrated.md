# nvim config: narrated demo videos

Snapshot: `feat/narrated-demos` @ `fe40ecc` + uncommitted work (2026-11-15). Verified by rendering
`docs/demos/narrated/c5-debug-python.tape` twice, reading frames, and transcribing the final mp4.
The real voice was NOT generated (OpenRouter key broken, see below); the sync was proven with a
throwaway macOS `say` voice that was never kept as a deliverable.

## What exists
- `docs/demos/keycast.lua` now adds the mapping `desc` as a second line in the key box
  (`<Space>bc` / `Conditional breakpoint`). The workflow GIFs (c1..c8) load the same file, so a
  re-render of them picks this up too.
- `docs/demos/narrated/c5-debug-python.tape`: chapter 5 re-timed for a voice track.
- `docs/demos/narrated/c5-debug-python.json`: the 10 narration lines (English) and the second at
  which each line's step shows on screen (`onsets`, measured from the rendered video).
- `docs/demos/narrated/c5-debug-python.silent.mp4`: the rendered silent video (51.96 s).
- `docs/demos/narrated/narrate.py`: the voice (one gpt-audio call per chapter, checked, retried
  whole). Rewritten from `~/gatik/drafts/secrets-roadmap-15-en/narr.py` to the immutable Python rules.
- `docs/demos/narrated/align.py` + `test_align.py` (5 tests): places each line of the take at its
  onset and writes the `.srt` and final mp4. How to run: `../docs/DEVELOPMENT.md` "Narrated videos".
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

## Blocker
- `OPENROUTER_API_KEY` is set, `GET /api/v1/key` returns 200 with `usage: 0`, but
  `chat/completions` returns `{"error":{"message":"User not found.","code":401}}`. The voice
  (gpt-audio, voice `marin`, per `~/.claude/rules/tts.md`) needs a working key.
