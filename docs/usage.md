# Usage

## General syntax

```bash
adv-install [OPTIONS] INPUT
```

## Supported input types

### Single APK

```bash
adv-install "/storage/emulated/0/Download/application.apk"
```

### Archives

Supported archive extensions:

- `.apks`
- `.xapk`
- `.zip`

Example:

```bash
adv-install "/storage/emulated/0/Download/application.apks"
```

### Directory containing split APK files

```bash
adv-install "/storage/emulated/0/Download/application-splits"
```

## Options

- `--no-grant`: omit Package Manager's runtime permission grant request.
- `--no-downgrade`: omit Package Manager's downgrade request.
- `--fresh`: remove the current-user installation before reinstalling.
- `--package PACKAGE_ID`: package ID used by `--fresh`.
- `--`: stop option parsing.
- `-h`, `--help`: show help text.

## Examples

Basic install:

```bash
adv-install "/storage/emulated/0/Download/application.apk"
```

Install without permission grant request:

```bash
adv-install --no-grant "/storage/emulated/0/Download/application.apk"
```

Install without downgrade request:

```bash
adv-install --no-downgrade "/storage/emulated/0/Download/application.apk"
```

Install path containing spaces:

```bash
adv-install "/storage/emulated/0/Download/My Application.apk"
```

Fresh reinstall:

```bash
adv-install --fresh --package com.example.app "/storage/emulated/0/Download/application.apk"
```

## Expected output

A successful run looks like:

```text
Staging:
  /storage/emulated/0/Download/application.apk
  -> /data/local/tmp/adv_install_12345_1784290248/base.apk
Installing single APK...
Success
```

## Archive behavior

If an archive contains `universal.apk` or `standalone.apk`, `adv-install` prefers that single package.

For split installs, `base.apk`, `master.apk`, or `base-master.apk` is moved to the first install position when found.

Archive entry paths are validated before extraction, and extracted symbolic links are rejected.
