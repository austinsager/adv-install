# Installation

## Requirements

Before setup, confirm:

- Android device.
- Termux installed.
- Shizuku installed and running.
- Shizuku-exported `rish` and `rish_shizuku.dex`.
- Android Developer options with Wireless debugging enabled.
- Termux storage access granted with `termux-setup-storage`.

## 1. Install Termux

Obtain Termux from official Termux sources.

## 2. Install Shizuku

Obtain Shizuku from the official Shizuku website.

## 3. Enable Developer options

Open Android settings, navigate to software information, tap **Build number** seven times, and authorize with the device lock method.

Then enable:

- USB debugging.
- Wireless debugging.

## 4. Start Shizuku

Open Shizuku, select **Start via Wireless debugging**, pair Shizuku using the Android wireless debugging pairing code, and start the local Shizuku service.

## 5. Export rish

Inside Shizuku:

1. Open **Use Shizuku in terminal apps**.
2. Select **Export files**.
3. Save `rish` and `rish_shizuku.dex` somewhere under shared storage, such as `Download/Shizuku`.

## 6. Prepare Termux

Run:

```bash
pkg update -y && pkg upgrade -y
pkg install -y coreutils grep sed findutils unzip file
termux-setup-storage
```

Optional testing package:

```bash
pkg install -y shellcheck
```

## 7. Install and test rish

Run this in Termux:

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

Also verify the exact marker used by `adv-install`:

```bash
rish -c 'printf "__ADV_INSTALL_UID__=%s\n" "$(id -u)"'
```

Expected output:

```text
__ADV_INSTALL_UID__=2000
```

## 8. Install adv-install

From a cloned repository:

```bash
install -m 755 adv-install "$PREFIX/bin/adv-install"
hash -r
```

Verify:

```bash
command -v adv-install
adv-install --help
```

## 9. Syntax check

```bash
bash -n "$PREFIX/bin/adv-install"
```

If ShellCheck is installed:

```bash
shellcheck "$PREFIX/bin/adv-install"
```
