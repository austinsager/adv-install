# Contributing

Thanks for your interest in improving `adv-install`.

## Project goals and scope

Contributions should preserve the project's core purpose: providing a local, authorized APK installation route through a non-root Termux + Shizuku shell workflow operating within the Android shell context (`uid=2000`).

## Before opening a pull request

1. Keep behavior strictly non-root.
2. Preserve safe shell quoting and defensive input validation.
3. Ensure automated cleanup mechanics remain fully intact for success, failure, and process interruption paths.
4. Run local test validation checks:

```bash
bash -n adv-install
bash tests/run-tests.sh
```

If available, also run:

```bash
shellcheck adv-install
```

## Commit / PR guidance

- Keep pull requests highly focused, small, and atomic.
- Explicitly explain any user-visible behavior modifications.
- Include your exact testing/verification steps in the PR description.
- If script behavior changes, update the relevant documentation under `docs/` and the README summary.

## Safety boundaries

Do not contribute features or patches that:
- download APK files from third-party or unverified sources;
- conceal background installation activity;
- disable native Android security mechanisms;
- target hardware environments not explicitly controlled by or authorized for the operator;
- intentionally evade enterprise, MDM, or managed-device organizational policy.
