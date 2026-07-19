# Scope and purpose

`adv-install` is a shell-oriented installer for locally stored APK files on non-rooted Android devices.

The project exists to provide an on-device Termux + Shizuku route for installing local APKs through the Android shell identity, especially in response to Android Developer Verification changes.

It changes the installation route. It does not weaken Android's package-security model.

## Components

`adv-install` combines:

- **Termux** for the local command-line environment.
- **Shizuku** for access to Android's shell service.
- **`rish`** for forwarding commands from Termux to Shizuku-backed shell execution.
- **Android Package Manager** for final installation.

## Common use cases

- Installing private development builds.
- Installing open-source applications outside a participating application store.
- Installing archived or discontinued applications.
- Installing internal test builds.
- Installing modified applications on an authorized test device.
- Compatibility testing.
- Security research.
- Application preservation.
- Personally controlled device management.

## Developer Verification scope

Google documents an ADB installation exception for Developer Verification. `adv-install` is built around a Shizuku-backed shell route that uses `uid=2000(shell)`.

Important caveat: Google does not explicitly guarantee that Shizuku or `rish` workflows will always be treated exactly like direct ADB usage in future releases.

## What adv-install is designed to avoid

When Android treats the operation as an exempt shell install, this workflow is intended to avoid:

- Developer Verification console enrollment.
- Developer Verification package registration.
- Consumer advanced flow activation.
- Advanced flow waiting periods.
- Repeated graphical Package Installer interaction.
- Root access.
- USB-connected computer use for every installation after setup.

Behavior remains dependent on Android, Package Manager, Google Play services, Shizuku, and device-manufacturer implementation.

## What adv-install does not bypass

The script does not bypass:

- APK signature validation.
- APK structural validation.
- Package parsing.
- Package-name validation.
- Update signing-certificate matching.
- Version-code enforcement.
- CPU architecture requirements.
- Minimum SDK requirements.
- Split-package dependency requirements.
- Device-owner policy.
- Work-profile policy.
- Enterprise-management restrictions.
- Android user restrictions.
- SELinux enforcement.
- Package Manager security checks.
- Play Protect scanning or detection.
- Signature-level permission restrictions.
- Privileged permission restrictions.
- Manufacturer-specific installation restrictions.
- Application integrity checks performed after installation.
- Play Integrity API checks.
- Application licensing checks.
- Server-side authentication.
- Account requirements imposed by an application.

An APK that is invalid, incompatible, corrupt, incomplete, incorrectly signed, or blocked by policy can still fail.

## Installation, not downloading

`adv-install` does not download APK files.

The APK must already exist on the device, for example:

```text
/storage/emulated/0/Download/application.apk
```

The file may have been obtained through:

- A trusted developer website.
- A source-code release page.
- A local build process.
- An authorized file transfer.
- A private repository.
- Another lawful distribution method.

`adv-install` begins after the file has been saved locally. The project is not an APK store, downloader, or malware scanner.
