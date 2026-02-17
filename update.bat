@echo off
setlocal

set REPO=aiimoyu/rime-xi
set BRANCH=main
set RAW_URL=https://raw.githubusercontent.com/%REPO%/%BRANCH%

if "%~1"=="" (
    set TARGET_DIR=%APPDATA%\Rime
) else (
    set TARGET_DIR=%~1
)

echo Target directory: %TARGET_DIR%
mkdir "%TARGET_DIR%" 2>nul

:: Download file list
set FILES=default.yaml squirrel.yaml weasel.yaml ibus_rime.yaml double_pinyin_flypy.schema.yaml melt_eng.schema.yaml symbols.yaml hot_keys.yaml terra_symbols.yaml stroke.schema.yaml t9.schema.yaml terra_pinyin.schema.yaml radical_pinyin.schema.yaml wubi86_jidian.schema.yaml wubi98_mint.schema.yaml rime_mint.schema.yaml rime_mint_flypy.schema.yaml double_pinyin.schema.yaml

for %%f in (%FILES%) do (
    echo Downloading %%f...
    powershell -Command "Invoke-WebRequest -Uri '%RAW_URL%/oh-my-rime/%%f' -OutFile '%TARGET_DIR%\%%f'"
)

echo Redeploying Rime...
echo Manual redeploy: Right-click Weasel tray icon → 重新部署

echo Update complete.