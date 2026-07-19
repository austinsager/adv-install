#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"

cleanup() {
  echo "== Cleaning up local test sandbox =="
  rm -rf "$TMP"
}
trap cleanup EXIT

export PREFIX="$TMP/prefix"
export TMPDIR="$TMP/tmp"
mkdir -p "$PREFIX/bin" "$TMPDIR"

export FAKE_DATA_LOCAL_TMP="$TMP/fake_data_local_tmp"
mkdir -p "$FAKE_DATA_LOCAL_TMP"

export FAKE_PM_DIR="$TMP/fake-bin"
mkdir -p "$FAKE_PM_DIR"

cat > "$PREFIX/bin/rish" <<'RISH'
#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" != "-c" ]; then
  echo "fake rish supports only -c" >&2
  exit 2
fi

shift
cmd="$1"

if [[ "$cmd" == *'__ADV_INSTALL_UID__'* ]]; then
  printf '__ADV_INSTALL_UID__=2000\n'
  exit 0
fi

: "${FAKE_DATA_LOCAL_TMP:?FAKE_DATA_LOCAL_TMP is required}"

cmd="${cmd//\/data\/local\/tmp/$FAKE_DATA_LOCAL_TMP}"

PATH="${FAKE_PM_DIR:-}:$PATH" bash -c "$cmd"
RISH

chmod +x "$PREFIX/bin/rish"

cat > "$FAKE_PM_DIR/pm" <<'PM'
#!/usr/bin/env bash
set -euo pipefail

printf 'pm %s\n' "$*" >> "${PM_LOG:?PM_LOG is required}"

case "${1:-}" in
  install|install-multiple)
    if [ -f "${FORCE_PM_FAILURE:-}" ]; then
      echo "Failure: Mock Package Manager simulated crash." >&2
      exit 1
    fi
    echo "Success"
    ;;

  list)
    :
    ;;

  uninstall)
    echo "Success"
    ;;

  *)
    echo "unsupported pm command: $*" >&2
    exit 2
    ;;
esac
PM

chmod +x "$FAKE_PM_DIR/pm"

export PATH="$PREFIX/bin:$PATH"
export PM_LOG="$TMP/pm.log"
export FORCE_PM_FAILURE="$TMP/force_failure.flag"

printf 'fake apk bytes' > "$TMP/app target.apk"

echo "== Syntax check =="
bash -n "$ROOT/adv-install"

echo "== Help output validation =="
help_output="$(bash "$ROOT/adv-install" --help)"
[[ "$help_output" == *'Usage:'* ]]

echo "== Single APK install workflow =="
: > "$PM_LOG"
bash "$ROOT/adv-install" "$TMP/app target.apk" > "$TMP/single.out"
grep -q 'Installing single APK' "$TMP/single.out"
grep -q 'pm install -r -d -g' "$PM_LOG"

echo "== Flag suppression verification =="
: > "$PM_LOG"
bash "$ROOT/adv-install" --no-grant --no-downgrade "$TMP/app target.apk" > "$TMP/no-flags.out"
grep -q 'pm install -r ' "$PM_LOG"
if grep -q -- ' -d ' "$PM_LOG"; then exit 1; fi
if grep -q -- ' -g ' "$PM_LOG"; then exit 1; fi

echo "== Directory split execution flow =="
mkdir -p "$TMP/splits"
printf base > "$TMP/splits/base.apk"
printf config > "$TMP/splits/config.apk"

: > "$PM_LOG"
bash "$ROOT/adv-install" "$TMP/splits" > "$TMP/splits.out"
grep -q 'Installing 2 APK split' "$TMP/splits.out"
grep -q 'pm install-multiple -r -d -g' "$PM_LOG"

echo "== Fresh reinstall when package is absent =="
: > "$PM_LOG"
bash "$ROOT/adv-install" --fresh --package com.example.app "$TMP/app target.apk" > "$TMP/fresh.out"
grep -q 'Fresh install requested; com.example.app is not installed' "$TMP/fresh.out"
grep -q 'pm list packages --user current com.example.app' "$PM_LOG"
grep -q 'pm install -r -d -g' "$PM_LOG"

echo "== Catastrophic failure cleanup handling =="
touch "$FORCE_PM_FAILURE"

if bash "$ROOT/adv-install" "$TMP/app target.apk" > "$TMP/fail_test.out" 2>&1; then
  echo "ERROR: The script indicated success even though Package Manager failed." >&2
  exit 1
fi

remaining_remotes="$(find "$FAKE_DATA_LOCAL_TMP" -mindepth 1 -maxdepth 1 -print)"
if [ -n "$remaining_remotes" ]; then
  echo "ERROR: Temporary remote staging directories were abandoned after failure." >&2
  echo "$remaining_remotes" >&2
  exit 1
fi

echo "All tests passed successfully."
