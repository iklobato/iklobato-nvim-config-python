# Narrated tutorial videos: how to make them convincing

Date: 2026-11-15. Settled in a grill session (5 rounds, 20 decisions). Branch `feat/narrated-demos`.
Goal: videos good enough to convince a developer to adopt this Neovim config.

## Decisions

| # | Decision | Chosen | Why | Depends on |
|---|----------|--------|-----|------------|
| 1 | Audience | Python developer coming from VS Code | Largest group; needs basic Vim and a comparison with what they use today | - |
| 2 | Where published | GitHub README only | The repo page is where people decide to install | - |
| 3 | Series shape | One trailer + one chapter per flow | The trailer sells, the chapters teach | - |
| 4 | Narration language | English only | Global audience; it is what exists now | - |
| 5 | How videos show in the README | Trailer as mp4 with voice at the top; each chapter as a muted GIF in its section | GIFs play without a click; the trailer explains for whoever clicks. GitHub embeds an mp4 up to 10 MB on the free plan | 2 |
| 6 | Narrated chapter mp4s | Kept; each chapter GIF gets a "watch with narration" link to its mp4 | Uses the voice work; GIF and mp4 tell the same story | 5 |
| 7 | Chapters (daily loop) | Move around + basic Vim (c2, done), Debug Python (c5, done), Run and debug tests (new), Find and fix errors (c4 flow) | Core loop for a Python developer | 1 |
| 8 | Chapters (extras) | Live Django debug (c6 flow), API + database in the editor (c7 flow) | Strong differentiators. Git (c8) and secret masking left out | 1 |
| 9 | Persuasion | Before and after as text (no VS Code recording), measured numbers only, one-command install at the end | Honest and cheap; every number must come from a real measurement | 1 |
| 10 | Trailer | 60 to 75 s: opens on a developer pain, then 5 to 6 strong moments (about 8 s each, one per chapter), then the install command; must fit 10 MB | Short enough to watch, long enough to explain | 3, 5, 7, 8 |
| 11 | Visual polish | Title and end cards, zoom on the area of action, low background music | Makes it look like a product video | 1 |
| 12 | Resolution | Stays 1400x820, FontSize 18 (1080p was offered, not chosen) | User choice | 11 |
| 13 | Voice | cedar (`openai/gpt-audio`), one voice for every video | Sounded more natural in the c5 v2 previews | 4 |
| 14 | Music source | Generated with Lyria on OpenRouter (same account) | No third-party download; one calm track reused | 11 |
| 15 | Zoom scope | Trailer and every narrated chapter: a zoom rectangle per step in the chapter json, applied by ffmpeg with a smooth move | One mechanism for everything | 11 |
| 16 | Chapter GIFs | Keep the current c1..c8 GIFs as they are | No rework | 5 |
| 17 | GIF for the new tests chapter | Record a short muted tape in the style of c1..c8, with the new key box | Its README section should not be empty | 7, 16 |
| 18 | API budget | Total limit 8 USD on the inference key (3.53 USD already spent) | About 8 min of voice is close to 1 USD, plus music and retakes | 13, 14 |
| 19 | Production order | Pilot: finish c5 with everything (cards, zoom, music, final voice); user approves the pattern; then the other 5 chapters; then the trailer | A style change costs one video, not six | 3, 7, 11 |
| 20 | Cards content | Opening card: chapter title + the problem. End card: before and after ("VS Code: open Run and Debug, write launch.json" / "here: two keys"), a measured number when there is one, and the install command | Keeps the middle of the video clean for the key box and zoom | 9, 11 |
| 21 | Hosting of narrated mp4s | Committed in `docs/demos/narrated/` (about 1 to 2 MB each) | Versioned, no manual upload; GitHub plays mp4 in the file view | 6 |

## Measured numbers available today

- Empty start 43 ms and first Python file 220 ms (interleaved A/B medians, 2026-11-15, branch `perf/faster-boot-ty`, see `knowledge/perf.md` on that branch). That branch is not merged into `main` yet, so the number is only true once it ships.

## Open risks

- c2 line 6 says "The preview shows each hit", but live grep shows no preview pane at 1400x820. Fix in the next c2 voice take (rewrite the line or make the preview show).
- The decided chapters 4 (errors), 6 (Django) and 7 (API + DB) exist only as fast GIF tapes; their narrated versions must be re-timed for voice (15 fps, Waits in Hide). c6 needs a running Django server inside VHS.
- Lyria output rights follow the OpenRouter and Google terms; not checked yet.
- The trailer must stay under 10 MB with voice and music; not measured yet.
- Zoom with ffmpeg (`zoompan` or `crop` + `scale` with eased keyframes) is not built yet; it is the largest piece of new work.

## Left undecided by the user

- Push and pull request: not requested.
