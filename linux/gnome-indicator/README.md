# CodexBar GNOME / Ubuntu indicator

A lightweight tray indicator that shows CodexBar usage in the desktop top bar on
Linux. It is a thin front-end over the native `codexbar` CLI — it periodically
runs `codexbar usage --format json` for your enabled providers and renders the
result as an [Ayatana AppIndicator](https://github.com/AyatanaIndicators).

Because it speaks the AppIndicator (StatusNotifier) protocol, it works on
GNOME/Ubuntu, Unity, KDE Plasma, XFCE, MATE and Cinnamon. On stock GNOME Shell
(especially Wayland) you need the
[AppIndicator/KStatusNotifier Support](https://extensions.gnome.org/extension/615/appindicator-support/)
extension for the icon to appear.

The menu shows, per provider, the session/weekly/monthly windows remaining, reset
times, credits, plan/login, and account — and the top-bar label shows a compact
summary such as `Ox88/97 Cl100/100` (provider prefix + primary/secondary percent
remaining; `!` marks an error, `$N` shows remaining credits).

## Requirements

- The **`codexbar` CLI** on your `PATH`. Install it the same way as any other
  Linux CodexBar CLI — via Homebrew, the AUR package `codexbar-cli`, or a
  `CodexBarCLI-*-linux-*.tar.gz` release tarball (see the repo README's
  "CLI Tarballs" section). Alternatively, set `CODEXBAR_CLI` to its full path.
- **GTK 3 + Ayatana AppIndicator** Python bindings. On Debian/Ubuntu:

  ```bash
  sudo apt install python3-gi gir1.2-gtk-3.0 gir1.2-ayatanaappindicator3-0.1
  ```

## Install

```bash
./install.sh
```

This installs a launcher to `~/.local/bin/codexbar-indicator`, registers an
autostart entry so it comes back on login, and starts it for the current session
(via `systemd-run --user` when available). Logs go to
`~/.cache/codexbar-indicator/indicator.log`.

## Run manually

```bash
./codexbar-indicator          # run in the foreground
./codexbar-indicator --once   # fetch once, print the label + menu text, exit
```

`--once` is handy for scripting and for checking that the CLI wiring works.

## Configuration

The indicator honors the providers you enabled in the CodexBar app
(`~/.codexbar/config.json`). Environment variables override the defaults:

| Variable | Default | Purpose |
| --- | --- | --- |
| `CODEXBAR_CLI` | auto (`codexbar`, then `CodexBarCLI`, on `PATH`) | Path to the CodexBar CLI binary. |
| `CODEXBAR_INDICATOR_PROVIDERS` | enabled providers, else `codex,claude` | Comma-separated provider ids to show. |
| `CODEXBAR_REFRESH_INTERVAL_SEC` | `120` | Seconds between refreshes. |
| `CODEXBAR_FETCH_TIMEOUT_SEC` | `120` | Per-provider CLI timeout. |

Example:

```bash
CODEXBAR_INDICATOR_PROVIDERS=codex,claude CODEXBAR_REFRESH_INTERVAL_SEC=300 ./codexbar-indicator
```

## Uninstall

```bash
systemctl --user stop codexbar-indicator-live.service 2>/dev/null || true
rm -f ~/.local/bin/codexbar-indicator \
      ~/.config/autostart/codexbar-indicator.desktop \
      ~/.local/share/applications/codexbar-indicator.desktop
```
