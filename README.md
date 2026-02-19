# Rime 输入法配置 - 月轮 + 万象词库

基于 [oh-my-rime](https://github.com/Mintimate/oh-my-rime) 和 [万象 LMDG](https://github.com/amzxyz/RIME-LMDG) 的 Rime 输入法配置。

## 特性

- 🔄 **自动更新**：GitHub Action 每周一 00:00 UTC 自动更新 oh-my-rime 和万象词库
- 🖥️ **多平台支持**：Linux (IBus/Fcitx)、macOS (Squirrel)、Windows (Weasel)
- 🚀 **一键更新**：无需 git，一条命令完成全平台更新
- 📦 **独立配置**：每台电脑的 `installation.yaml` 独立保存，不会被覆盖

## 快速开始

### 方式一：一键更新（推荐）

无需克隆仓库，直接执行更新脚本：

```bash
# Linux / macOS
bash -c "$(curl -fsSL https://raw.githubusercontent.com/aiimoyu/rime-xi/main/update.sh)"

# Windows (PowerShell)
irm https://raw.githubusercontent.com/aiimoyu/rime-xi/main/update.bat | iex
```

脚本会自动检测 Rime 配置目录并下载最新配置。

### 方式二：本地脚本更新

克隆仓库后在本地运行：

```bash
git clone https://github.com/YOUR_USERNAME/rime-xi.git
cd rime-xi
```

```bash
# Linux (IBus)
bash update.sh ~/.config/ibus/rime

# Linux (Fcitx)
bash update.sh ~/.config/fcitx/rime

# macOS (Squirrel)
bash update.sh ~/Library/Rime

# Windows (CMD/PowerShell)
update.bat %APPDATA%\Rime
```

### 重新部署 Rime

更新后需要重新部署 Rime 使配置生效：

- **Linux (IBus)**: `ibus restart` 或重新登录
- **Linux (Fcitx)**: `fcitx5-remote -r` 或重启 Fcitx
- **macOS (Squirrel)**: 右键系统托盘图标 → 重新部署
- **Windows (Weasel)**: 右键系统托盘图标 → 重新部署

## 更新配置

### 本地脚本

```bash
# Linux / macOS
bash update.sh                          # 自动检测目录
bash update.sh /path/to/rime            # 自定义目录

# Windows
update.bat                              # 自动检测目录
update.bat D:\RimeConfig                # 自定义目录
```

### 一键更新（远程执行）

```bash
# Linux / macOS
bash -c "$(curl -fsSL https://raw.githubusercontent.com/aiimoyu/rime-xi/main/update.sh)"

# Windows PowerShell
irm https://raw.githubusercontent.com/aiimoyu/rime-xi/main/update.bat | iex
```

### 工作原理

1. 从 GitHub 下载最新 zip 包
2. 解压到临时目录
3. 复制 `oh-my-rime/` 目录内容到 Rime 配置目录
4. 自动清理临时文件

### 不会被覆盖的文件

以下文件**不会被覆盖**（不在仓库的 `oh-my-rime/` 目录中）：

- `installation.yaml` - 每台电脑的独立配置（需手动创建）
- `*.custom.yaml` - 用户自定义配置（建议手动维护）

### 手动创建 installation.yaml

此文件不在仓库中，需要在 Rime 配置目录手动创建，包含每台电脑的独立配置信息：

```yaml
distribution_code_name: weasel
distribution_name: 小狼毫
distribution_version: 0.16.3
install_time: 2026-02-19
rime_version: 1.11.2
```

## GitHub Action

仓库包含 `.github/workflows/update-rime.yml`，会自动：

- 每周一 00:00 UTC 更新 oh-my-rime（git subtree）
- 下载最新万象 LTS 词库
- 提交并推送更改

### 手动触发

在 GitHub 仓库页面 → Actions → Update Rime Configuration → Run workflow

## 文件结构

```
rime-xi/
├── .github/workflows/
│   └── update-rime.yml      # GitHub Action 自动更新工作流
├── oh-my-rime/              # oh-my-rime 子模块
│   └── wanxiang-lts-zh-hans.gram  # 万象词库
├── update.sh                # Linux/macOS 更新脚本
├── update.bat               # Windows 更新脚本
└── README.md                # 说明文档
```

## 故障排除

### 更新失败

```bash
# Linux - 检查依赖
sudo apt install curl unzip        # Debian/Ubuntu
sudo dnf install curl unzip        # Fedora
brew install curl unzip            # macOS

# Windows - 无需额外依赖（使用内置 PowerShell）
```

### 同步冲突

如果 git subtree 冲突：

```bash
# 重置 oh-my-rime 目录
git subtree pull --prefix oh-my-rime https://github.com/Mintimate/oh-my-rime.git main --squash --force
```

### Rime 未生效

1. 确认配置已复制到正确的目录
2. 执行重新部署操作
3. 检查 Rime 日志：`~/.config/ibus/rime/rime.log`

## 相关链接

- [oh-my-rime](https://github.com/Mintimate/oh-my-rime) - Rime 配置框架
- [万象 LMDG](https://github.com/amzxyz/RIME-LMDG) - 语言模型词库
- [Rime 官网](https://rime.im/) - Rime 输入法引擎

## License

MIT
