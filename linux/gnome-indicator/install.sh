#!/usr/bin/env bash
set -euo pipefail

# Installs the CodexBar GNOME/Ubuntu indicator as a per-user autostart app and
# launches it immediately for the current session.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INDICATOR="${SCRIPT_DIR}/codexbar-indicator"
ICON_PATH="${SCRIPT_DIR}/codexbar-icon.png"
LAUNCHER_PATH="${HOME}/.local/bin/codexbar-indicator"
AUTOSTART_PATH="${HOME}/.config/autostart/codexbar-indicator.desktop"
APPLICATION_PATH="${HOME}/.local/share/applications/codexbar-indicator.desktop"
CACHE_DIR="${HOME}/.cache/codexbar-indicator"

if ! command -v codexbar >/dev/null 2>&1 \
  && ! command -v CodexBarCLI >/dev/null 2>&1 \
  && [[ -z "${CODEXBAR_CLI:-}" ]]; then
  echo "warning: CodexBar CLI not found on PATH." >&2
  echo "         Install it (Homebrew, the AUR package 'codexbar-cli', or a" >&2
  echo "         CodexBarCLI-*-linux-*.tar.gz release tarball) or set CODEXBAR_CLI" >&2
  echo "         to its full path before the indicator can show usage." >&2
fi

mkdir -p "${HOME}/.local/bin" "${HOME}/.config/autostart" "${HOME}/.local/share/applications" "${CACHE_DIR}"

cat > "${LAUNCHER_PATH}" <<EOF
#!/usr/bin/env bash
set -euo pipefail
exec "${INDICATOR}" >>"${CACHE_DIR}/indicator.log" 2>&1
EOF
chmod +x "${LAUNCHER_PATH}"

cat > "${AUTOSTART_PATH}" <<EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=CodexBar Indicator
Comment=Show CodexBar usage in the desktop top bar
Exec=${LAUNCHER_PATH}
Icon=${ICON_PATH}
Terminal=false
StartupNotify=false
X-GNOME-Autostart-enabled=true
EOF

cp "${AUTOSTART_PATH}" "${APPLICATION_PATH}"

pkill -f "${INDICATOR}" 2>/dev/null || true
systemctl --user stop codexbar-indicator-live.service 2>/dev/null || true

# Forward the display/session and CodexBar config variables to the live process.
env_args=()
for name in \
  HOME PATH DISPLAY DBUS_SESSION_BUS_ADDRESS XAUTHORITY XDG_RUNTIME_DIR \
  XDG_CURRENT_DESKTOP XDG_SESSION_TYPE WAYLAND_DISPLAY \
  CODEXBAR_CLI CODEXBAR_INDICATOR_PROVIDERS CODEXBAR_REFRESH_INTERVAL_SEC CODEXBAR_FETCH_TIMEOUT_SEC; do
  value="${!name-}"
  if [[ -n "${value}" ]]; then
    env_args+=(--setenv="${name}=${value}")
  fi
done

if command -v systemd-run >/dev/null 2>&1; then
  systemd-run --user --unit=codexbar-indicator-live --collect "${env_args[@]}" "${INDICATOR}" >/dev/null
else
  gtk-launch codexbar-indicator >/dev/null 2>&1 || true
fi

echo "Installed launcher:  ${LAUNCHER_PATH}"
echo "Installed autostart: ${AUTOSTART_PATH}"
