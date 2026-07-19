# Technical overview

For a single APK, the process is:

```text
APK in shared storage
        |
        | Termux on file read
        v
Standard-input byte stream
        |
        | rish processes the bytes as UID 2000(shell)
        v
/data/local/tmp/adv_install_.../base.apk
        |
        | Original and staged byte counts are compared
        v
pm install
        |
        | Android Package Manager processes the package
        v
Temporary files are removed
```

## Features

`adv-install` supports:

- Single `.apk` files.
- `.apks`, `.xapk`, and `.zip` archives containing APK files.
- Directories containing split APK files.
- Filenames containing spaces.
- Quoted paths beginning with `~/`.
- Replacement installations.
- Requested version downgrades.
- Requested runtime-permission grants.
- Optional fresh reinstalls.
- Automatic staging under `/data/local/tmp`.
- Staged byte-count validation.
- Automatic cleanup after success, failure, or interruption.
- Non-root operation through Shizuku.
- Defensive zip-slip path and symlink checks.

## Shell verification

The script verifies `rish` identity with:

```bash
rish -c 'printf "__ADV_INSTALL_UID__=%s\n" "$(id -u)"'
```

The expected UID is:

```text
2000
```

## Why staging is required

A direct command may fail:

```bash
rish -c 'pm install "/storage/emulated/0/Download/application.apk"'
```

The Package Manager may be unable to read files directly from shared storage. `adv-install` works around this by streaming the APK into `/data/local/tmp`, validating the staged byte count, installing from there, and then cleaning up.

## Default Package Manager flags

The default install flags are:

- `-r`: request replacement of an existing package.
- `-d`: request permission to install a lower version code.
- `-g`: request eligible runtime permissions.
