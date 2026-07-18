# adv-install

`adv-install` is a non-root Termux + Shizuku shell workflow for installing locally stored APK files. It runs Android Package Manager through `rish` as `uid=2000(shell)`, stages files under `/data/local/tmp`, validates staged byte counts, installs, and cleans up temporary files.

## Quick start

1. Install Termux and Shizuku on your Android device.
2. In Shizuku, start wireless debugging and export `rish` + `rish_shizuku.dex`.
3. In Termux, run the setup steps in [First-time installation](#first-time-installation).
4. Install `adv-install` using the script block in [8. Install adv-install](#8-install-adv-install).
5. Install a local APK:

```bash
adv-install "/storage/emulated/0/Download/application.apk"
```

> [!IMPORTANT]
> Google documents a Developer Verification exception for Android Debug Bridge (ADB) installs. Google does not explicitly name Shizuku, `rish`, Termux, or `adv-install`. This project is designed to use the same Android shell identity as ADB, but future Android or manufacturer changes could classify this workflow differently.

---

## Table of contents

- [Quick start](#quick-start)
- [Primary purpose](#primary-purpose)
- [Developer Verification scope](#developer-verification-scope)
- [What adv-install is designed to avoid](#what-adv-install-is-designed-to-avoid)
- [What adv-install does not bypass](#what-adv-install-does-not-bypass)
- [Installation, not downloading](#installation-not-downloading)
- [Features](#features)
- [Technical overview](#technical-overview)
- [Why staging is required](#why-staging-is-required)
- [Default Package Manager flags](#default-package-manager-flags)
- [Requirements](#requirements)
- [First-time installation](#first-time-installation)
  - [1. Install Termux](#1-install-termux)
  - [2. Install Shizuku](#2-install-shizuku)
  - [3. Enable Developer options](#3-enable-developer-options)
  - [4. Start Shizuku](#4-start-shizuku)
  - [5. Export rish](#5-export-rish)
  - [6. Prepare Termux](#6-prepare-termux)
  - [7. Install and test rish](#7-install-and-test-rish)
  - [8. Install adv-install](#8-install-adv-install)
  - [9. Verify the installation](#9-verify-the-installation)
- [Usage](#usage)
- [Supported input types](#supported-input-types)
- [Options](#options)
- [Examples](#examples)
- [Fresh reinstall](#fresh-reinstall)
- [Paths containing spaces](#paths-containing-spaces)
- [Expected output](#expected-output)
- [Archive behavior](#archive-behavior)
- [Security considerations](#security-considerations)
- [Verify an APK hash](#verify-an-apk-hash)
- [Troubleshooting](#troubleshooting)
- [Updating adv-install](#updating-adv-install)
- [Restore a backup](#restore-a-backup)
- [Removing adv-install](#removing-adv-install)
- [Repository setup](#repository-setup)
- [Frequently asked questions](#frequently-asked-questions)
- [Policy and project limitations](#policy-and-project-limitations)
- [Responsible use](#responsible-use)
- [Official references](#official-references)
- [License](#license)
- [Disclaimer](#disclaimer)

---

## Primary purpose

`adv-install` is a shell-oriented installer for locally stored APK files on non-rooted Android devices.

It combines:
* **Termux** for the local command-line environment
* **Shizuku** for access to Android's shell service
* **`rish`** for forwarding commands from Termux to Shizuku-backed shell execution
* **Android Package Manager** for the final installation

Common use cases include:
* Installing private development builds
* Installing open-source applications outside a participating application store
* Installing archived or discontinued applications
* Installing internal test builds
* Installing modified applications on an authorized test device
* Compatibility testing
* Security research
* Application preservation
* Personally controlled device management

---

## Developer Verification scope

Google's documentation states that ADB installs remain available without Developer Verification, primarily for development and testing workflows.

`adv-install` is built around that shell route. It verifies `rish` is running as `uid=2000(shell)` and then executes `pm` commands through that identity instead of the normal graphical Package Installer flow.

Important caveat: Google does not explicitly guarantee that Shizuku/`rish`-based workflows will always be treated exactly like direct ADB usage in future releases.

---

## What adv-install is designed to avoid

When Android treats the operation as an exempt shell install, this workflow is intended to avoid Developer Verification enrollment steps and the consumer advanced flow.

| Requirement or process | Intended result |
| :--- | :--- |
| Developer identity verification | Not required for the exempt shell installation |
| Developer Verification console enrollment | Not required for the exempt shell installation |
| Developer Verification package registration | Not required for the exempt shell installation |
| Consumer advanced flow activation | Not used |
| Advanced flow waiting period | Not used |
| Advanced flow restart and reauthentication | Not used |
| Repeated graphical Package Installer interaction | Not used |
| Root access | Not required |
| USB-connected computer for each installation | Not required after Shizuku setup |

Behavior remains dependent on Android, Package Manager, Google Play services, Shizuku, and device-manufacturer implementation.

---

## What adv-install does not bypass

`adv-install` changes the installation route. It does not disable Android's ordinary package-security model.

The script does not bypass:
* APK signature validation
* APK structural validation
* Package parsing
* Package-name validation
* Update signing-certificate matching
* Version-code enforcement
* CPU architecture requirements
* Minimum SDK requirements
* Split-package dependency requirements
* Device-owner policy
* Work-profile policy
* Enterprise-management restrictions
* Android user restrictions
* SELinux enforcement
* Package Manager security checks
* Play Protect scanning or detection
* Signature-level permission restrictions
* Privileged permission restrictions
* Manufacturer-specific installation restrictions
* Application integrity checks performed after installation
* Play Integrity API checks
* Application licensing checks
* Server-side authentication
* Account requirements imposed by an application

An APK that is invalid, incompatible, corrupt, incomplete, incorrectly signed, or blocked by policy can still fail.

---

## Installation, not downloading

`adv-install` does not download APK files. The APK must already exist on the device, for example under `/storage/emulated/0/Download/application.apk`.

The file may have been obtained through:
* A trusted developer website
* A source-code release page
* A local build process
* An authorized file transfer
* A private repository
* Another lawful distribution method

`adv-install` begins after the file has been saved locally. The project is not an APK store, downloader, or malware scanner.

---

## Features

`adv-install` supports:
* Single `.apk` files
* `.apks`, `.xapk`, and `.zip` archives containing APK files
* Directories containing split APK files
* Filenames containing spaces
* Quoted paths beginning with `~/`
* Replacement installations
* Requested version downgrades
* Requested runtime-permission grants
* Optional fresh reinstalls
* Automatic staging under `/data/local/tmp`
* Staged byte-count validation
* Automatic cleanup after success, failure, or interruption
* Non-root operation through Shizuku
* Defensive zip-slip path and symlink checks

---

## Technical overview

For a single APK, the process is:

```text
APK in shared storage
        |
        | Termux opens the source file
        v
Standard-input byte stream
        |
        | rish receives the bytes as UID 2000(shell)
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

### Command parsing
The script accepts one input path, optional installation flags, and an optional package ID when `--fresh` is used. It handles flags defensively using an options end-marker (`--`) and stops processing unknown arguments.

### Shell verification
The script runs a structured, isolated string token test through `rish`:
```bash
rish -c 'printf "__ADV_INSTALL_UID__=%s\n" "$(id -u)"' 2>&1
```
The resulting stream is processed to remove standard legacy carriage returns (`tr -d '\r'`) and evaluated against the expected value of `2000`. The script terminates cleanly using a dedicated logging function if the identity validation fails.

### Literal tilde handling
A quoted path does not receive normal shell tilde expansion. The script detects a literal `~/` prefix and manually expands it to the full local environment home variable:
```bash
case "$INPUT" in
  \~/*)
    INPUT="$HOME/${INPUT#\~/}"
    ;;
esac
```

### Local temporary directory
The script establishes explicit path resolution anchors targeting Termux prefix environments:
```bash
TERMUX_PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
LOCAL_TMP_BASE="${TMPDIR:-$TERMUX_PREFIX/tmp}"
mkdir -p -- "$LOCAL_TMP_BASE"
LOCAL_WORK="$(mktemp -d "$LOCAL_TMP_BASE/adv-install.XXXXXX")"
```

### Remote staging directory
Each run creates a unique remote directory under `/data/local/tmp/` whose name incorporates the active Termux process ID and a UNIX epoch timestamp.

### File streaming
The source file bytes are read by Termux and securely written to the target path through `rish` using an absolute file identifier constraint:
```bash
cat -- "$src" | rish -c "cat > $(quote_remote "$dst") && chmod 0644 $(quote_remote "$dst")"
```

### Byte-count verification
The local file size is checked using `wc -c`. The remote shell measures the written bytes inside a `__ADV_INSTALL_SIZE__` output block. The sizes are extracted and parsed via `sed` to verify transmission integrity, blocking execution if a size mismatch occurs.

### Package installation
Installer arguments are assembled through a shell array and passed to `pm install` or `pm install-multiple` inside Shizuku-hosted shell execution.

### Cleanup
The script traps standard lifecycle exit points:
```bash
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
```
This ensures that the remote directories and local workspace paths are entirely deleted regardless of installation success or manual process termination.

---

## Why staging is required

A direct command may appear sufficient:
```bash
rish -c 'pm install "/storage/emulated/0/Download/application.apk"'
```

On modern Android devices, that command may fail with:
```text
System server has no access to read file context u:object_r:fuse:s0
Error: Unable to open file: /storage/emulated/0/Download/application.apk
Consider using a file under /data/local/tmp/
```

The failure is caused by the shared-storage location and its FUSE-backed SELinux context (`u:object_r:fuse:s0`), which prevents Android system services from reading the file directly. `adv-install` handles this by parsing the stream locally, pushing it under `/data/local/tmp`, and dropping tracking footprints after execution is completed.

---

## Default Package Manager flags

The script uses an array initialization pattern containing the elements `-r`, `-d`, and `-g` by default.

| Flag | Purpose |
| :--- | :--- |
| `-r` | Requests replacement of an existing package while retaining data when Android permits |
| `-d` | Requests permission to install a lower version code |
| `-g` | Requests grants for eligible runtime permissions declared by the package |

---

## Requirements

Before setup, confirm:
* Android device (Android 11+ recommended for wireless debugging flow)
* Termux installed
* Shizuku installed and running
* Shizuku-exported `rish` and `rish_shizuku.dex`
* Android Developer options with Wireless debugging enabled
* Termux storage access granted (`termux-setup-storage`)

---

## First-time installation

### 1. Install Termux
Obtain Termux from official sources such as F-Droid or the official Termux GitHub repository.

### 2. Install Shizuku
Obtain Shizuku from the official website.

### 3. Enable Developer options
Navigate to your Android Software Information settings, tap **Build number** seven times, and authorize your lock-screen PIN. Once active, enable **USB debugging** and **Wireless debugging** inside Developer options.

### 4. Start Shizuku
Open Shizuku, select **Start via Wireless debugging**, pair the application using the pairing code provided by your Android system configuration menu, and start the local Shizuku service.

### 5. Export rish
Inside Shizuku, open **Use Shizuku in terminal apps**, select **Export files**, and save them to a directory in your shared storage (e.g., `Download/Shizuku`).

### 6. Prepare Termux
Open Termux and sync the core workspace packaging files:
```bash
pkg update -y && pkg upgrade -y && pkg install -y coreutils grep sed findutils unzip file
termux-setup-storage
```

### 7. Install and test rish
Execute the following automated installation block inside Termux to link your exported terminal files:
```bash
RISH_SOURCE="$(find "$HOME/storage/downloads" -type f -name 'rish' -print -quit)"
DEX_SOURCE="$(find "$HOME/storage/downloads" -type f -name 'rish_shizuku.dex' -print -quit)"

[ -n "$RISH_SOURCE" ] || {
  echo "ERROR: The exported rish file was not found under Downloads." >&2
  exit 1
}

[ -n "$DEX_SOURCE" ] || {
  echo "ERROR: The exported rish_shizuku.dex file was not found under Downloads." >&2
  exit 1
}

mkdir -p "$PREFIX/bin"

cp -f "$RISH_SOURCE" "$PREFIX/bin/rish"
cp -f "$DEX_SOURCE" "$PREFIX/bin/rish_shizuku.dex"

chmod 755 "$PREFIX/bin/rish"
chmod 444 "$PREFIX/bin/rish_shizuku.dex"

grep -qF 'export RISH_APPLICATION_ID="com.termux"' "$HOME/.bashrc" 2>/dev/null || \
  printf '\nexport RISH_APPLICATION_ID="com.termux"\n' >> "$HOME/.bashrc"

export RISH_APPLICATION_ID="com.termux"
hash -r

rish -c 'id -u'
```
Expected output:
```text
2000
```
If you get a different UID or an error, re-check Shizuku startup and the exported `rish` files before continuing.

### 8. Install adv-install
> [!NOTE]
> The `adv-install` script is intentionally duplicated in this README and in the repository file (`adv-install`) to support copy/paste onboarding in Termux.
>
> Maintainers: if script logic changes, update **both copies in the same commit/PR** to keep them synchronized.

The following block creates the complete hardened production script at `/data/data/com.termux/files/usr/bin/adv-install`. Copy and paste the entire block into Termux:
```bash
cat > "$PREFIX/bin/adv-install" <<'SCRIPT'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

GRANT=1
DOWNGRADE=1
FRESH=0
FRESH_DONE=0
PACKAGE_ID=""
INPUT=""

usage() {
  cat <<'USAGE'
Usage:
  adv-install [OPTIONS] INPUT

Inputs:
  application.apk
  application.apks
  application.xapk
  archive.zip
  directory containing APK splits

Options:
  --no-grant             Do not grant requested runtime permissions.
  --no-downgrade         Do not permit a version-code downgrade.
  --fresh                Remove the current-user installation first.
  --package PACKAGE_ID   Package ID required by --fresh.
  --                     End option parsing.
  -h, --help             Show this help text.
USAGE
}

fail() {
  printf '%s\n' "$*" >&2
  exit 1
}

usage_error() {
  printf '%s\n' "$*" >&2
  exit 2
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --no-grant)
      GRANT=0
      ;;
    --no-downgrade)
      DOWNGRADE=0
      ;;
    --fresh)
      FRESH=1
      ;;
    --package)
      shift
      [ "$#" -gt 0 ] || usage_error "Missing package ID after --package."
      PACKAGE_ID="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      [ "$#" -eq 1 ] || usage_error "Exactly one input must follow --."
      [ -z "$INPUT" ] || usage_error "Only one input is accepted."
      INPUT="$1"
      shift
      break
      ;;
    -*)
      usage_error "Unknown option: $1"
      ;;
    *)
      [ -z "$INPUT" ] || usage_error "Only one input is accepted."
      INPUT="$1"
      ;;
  esac
  shift
done

[ -n "$INPUT" ] || {
  usage >&2
  exit 2
}

if [ "$FRESH" -eq 1 ]; then
  [ -n "$PACKAGE_ID" ] || usage_error "--fresh requires --package PACKAGE_ID."

  case "$PACKAGE_ID" in
    *[!A-Za-z0-9._]*|.*|*.|*..*|'')
      usage_error "Invalid package ID: $PACKAGE_ID"
      ;;
  esac
fi

case "$INPUT" in
  \~/*)
    INPUT="$HOME/${INPUT#\~/}"
    ;;
esac

INPUT="$(readlink -f -- "$INPUT" 2>/dev/null || printf '%s' "$INPUT")"

[ -e "$INPUT" ] || fail "Input does not exist: $INPUT"
[ -r "$INPUT" ] || fail "Input is not readable: $INPUT"

export RISH_APPLICATION_ID="${RISH_APPLICATION_ID:-com.termux}"

command -v rish >/dev/null 2>&1 || fail "rish was not found in PATH."

if RISH_CHECK_OUTPUT="$(
  rish -c 'printf "__ADV_INSTALL_UID__=%s\n" "$(id -u)"' 2>&1
)"; then
  RISH_CHECK_STATUS=0
else
  RISH_CHECK_STATUS=$?
fi

RISH_UID="$(
  printf '%s\n' "$RISH_CHECK_OUTPUT" |
    tr -d '\r' |
    sed -n 's/^__ADV_INSTALL_UID__=\([0-9][0-9]*\)$/\1/p' |
    tail -n 1
)"

if [ "$RISH_CHECK_STATUS" -ne 0 ] || [ "$RISH_UID" != "2000" ]; then
  echo "rish is not returning Android shell identity." >&2
  echo "Received UID: ${RISH_UID:-none}; expected 2000." >&2
  [ -z "$RISH_CHECK_OUTPUT" ] || {
    echo "rish output:" >&2
    printf '%s\n' "$RISH_CHECK_OUTPUT" >&2
  }
  exit 1
fi

quote_remote() {
  printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

INSTALL_FLAGS=(-r)
[ "$DOWNGRADE" -eq 1 ] && INSTALL_FLAGS+=(-d)
[ "$GRANT" -eq 1 ] && INSTALL_FLAGS+=(-g)

build_pm_command() {
  local subcommand="$1"
  shift

  local command="pm $subcommand"
  local argument

  for argument in "${INSTALL_FLAGS[@]}" "$@"; do
    command+=" $(quote_remote "$argument")"
  done

  printf '%s' "$command"
}

TERMUX_PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
LOCAL_TMP_BASE="${TMPDIR:-$TERMUX_PREFIX/tmp}"
mkdir -p -- "$LOCAL_TMP_BASE"
LOCAL_WORK="$(mktemp -d "$LOCAL_TMP_BASE/adv-install.XXXXXX")"
REMOTE_WORK="/data/local/tmp/adv_install_${$}_$(date +%s)"

cleanup() {
  local status="$?"
  trap - EXIT INT TERM

  rm -rf -- "$LOCAL_WORK" 2>/dev/null || true
  rish -c "rm -rf $(quote_remote "$REMOTE_WORK")" >/dev/null 2>&1 || true

  exit "$status"
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

prepare_remote() {
  rish -c "
    rm -rf $(quote_remote "$REMOTE_WORK") &&
    mkdir -p $(quote_remote "$REMOTE_WORK") &&
    chmod 0755 $(quote_remote "$REMOTE_WORK")
  "
}

stage_file() {
  local src="$1"
  local dst="$2"
  local expected
  local actual
  local size_output
  local size_status

  [ -f "$src" ] || fail "APK is not a regular file: $src"
  [ -r "$src" ] || fail "APK is not readable: $src"

  echo "Staging:"
  echo "  $src"
  echo "  -> $dst"

  if ! cat -- "$src" | rish -c "
    cat > $(quote_remote "$dst") &&
    chmod 0644 $(quote_remote "$dst")
  "; then
    fail "Failed to stage APK: $src"
  fi

  expected="$(wc -c < "$src" | tr -d '[:space:]')"

  if size_output="$(
    rish -c "
      bytes=\$(wc -c < $(quote_remote "$dst")) || exit 1
      printf '__ADV_INSTALL_SIZE__=%s\\n' \"\$bytes\"
    " 2>&1
  )"; then
    size_status=0
  else
    size_status=$?
  fi

  actual="$(
    printf '%s\n' "$size_output" |
      tr -d '\r' |
      sed -n 's/^__ADV_INSTALL_SIZE__=\([0-9][0-9]*\)$/\1/p' |
      tail -n 1
  )"

  if [ "$size_status" -ne 0 ] || [ "$expected" != "$actual" ]; then
    echo "Staging size mismatch: expected $expected, got ${actual:-unknown}." >&2
    [ -z "$size_output" ] || printf '%s\n' "$size_output" >&2
    exit 1
  fi
}

fresh_uninstall_once() {
  [ "$FRESH" -eq 1 ] || return 0
  [ "$FRESH_DONE" -eq 0 ] || return 0

  FRESH_DONE=1

  local package_list_output
  local package_list_status

  if package_list_output="$(
    rish -c "pm list packages --user current $(quote_remote "$PACKAGE_ID")" 2>&1
  )"; then
    package_list_status=0
  else
    package_list_status=$?
  fi

  if [ "$package_list_status" -ne 0 ]; then
    [ -z "$package_list_output" ] || printf '%s\n' "$package_list_output" >&2
    fail "Unable to determine whether $PACKAGE_ID is installed for the current user."
  fi

  if ! printf '%s\n' "$package_list_output" |
    tr -d '\r' |
    grep -Fxq "package:$PACKAGE_ID"; then
    echo "Fresh install requested; $PACKAGE_ID is not installed for the current user."
    return 0
  fi

  echo "Removing current-user installation: $PACKAGE_ID"
  if ! rish -c "pm uninstall --user current $(quote_remote "$PACKAGE_ID")"; then
    fail "Failed to remove current-user installation: $PACKAGE_ID"
  fi
}

install_single() {
  local src="$1"
  local dst="$REMOTE_WORK/base.apk"
  local command

  prepare_remote
  stage_file "$src" "$dst"
  fresh_uninstall_once

  command="$(build_pm_command install "$dst")"
  echo "Installing single APK..."
  rish -c "$command"
}

install_multiple() {
  local -a sources=("$@")
  local -a remote_paths=()
  local src
  local dst
  local index=0
  local command

  [ "${#sources[@]}" -gt 0 ] || fail "No APK files found."

  prepare_remote

  for src in "${sources[@]}"; do
    dst="$(printf '%s/%04d.apk' "$REMOTE_WORK" "$index")"
    stage_file "$src" "$dst"
    remote_paths+=("$dst")
    index=$((index + 1))
  done

  fresh_uninstall_once
  command="$(build_pm_command install-multiple "${remote_paths[@]}")"
  echo "Installing $index APK split(s)..."
  rish -c "$command"
}

collect_apks() {
  local root="$1"
  local array_name="$2"
  local -n output_array="$array_name"
  local unsorted_list="$LOCAL_WORK/apks.${RANDOM}.$$.unsorted"
  local sorted_list="$LOCAL_WORK/apks.${RANDOM}.$$.sorted"

  if ! find "$root" -type f -iname '*.apk' -print0 > "$unsorted_list"; then
    fail "Failed to search for APK files under: $root"
  fi

  if ! sort -z "$unsorted_list" > "$sorted_list"; then
    fail "Failed to sort APK files found under: $root"
  fi

  mapfile -d '' -t output_array < "$sorted_list"
  rm -f -- "$unsorted_list" "$sorted_list"
}

validate_archive_paths() {
  local archive="$1"
  local entries_file="$LOCAL_WORK/archive.entries"
  local entry

  if ! unzip -Z1 "$archive" > "$entries_file"; then
    fail "Unable to read archive directory: $archive"
  fi

  while IFS= read -r entry || [ -n "$entry" ]; do
    case "$entry" in
      ''|./)
        ;;
      /*|[A-Za-z]:*|..|../*|*/../*|*/..|*\\*)
        fail "Archive contains an unsafe path: $entry"
        ;;
    esac
  done < "$entries_file"
}

reject_extracted_symlinks() {
  local root="$1"
  local symlink_list="$LOCAL_WORK/archive.symlinks"

  if ! find "$root" -type l -print > "$symlink_list"; then
    fail "Failed to inspect extracted archive contents."
  fi

  if [ -s "$symlink_list" ]; then
    echo "Archive contains symbolic links, which are not accepted:" >&2
    sed -n '1,10p' "$symlink_list" >&2
    exit 1
  fi
}

if [ -d "$INPUT" ]; then
  declare -a directory_apks=()
  collect_apks "$INPUT" directory_apks
  install_multiple "${directory_apks[@]}"
  exit 0
fi

LOWER="$(printf '%s' "$INPUT" | tr '[:upper:]' '[:lower:]')"

case "$LOWER" in
  *.apk)
    install_single "$INPUT"
    ;;

  *.apks|*.xapk|*.zip)
    command -v unzip >/dev/null 2>&1 || fail "Install unzip first: pkg install unzip"

    mkdir -p -- "$LOCAL_WORK/extracted"
    validate_archive_paths "$INPUT"

    if ! unzip -q -o "$INPUT" -d "$LOCAL_WORK/extracted"; then
      fail "Failed to extract archive: $INPUT"
    fi

    reject_extracted_symlinks "$LOCAL_WORK/extracted"

    declare -a all_apks=()
    collect_apks "$LOCAL_WORK/extracted" all_apks

    [ "${#all_apks[@]}" -gt 0 ] || fail "No APK files were found in the archive."

    declare -a universal_apks=()
    declare -a standalone_apks=()
    for apk in "${all_apks[@]}"; do
      basename_lower="$(printf '%s' "${apk##*/}" | tr '[:upper:]' '[:lower:]')"
      case "$basename_lower" in
        universal.apk)
          universal_apks+=("$apk")
          ;;
        standalone.apk)
          standalone_apks+=("$apk")
          ;;
      esac
    done

    if [ "${#universal_apks[@]}" -gt 0 ]; then
      install_single "${universal_apks[0]}"
      exit 0
    fi

    if [ "${#standalone_apks[@]}" -gt 0 ]; then
      install_single "${standalone_apks[0]}"
      exit 0
    fi

    declare -a selected_apks=()
    declare -a split_dir_apks=()
    declare -a non_standalone_apks=()

    for apk in "${all_apks[@]}"; do
      relative="/${apk#"$LOCAL_WORK/extracted"/}"
      relative_lower="$(printf '%s' "$relative" | tr '[:upper:]' '[:lower:]')"

      case "$relative_lower" in
        */standalone/*|*/standalones/*)
          ;;
        *)
          non_standalone_apks+=("$apk")
          ;;
      esac

      case "$relative_lower" in
        */splits/*)
          split_dir_apks+=("$apk")
          ;;
      esac
    done

    split_dir_has_base=0
    for apk in "${split_dir_apks[@]}"; do
      basename_lower="$(printf '%s' "${apk##*/}" | tr '[:upper:]' '[:lower:]')"
      case "$basename_lower" in
        base.apk|master.apk|base-master.apk)
          split_dir_has_base=1
          break
          ;;
      esac
    done

    if [ "$split_dir_has_base" -eq 1 ]; then
      selected_apks=("${split_dir_apks[@]}")
    elif [ "${#non_standalone_apks[@]}" -gt 0 ]; then
      selected_apks=("${non_standalone_apks[@]}")
    else
      selected_apks=("${all_apks[@]}")
    fi

    base_index=-1
    for i in "${!selected_apks[@]}"; do
      basename_lower="$(printf '%s' "${selected_apks[$i]##*/}" | tr '[:upper:]' '[:lower:]')"
      case "$basename_lower" in
        base.apk|master.apk|base-master.apk)
          base_index="$i"
          break
          ;;
      esac
    done

    if [ "$base_index" -ge 0 ]; then
      base_apk="${selected_apks[$base_index]}"
      declare -a ordered_apks=("$base_apk")

      for i in "${!selected_apks[@]}"; do
        [ "$i" -eq "$base_index" ] || ordered_apks+=("${selected_apks[$i]}")
      done

      install_multiple "${ordered_apks[@]}"
    else
      install_multiple "${selected_apks[@]}"
    fi
    ;;

  *)
    usage_error "Unsupported input type: $INPUT"
    ;;
esac
SCRIPT

chmod 755 "$PREFIX/bin/adv-install"
hash -r
```

### 9. Verify the installation
Run the tracking checks to verify execution:
```bash
command -v adv-install
bash -n "$PREFIX/bin/adv-install" && echo "Syntax check passed."
shellcheck "$PREFIX/bin/adv-install"
```

---

## Usage

General syntax:
```bash
adv-install [OPTIONS] INPUT
```

---

## Supported input types

### Single APK
```bash
adv-install "/storage/emulated/0/Download/application.apk"
```

### Archives (.apks, .xapk, .zip)
```bash
adv-install "/storage/emulated/0/Download/application.zip"
```

### Directory containing split APK files
```bash
adv-install "/storage/emulated/0/Download/application-splits"
```

---

## Options

| Option | Effect |
| :--- | :--- |
| `--no-grant` | Omits Package Manager's permission grant (-g) flag request |
| `--no-downgrade` | Omits Package Manager's low-version-code downgrade (-d) flag request |
| `--fresh` | Removes the current-user installation before reinstalling |
| `--package PACKAGE_ID` | Package ID used by `--fresh` |
| `--` | Explicit option parsing end marker |
| `-h`, `--help` | Displays usage definition information |

---

## Examples

### Complete Installation Workflow
```bash
adv-install --no-grant "$HOME/storage/downloads/Target.apk"
```

### Prompt-Driven Execution
```bash
read -r -p "Enter the full APK path: " APK_PATH
adv-install "$APK_PATH"
```

---

## Fresh reinstall

A fresh reinstall removes the current user's installed copy before staging and installing the APK.
```bash
adv-install --fresh --package com.example.app "/path/to/application.apk"
```

This triggers:
```text
pm uninstall --user current PACKAGE_ID
```

---

## Paths containing spaces

Wrap paths containing spaces in double quotes:
```bash
adv-install "/storage/emulated/0/Download/My Application Target.apk"
```

---

## Expected output

A successful run looks like:
```text
Staging:
  /storage/emulated/0/Download/application.apk
  -> /data/local/tmp/adv_install_12345_1784290248/base.apk
Installing single APK...
Success
```

---

## Archive behavior

### Universal Preference
If present, `universal.apk` or `standalone.apk` is preferred for single-package install.

### Split Pipeline Order
For split installs, `base.apk`, `master.apk`, or `base-master.apk` is moved to the first install position when found.

### Secure Traversal Protection
Archive handling validates entry paths (`validate_archive_paths`) and rejects extracted symlinks (`reject_extracted_symlinks`) to reduce zip-slip style risks.

---

## Security considerations

* Stage software variants solely from authorized engineering foundations.
* Evaluate deployment checksum parameters via `sha256sum` queries.
* Ensure elevation bridges are closed when execution requirements are met.
* No external backend connections, metrics tracking, or data mutations are executed by this installer.

---

## Verify an APK hash

```bash
sha256sum "/storage/emulated/0/Download/application.apk"
```

---

## Troubleshooting

| Symptom | Likely cause | Fix |
| :--- | :--- | :--- |
| `rish` not found | Exported files were not copied to `$PREFIX/bin` | Re-run step 7 and verify both files exist in `$PREFIX/bin` |
| `rish -c 'id -u'` is not `2000` | Shizuku is not active or not linked to Termux | Restart Shizuku, ensure wireless debugging pairing is active, then rerun step 7 |
| `Unable to open file` under shared storage | APK was not staged in `/data/local/tmp` (usually when bypassing the script flow) | Use `adv-install` directly with the APK path so staging is performed |
| Writable DEX error | `rish_shizuku.dex` is too permissive | `chmod 444 "$PREFIX/bin/rish_shizuku.dex"` |
| No APKs found in archive | Archive does not contain usable `.apk` entries | Extract locally and verify APK contents before reinstalling |

---

## Updating adv-install

```bash
cp -f "$PREFIX/bin/adv-install" "$PREFIX/bin/adv-install.backup"
```

Rerun the execution steps detailed in `8. Install adv-install`.

---

## Restore a backup

```bash
cp -f "$PREFIX/bin/adv-install.backup" "$PREFIX/bin/adv-install"
chmod 755 "$PREFIX/bin/adv-install"
hash -r
```

---

## Removing adv-install

```bash
rm -f "$PREFIX/bin/adv-install"
hash -r
```

---

## Repository setup

```bash
mkdir -p "$HOME/adv-install"
cd "$HOME/adv-install"
git init
git branch -M main
```

---

## Frequently asked questions

### Does adv-install allow APKs from unverified developers to be installed?

That is the project's primary purpose.

The APK must still pass Android's ordinary Package Manager checks.

### Does the developer need to complete Android Developer Verification?

Google documents that ADB installations may proceed without Developer Verification.

`adv-install` is designed to use Android's shell installation route through UID `2000(shell)`.

Google does not specifically guarantee Shizuku or `rish`, so future behavior may depend on Android's classification of that shell operation.

### Does the package need Developer Verification registration?

The documented ADB exception does not require Developer Verification package registration.

The Shizuku-backed implementation remains subject to the qualification described above.

### Does adv-install use the consumer advanced flow?

No. The script invokes Package Manager through the Android shell identity.

### Does adv-install require root?

No.

### Does adv-install require a computer?

A computer is not required for normal use after Shizuku has been configured through wireless debugging on Android 11 or newer.

### Does adv-install download APKs?

No. The APK must already be stored on the device.

### Does adv-install install every APK?

No. Invalid, corrupt, incompatible, incomplete, incorrectly signed, or policy-blocked APKs may still fail.

### Does adv-install disable Play Protect?

No.

### Does adv-install bypass APK signatures?

No.

### Does adv-install bypass update-signature mismatches?

No.

### Does adv-install automatically grant every permission?

No. The default `-g` option requests eligible runtime permissions. Android controls which permissions may be granted.

### Can adv-install install split APKs?

Yes, on a best-effort basis. Complex device-targeted archives may require a specialized installer.

### Will adv-install always work after future Android updates?

No permanent guarantee can be made.

The project depends on:

- Android's continued ADB exception
- Android shell permissions
- Shizuku functionality
- `rish` functionality
- Package Manager behavior
- Google Play services behavior
- Manufacturer implementation

---

## Policy and project limitations

This project depends on current Android shell behavior and published ADB policy language.

ADB exceptions are documented; Shizuku/`rish` equivalency is an implementation assumption and may change in future Android, Google Play services, or OEM builds.

---

## Responsible use

The project is intended for lawful activity on devices controlled by or authorized for the operator, including:

- Application development
- Application testing
- Compatibility testing
- Security research
- Open-source application installation
- Digital preservation
- Internal deployment
- Recovery of discontinued applications
- Authorized testing of modified applications
- Installation of privately distributed software

The project should not be used to:

- Install malicious software
- Modify devices without authorization
- Evade organizational policy on managed devices
- Interfere with another person's device
- Conceal unauthorized software installation

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY ARISING FROM THE USE OF THIS SOFTWARE.

---

## Official references

* Android Developer Verification Documentation: <https://developer.android.com/developer-verification>
* Android 16 QPR2 release notes:
<https://developer.android.com/about/versions/16/qpr2/release-notes>
* Shizuku System Framework: <https://shizuku.rikka.app/>
* Shizuku Setup Guide:
<https://shizuku.rikka.app/guide/setup/>  
* Shizuku Downloads:
<https://shizuku.rikka.app/download/>
* Rish Documentation:
<https://github.com/RikkaApps/Shizuku-API/blob/master/rish/README.md>
* Termux Console Workspace:
<https://github.com/termux/termux-app>

---

## License

Distributed under the MIT License.
See `LICENSE` for more information.

---

## Disclaimer

This project is not affiliated with, endorsed by, or sponsored by Google, Android, Shizuku, RikkaApps, Termux, or their respective maintainers.

Android is a trademark of Google LLC.

The project is provided without a guarantee that future Android releases, Google Play services updates, manufacturer changes, or Developer Verification policy changes will preserve the current behavior.
