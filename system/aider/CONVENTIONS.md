# Global coding conventions

## General principles
- Prefer clarity over cleverness. Code is read far more than it is written.
- Use the return-early pattern to reduce nesting. Fail fast, exit early.
- Write self-documenting code. Reserve comments for *why*, not *what*.
- Follow the principle of least surprise. Code should behave as expected.
- Prefer boring, established solutions over shiny new libraries.

## Code structure
- Split large files into small, focused modules with a single responsibility.
- Keep functions short — if it doesn't fit on one screen, split it.
- Avoid deep nesting. Max 3 levels. Flatten with early returns or extracted functions.
- Delete dead code. Don't comment it out.

## Naming
- Use descriptive names. `user_id` not `uid`, `process_payment` not `do_stuff`.
- Be consistent — if one function is `get_user`, don't name another `fetch_account`.
- Avoid abbreviations unless universally understood (`url`, `id`, `db` are fine).
- Booleans should read as statements: `is_valid`, `has_permission`, `should_retry`.

## Error handling
- Always handle errors explicitly. Never silently swallow exceptions.
- Fail loudly in development, gracefully in production.
- Prefer specific error types over generic ones.

## Testing
- Write tests for edge cases, not just the happy path.
- Test behaviour, not implementation details.
- A test that needs to be rewritten every time the internals change is a bad test.

## Git
- Each commit should represent one logical change.
- Commit messages: imperative tense, present tense. "Add feature" not "Added feature".
- Never commit commented-out code, debug prints, or TODO without a ticket reference.

## What NOT to do
- Do not add dependencies for things that can be done in a few lines of standard library.
- Do not over-engineer. Solve the problem in front of you, not the imagined future one.
- Do not rewrite working code unless there is a clear reason.
- Do not add unrelated changes in the same commit or PR.
- Do not use magic numbers — name your constants.
