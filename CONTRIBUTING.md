# Contributing to adv-install

Thanks for helping improve `adv-install`.

## Scope

This project is a Termux + Shizuku shell installer focused on installing locally stored APKs through Android shell context (`uid=2000`).

## Before opening a PR

1. Keep behavior non-root.
2. Preserve safe quoting and input validation.
3. Keep cleanup behavior intact for success/failure/interrupt paths.
4. Run local checks:

```bash
bash -n adv-install
shellcheck adv-install
```

## Commit / PR guidance

- Keep PRs focused and small.
- Explain user-visible behavior changes.
- Include test/verification steps in the PR description.
- If changing install semantics, document it in `README.md`.

## README/script sync policy

The script is intentionally present in both:
- `adv-install` (source file), and
- README setup block (beginner copy/paste flow).

When script logic changes, update **both copies** in the same PR.
