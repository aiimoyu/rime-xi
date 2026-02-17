#!/bin/bash
set -e

REPO="aiimoyu/rime-xi"
BRANCH="main"
RAW_URL="https://raw.githubusercontent.com/$REPO/$BRANCH"

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

mkdir -p "$TARGET_DIR"

files="default.yaml squirrel.yaml weasel.yaml ibus_rime.yaml double_pinyin_flypy.schema.yaml melt_eng.schema.yaml symbols.yaml hot_keys.yaml terra_symbols.yaml stroke.schema.yaml t9.schema.yaml terra_pinyin.schema.yaml radical_pinyin.schema.yaml wubi86_jidian.schema.yaml wubi98_mint.schema.yaml rime_mint.schema.yaml rime_mint_flypy.schema.yaml double_pinyin.schema.yaml"

for file in $files; do
    if [[ "$file" == "installation.yaml" ]] || [[ "$file" == *.custom.yaml ]]; then
        continue
    fi
    echo "Downloading $file..."
    if curl -L -o "$TARGET_DIR/$file" "$RAW_URL/oh-my-rime/$file"; then
        echo "  ✓ $file"
    else
        echo "  ✗ $file (failed)"
    fi
done

echo "Redeploying Rime..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Manual redeploy: Right-click Squirrel tray icon → 重新部署"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    echo "Manual redeploy: Right-click Weasel tray icon → 重新部署"
else
    ibus restart 2>/dev/null || echo "Manual redeploy needed"
fi

echo "Update complete."
