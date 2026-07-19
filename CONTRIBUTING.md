# Contributing

Thanks for your interest in improving `adv-install`.

## Project goals

Contributions should preserve the project's purpose: local, authorized APK installation through a non-root Termux + Shizuku shell workflow.

## Before opening a pull request

Run:

```bash
bash -n adv-install
bash tests/run-tests.sh
```

If available, also run:

```bash
shellcheck adv-install
```

## Documentation changes

If script behavior changes, update the relevant documentation under `docs/` and the README summary.

## Safety boundaries

Do not contribute features that:

- download APKs from third-party sources;
- conceal installation activity;
- disable Android security mechanisms;
- target devices not controlled by or authorized for the operator;
- evade enterprise or managed-device policy.
