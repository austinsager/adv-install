# FAQ

## Does adv-install allow APKs from unverified developers to be installed?

That is the project's primary purpose when Android treats the operation as an exempt shell installation route. The APK must still pass Android's ordinary Package Manager checks.

## Does the developer need to complete Android Developer Verification?

Google documents that ADB installations may proceed without Developer Verification. `adv-install` is designed to use Android's shell installation route through UID `2000(shell)`.

Google does not specifically guarantee Shizuku or `rish`, so future behavior may depend on Android's classification of that shell operation.

## Does adv-install use the consumer advanced flow?

No. The script invokes Package Manager through the Android shell identity.

## Does adv-install require root?

No.

## Does adv-install require a computer?

A computer is not required for normal use after Shizuku has been configured through wireless debugging on a supported Android device.

## Does adv-install download APKs?

No. `adv-install` handles only installation. The APK must already be stored on the device.

## Does adv-install install every APK?

No. Invalid, corrupt, incompatible, incomplete, incorrectly signed, or policy-blocked APKs may still fail.

## Does adv-install disable Play Protect?

No.

## Does adv-install bypass APK signatures?

No.

## Does adv-install bypass update-signature mismatches?

No.

## Does adv-install automatically grant every permission?

No. The default `-g` option requests eligible runtime permissions. Android controls which permissions may be granted.

## Can adv-install install split APKs?

Yes, on a best-effort basis. Complex device-targeted archives may require a specialized installer.

## Will adv-install always work after future Android updates?

No permanent guarantee can be made.

The project depends on:

- Android's continued ADB exception.
- Android shell permissions.
- Shizuku functionality.
- `rish` functionality.
- Package Manager behavior.
- Google Play services behavior.
- Manufacturer implementation.
