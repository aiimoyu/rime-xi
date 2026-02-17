# Rime 输入法配置 - 月轮 + 万象词库

基于 [oh-my-rime](https://github.com/Mintimate/oh-my-rime) 和 [万象 LMDG](https://github.com/amzxyz/RIME-LMDG) 的 Rime 输入法配置。

## 特性

- 🔄 **自动更新**：GitHub Action 每周一 00:00 UTC 自动更新 oh-my-rime 和万象词库
- 🖥️ **多平台支持**：Linux (IBus/Fcitx)、macOS (Squirrel)、Windows (Weasel)
- 🤖 **AI 友好**：支持 opencode、claude code 等 AI 工具本地更新
- 📦 **独立配置**：每台电脑的 `installation.yaml` 独立保存，不会被覆盖

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/YOUR_USERNAME/rime-xi.git
cd rime-xi
```

### 2. 本地更新配置

#### 方法 A：在配置目录运行（推荐）

```bash
# Linux (IBus)
bash update.sh ~/.config/ibus/rime

# Linux (Fcitx)
bash update.sh ~/.config/fcitx/rime

# macOS (Squirrel)
bash update.sh ~/Library/Rime

# Windows (Weasel) - PowerShell
bash update.sh "$env:APPDATA\Rime"
```

#### 方法 B：在仓库目录运行

```bash
cd rime-xi
bash update.sh
```

脚本会自动检测 Rime 配置目录，或允许你手动指定。

#### 方法 C：AI 工具调用

在 opencode 或 claude code 中：

```bash
# AI 工具可以直接执行更新脚本
bash ./update.sh ~/.config/ibus/rime
```

### 3. 重新部署 Rime

更新后需要重新部署 Rime 使配置生效：

- **Linux (IBus)**: `ibus restart` 或重新登录
- **Linux (Fcitx)**: `fcitx5-remote -r` 或重启 Fcitx
- **macOS (Squirrel)**: 右键系统托盘图标 → 重新部署
- **Windows (Weasel)**: 右键系统托盘图标 → 重新部署

## 更新配置

### Linux/macOS
```bash
bash update.sh                          # 使用默认目录
bash update.sh /path/to/rime            # 自定义目录
```

### Windows
```cmd
update.bat                              # 使用默认目录
update.bat D:\RimeConfig                # 自定义目录
```

### 排除文件
以下文件不会被覆盖：
- `installation.yaml` - 机器独有配置
- `*.custom.yaml` - 用户自定义配置

### 手动创建 installation.yaml
此文件不在仓库中，需要在系统目录手动创建，包含每台电脑的独立配置信息。

### GitHub Action

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
├── installation.yaml        # 安装配置（不在仓库中，每台电脑独立）
├── update.sh                # 本地更新脚本
└── README.md                # 说明文档
```

## 独立配置文件

以下文件在更新时**不会被覆盖**（在 `update.sh` 的排除列表中）：

- `installation.yaml` - 每台电脑的安装配置
- `.git/` - Git 版本控制目录

修改这些文件后，可以单独提交到仓库：

```bash
git add installation.yaml
git commit -m "chore: update installation config"
git push
```

## 故障排除

### 更新失败

```bash
# 检查依赖
sudo apt install git curl rsync  # Debian/Ubuntu
sudo dnf install git curl rsync  # Fedora
brew install git curl rsync      # macOS
```

### 同步冲突

如果 git subtree 冲突：

```bash
# 重置 oh-my-rime 目录
git subtree pull --prefix oh-my-rime https://github.com/Mintimate/oh-my-rime.git main --squash --force
```

### Rime 未生效

1. 确认配置已同步到正确的目录
2. 执行重新部署操作
3. 检查 Rime 日志：`~/.config/ibus/rime/rime.log`

## 相关链接

- [oh-my-rime](https://github.com/Mintimate/oh-my-rime) - Rime 配置框架
- [万象 LMDG](https://github.com/amzxyz/RIME-LMDG) - 语言模型词库
- [Rime 官网](https://rime.im/) - Rime 输入法引擎

## License

MIT
