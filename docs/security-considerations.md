# Security considerations

`adv-install` changes the installation route. It does not make an APK safe.

## Before installing

- Install APKs only from sources you trust or control.
- Verify hashes when a developer publishes checksums.
- Prefer signed releases from known developers or your own local builds.
- Avoid installing APKs from unknown file-sharing sources.
- Review whether the device is personally controlled, test-owned, or organization-managed.

## Verify an APK hash

```bash
sha256sum "/storage/emulated/0/Download/application.apk"
```

Compare the result to a checksum published by the developer or release source.

## Shizuku and rish

After installation work is complete, consider stopping Shizuku if the shell bridge is no longer needed.

Ensure `rish_shizuku.dex` is not writable:

```bash
chmod 444 "$PREFIX/bin/rish_shizuku.dex"
```

## Data handling

`adv-install`:

- does not contact an external backend;
- does not collect metrics;
- does not download APKs;
- briefly stages install files under `/data/local/tmp`;
- removes temporary files during cleanup.
