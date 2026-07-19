# Troubleshooting

## rish not found

Likely cause: exported files were not copied to `$PREFIX/bin`.

Fix:

```bash
ls -l "$PREFIX/bin/rish" "$PREFIX/bin/rish_shizuku.dex"
```

If missing, repeat the `rish` installation step.

## rish does not return UID 2000

Likely cause: Shizuku is not active or `rish` is not linked correctly to Termux.

Fix:

```bash
rish -c 'id -u'
```

Expected:

```text
2000
```

If not, restart Shizuku and re-check the exported terminal files.

## Unable to open file under shared storage

Likely cause: `pm install` was called directly on a shared-storage path.

Fix: use `adv-install` directly with the APK path so staging is performed.

## Writable DEX error

Likely cause: `rish_shizuku.dex` permissions are too permissive.

Fix:

```bash
chmod 444 "$PREFIX/bin/rish_shizuku.dex"
```

## No APKs found in archive

Likely cause: the archive does not contain usable `.apk` files.

Fix: extract locally and inspect the archive contents.

## Unsupported input type

Likely cause: the supplied path is not a directory and does not end in `.apk`, `.apks`, `.xapk`, or `.zip`.

Fix: confirm the path and extension.

## Package Manager install failure

Possible causes include:

- invalid APK;
- corrupt APK;
- incompatible architecture;
- minimum SDK mismatch;
- update-signature mismatch;
- missing split APK dependency;
- device policy restriction;
- work-profile restriction;
- manufacturer-specific restriction.

Read the Package Manager error and verify APK compatibility.
