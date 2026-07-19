# adv-install

`adv-install` is a non-root Termux + Shizuku shell workflow for installing locally stored APK files through Android Package Manager as `uid=2000(shell)`.

The project is intended as an on-device shell installation route in response to Android Developer Verification: it uses Shizuku and `rish` to run Package Manager through the Android shell identity normally associated with ADB, without root and without requiring a USB-connected computer for every APK installation after setup.

> [!IMPORTANT]
> Google documents a Developer Verification exception for Android Debug Bridge (ADB) installs. Google does not explicitly name Shizuku, `rish`, Termux, or `adv-install`. This project is designed to use the same Android shell identity as ADB, but future Android, Google Play services, or manufacturer changes could classify this workflow differently.

## Quick start

1. Install Termux and Shizuku on your Android device.
2. Start Shizuku using wireless debugging.
3. Export `rish` and `rish_shizuku.dex` from Shizuku.
4. Follow the full setup guide in docs/installation.md.
5. Install a local APK:

```bash
adv-install "/storage/emulated/0/Download/application.apk"
```

## Workflow

```text
Local APK or APK archive
        |
        v
Termux
        |
        v
adv-install
        |
        v
rish + Shizuku
        |
        v
uid=2000(shell)
        |
        v
/data/local/tmp staging
        |
        v
Android Package Manager
        |
        v
Installed app
```

## What adv-install does

`adv-install`:

- accepts a local `.apk`, `.apks`, `.xapk`, `.zip`, or directory of split APKs;
- verifies that `rish` returns Android shell UID `2000`;
- stages APK files under `/data/local/tmp`;
- validates staged byte counts;
- calls `pm install` or `pm install-multiple` through `rish`;
- removes local and remote temporary files after success, failure, or interruption.

## Documentation

- docs/scope.md
- docs/installation.md
- docs/usage.md
- docs/technical-overview.md
- docs/security-considerations.md
- docs/troubleshooting.md
- docs/faq.md
- docs/maintenance.md

## Non-goals

`adv-install` does not:

- download APK files;
- provide APK sources;
- disable Play Protect;
- bypass APK signatures;
- bypass Android package parsing;
- bypass update-signature checks;
- bypass device-owner, work-profile, or enterprise policy;
- grant root access;
- guarantee compatibility with future Android or manufacturer changes.

## Install from this repository

After cloning:

```bash
install -m 755 adv-install "$PREFIX/bin/adv-install"
hash -r
```

Then verify:

```bash
command -v adv-install
bash -n "$PREFIX/bin/adv-install"
```

## Test

```bash
bash -n adv-install
bash tests/run-tests.sh
```

If ShellCheck is installed:

```bash
shellcheck adv-install
```

## Responsible use

Use this project only on devices controlled by you or devices where you are authorized to perform installation and testing.

Do not use this project to install malicious software, interfere with another person's device, conceal unauthorized installation activity, or evade organizational policy on managed devices.

## Official references

- Android Developer Verification: [https://developer.android.com/developer-verification](https://developer.android.com/developer-verification)
- Android release notes: [https://developer.android.com/about/versions/16/qpr2/release-notes](https://developer.android.com/about/versions/16/qpr2/release-notes)
- Shizuku: [https://shizuku.rikka.app/](https://shizuku.rikka.app/)
- Shizuku setup guide: [https://shizuku.rikka.app/guide/setup/](https://shizuku.rikka.app/guide/setup/)
- Shizuku downloads: [https://shizuku.rikka.app/download/](https://shizuku.rikka.app/download/)
- `rish` documentation: [https://github.com/RikkaApps/Shizuku-API/blob/master/rish/README.md](https://github.com/RikkaApps/Shizuku-API/blob/master/rish/README.md)
- Termux app: [https://github.com/termux/termux-app](https://github.com/termux/termux-app)

## License

Distributed under the MIT License. See LICENSE.

## Disclaimer

This project is not affiliated with, endorsed by, or sponsored by Google, Android, Shizuku, RikkaApps, Termux, or their respective maintainers.

Android is a trademark of Google LLC.

The project is provided without a guarantee that future Android releases, Google Play services updates, manufacturer changes, or Developer Verification policy changes will preserve current behavior.
