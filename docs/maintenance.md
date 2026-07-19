# Maintenance

## Updating adv-install on-device

Back up the current installed script:

```bash
cp -f "$PREFIX/bin/adv-install" "$PREFIX/bin/adv-install.backup"
```

Install the updated repository file:

```bash
install -m 755 adv-install "$PREFIX/bin/adv-install"
hash -r
```

## Restore a backup

```bash
cp -f "$PREFIX/bin/adv-install.backup" "$PREFIX/bin/adv-install"
chmod 755 "$PREFIX/bin/adv-install"
hash -r
```

## Remove adv-install

```bash
rm -f "$PREFIX/bin/adv-install"
hash -r
```

## Repository setup

```bash
mkdir -p "$HOME/adv-install"
cd "$HOME/adv-install"
git init
git branch -M main
```

## Local validation

```bash
bash -n adv-install
bash tests/run-tests.sh
```

If ShellCheck is installed:

```bash
shellcheck adv-install
```

## Release checklist

1. Run local tests.
2. Run a real-device install test.
3. Update documentation if behavior changed.
4. Update `CHANGELOG.md`.
5. Tag a release.
6. Attach `adv-install` and checksum files to the GitHub release.
