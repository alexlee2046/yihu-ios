#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_SWIFT="$REPO_ROOT/tools/mac_hotspot_ble_daemon.swift"

APP_DIR="$HOME/Applications/YihuHotspotBLE.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
BINARY_PATH="$MACOS_DIR/YihuHotspotBLE"
PLIST_INFO="$CONTENTS_DIR/Info.plist"

LAUNCH_AGENT_LABEL="com.alex.yihu-hotspot-ble"
LAUNCH_AGENT_PLIST="$HOME/Library/LaunchAgents/${LAUNCH_AGENT_LABEL}.plist"
LOG_PATH="$HOME/Library/Logs/yihu-hotspot-ble.log"

mkdir -p "$MACOS_DIR" "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"

# Unload any existing LaunchAgent and stop old binary before replacing bundle contents.
launchctl bootout "gui/$(id -u)/${LAUNCH_AGENT_LABEL}" 2>/dev/null || true
pkill -x YihuHotspotBLE 2>/dev/null || true

echo "[install] Compiling mac_hotspot_ble_daemon.swift -> $BINARY_PATH"
swiftc -O "$SOURCE_SWIFT" -o "$BINARY_PATH"

cat > "$PLIST_INFO" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.qm.agent.collie.mac-ble-hotspot</string>
    <key>CFBundleName</key>
    <string>YihuHotspotBLE</string>
    <key>CFBundleDisplayName</key>
    <string>一呼蓝牙热点守护</string>
    <key>CFBundleExecutable</key>
    <string>YihuHotspotBLE</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>0.1.1</string>
    <key>CFBundleVersion</key>
    <string>6</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>用于接收一呼 iOS 端的蓝牙热点唤醒指令，自动连接手机个人热点。</string>
</dict>
</plist>
EOF

SIGN_IDENTITY="Developer ID Application: Guangdong Mifeng Intelligent Technology Co., Ltd. (PM6M3M34BA)"
if security find-identity -v -p codesigning | grep -Fq "$SIGN_IDENTITY"; then
    echo "[install] Codesigning $APP_DIR with '$SIGN_IDENTITY'"
    codesign --force --deep --sign "$SIGN_IDENTITY" --timestamp=none "$APP_DIR"
else
    echo "[install] Developer ID identity not found; using ad-hoc signature"
    codesign --force --deep --sign - "$APP_DIR"
fi

cat > "$LAUNCH_AGENT_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${LAUNCH_AGENT_LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/open</string>
        <string>-g</string>
        <string>-W</string>
        <string>${APP_DIR}</string>
        <string>--args</string>
        <string>--log</string>
        <string>${LOG_PATH}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>ProcessType</key>
    <string>Interactive</string>
</dict>
</plist>
EOF
chmod 644 "$LAUNCH_AGENT_PLIST"

launchctl bootstrap "gui/$(id -u)" "$LAUNCH_AGENT_PLIST"
echo "[install] Bootstrapped LaunchAgent ${LAUNCH_AGENT_LABEL}"
