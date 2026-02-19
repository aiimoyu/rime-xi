@echo off
setlocal

set REPO=aiimoyu/rime-xi
set BRANCH=main
set ZIP_URL=https://github.com/%REPO%/archive/refs/heads/%BRANCH%.zip

:: 检测目标目录
if "%~1"=="" (
    set TARGET_DIR=%APPDATA%\Rime
) else (
    set TARGET_DIR=%~1
)

echo Target directory: %TARGET_DIR%
echo Downloading from: %ZIP_URL%

:: 创建临时目录
set TMP_DIR=%TEMP%\rime-update-%RANDOM%
mkdir "%TMP_DIR%"

:: 下载 zip
echo Downloading...
powershell -Command "Invoke-WebRequest -Uri '%ZIP_URL%' -OutFile '%TMP_DIR%\rime.zip'"

:: 解压
echo Extracting...
powershell -Command "Expand-Archive -Path '%TMP_DIR%\rime.zip' -DestinationPath '%TMP_DIR%' -Force"

:: 复制文件
echo Copying files...
powershell -Command "Copy-Item -Path '%TMP_DIR%\rime-xi-%BRANCH%\oh-my-rime\*' -Destination '%TARGET_DIR%' -Recurse -Force"

:: 清理临时目录
rmdir /s /q "%TMP_DIR%"

echo Redeploying Rime...
echo Manual redeploy: Right-click Weasel tray icon → 重新部署

echo ✓ Update complete.
