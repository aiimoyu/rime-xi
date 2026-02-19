#!/bin/bash
set -e

REPO="aiimoyu/rime-xi"
BRANCH="main"
ZIP_URL="https://github.com/$REPO/archive/refs/heads/$BRANCH.zip"

# 检测平台
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    TARGET_DIR="${APPDATA}/Rime"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    TARGET_DIR="$HOME/Library/Rime"
else
    TARGET_DIR="$HOME/.config/ibus/rime"
fi

if [ -n "$1" ]; then
    TARGET_DIR="$1"
fi

echo "Target directory: $TARGET_DIR"
echo "Downloading from: $ZIP_URL"

# 创建临时目录
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

# 下载并解压
echo "Downloading..."
curl -sL -o "$TMP_DIR/rime.zip" "$ZIP_URL"

echo "Extracting..."
unzip -q "$TMP_DIR/rime.zip" -d "$TMP_DIR"

# 复制 oh-my-rime 目录内容到目标目录
echo "Copying files..."
cp -r "$TMP_DIR/rime-xi-$BRANCH/oh-my-rime/"* "$TARGET_DIR/"

echo "Redeploying Rime..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Manual redeploy: Right-click Squirrel tray icon → 重新部署"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    echo "Manual redeploy: Right-click Weasel tray icon → 重新部署"
else
    ibus restart 2>/dev/null || echo "Manual redeploy needed"
fi

echo "✓ Update complete."
