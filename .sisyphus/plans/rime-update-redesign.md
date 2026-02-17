# Rime 配置更新系统重新设计

## TL;DR

> **核心问题**: 当前脚本逻辑混乱，`installation.yaml` 不应在仓库中
> 
> **解决方案**: 脚本从 GitHub 下载配置文件，直接覆盖系统目录
> 
> **排除文件**: `installation.yaml`, `*.custom.yaml` 等用户独有文件
> 
> **平台支持**: Linux (~/.config/ibus/rime) + Windows (%APPDATA%\Rime)

---

## Context

### 用户需求
- 系统 Rime 配置目录：`~/.config/ibus/rime`
- 仓库目录：`~/git/rime-xi`
- 需要从仓库同步配置到系统目录
- `installation.yaml` 是机器独有，不应在仓库中，不应覆盖

### 当前问题
1. `installation.yaml` 错误地存在于仓库中
2. 脚本逻辑过于复杂（git subtree + 下载词库）
3. 同步方向不清晰

---

## Work Objectives

### Core Objective
简化更新脚本，明确同步方向：GitHub 仓库 → 系统 Rime 目录

### Concrete Deliverables
- [ ] 删除 `installation.yaml`
- [ ] 重写 `update.sh`（简化版）
- [ ] 更新 `README.md` 使用说明
- [ ] 更新 GitHub Action（仅更新仓库自身）

### Definition of Done
- [ ] `bash update.sh` 可从仓库同步到 `~/.config/ibus/rime`
- [ ] 用户独有文件不被覆盖
- [ ] 提交并推送到远程 main 分支

---

## TODOs

- [ ] 1. 删除 `installation.yaml`

  **What to do**:
  - 从仓库删除此文件（机器独有，不应在版本控制中）
  
  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: [`git-master`]

  **Parallelization**:
  - **Can Run In Parallel**: NO (blocks Task 2)
  
  **Acceptance Criteria**:
  - [ ] `installation.yaml` 从仓库删除
  - [ ] 提交信息：`chore: remove installation.yaml (machine-specific)`

  **Commit**: YES
  - Message: `chore: remove installation.yaml (machine-specific config)`

---

- [ ] 2. 重写 `update.sh`（支持 Linux + Windows）

  **What to do**:
  - 从 GitHub 下载文件覆盖配置
  - 不依赖 rsync，使用 curl + cp
  - 支持 Linux 和 Windows
  - 保护用户独有文件
  
  **新脚本内容**:
  ```bash
  #!/bin/bash
  # Rime 配置更新脚本 - 从 GitHub 下载并覆盖
  
  set -e
  
  # 配置
  REPO="aiimoyu/rime-xi"
  BRANCH="main"
  RAW_URL="https://raw.githubusercontent.com/$REPO/$BRANCH"
  
  # 检测平台
  if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
      # Windows
      TARGET_DIR="${1:-$APPDATA/Rime}"
  else
      # Linux/macOS
      TARGET_DIR="${1:-$HOME/.config/ibus/rime}"
  fi
  
  # 创建目录
  mkdir -p "$TARGET_DIR"
  
  echo "Downloading from: $RAW_URL"
  echo "Target directory: $TARGET_DIR"
  
  # 文件列表（从仓库下载）
  FILES=(
      "default.yaml"
      "double_pinyin_flypy.schema.yaml"
      "melt_eng.schema.yaml"
      # ... 其他文件
  )
  
  # 排除文件（不覆盖）
  EXCLUDE=(
      "installation.yaml"
      "*.custom.yaml"
  )
  
  # 下载并覆盖
  for file in "${FILES[@]}"; do
      echo "Downloading: $file"
      curl -L -o "$TARGET_DIR/$file" "$RAW_URL/$file"
  done
  
  # 下载 oh-my-rime 目录
  echo "Downloading oh-my-rime directory..."
  # 使用 git 或下载 zip
  
  # 重新部署
  if command -v ibus &> /dev/null; then
      ibus restart
  fi
  
  echo "Update complete!"
  ```

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Blocked By**: Task 1
  
  **Acceptance Criteria**:
  - [ ] 脚本可在 Linux 运行
  - [ ] 脚本可在 Windows (Git Bash) 运行
  - [ ] 不依赖 rsync
  - [ ] 排除文件不被覆盖

  **Commit**: YES
  - Message: `feat: add cross-platform update script`

---

- [ ] 3. 创建 `update.bat`（Windows 原生支持）

  **What to do**:
  - 为 Windows 用户创建批处理版本
  - 功能与 bash 脚本相同
  
  **Recommended Agent Profile**:
  - **Category**: `quick`
  
  **Parallelization**:
  - **Can Run In Parallel**: YES (with Task 2)
  
  **Acceptance Criteria**:
  - [ ] 可在 Windows CMD/PowerShell 运行
  - [ ] 使用 curl/copy 命令

  **Commit**: YES
  - Message: `feat: add Windows batch update script`

---

- [ ] 4. 更新 `README.md`

  **What to do**:
  - 更新使用说明
  - 说明 Linux 和 Windows 使用方法
  - 说明 `installation.yaml` 需要手动创建
  
  **Recommended Agent Profile**:
  - **Category**: `quick`
  
  **Parallelization**:
  - **Blocked By**: Task 2, 3
  
  **Acceptance Criteria**:
  - [ ] README 包含 Linux 使用说明
  - [ ] README 包含 Windows 使用说明
  - [ ] 说明排除文件机制

  **Commit**: YES
  - Message: `docs: update README with cross-platform instructions`

---

- [ ] 5. 更新 GitHub Action

  **What to do**:
  - 简化 workflow
  - 仅更新 oh-my-rime subtree
  
  **Recommended Agent Profile**:
  - **Category**: `quick`
  
  **Parallelization**:
  - **Blocked By**: Task 2
  
  **Acceptance Criteria**:
  - [ ] GitHub Action 正常工作
  - [ ] 提交并推送

  **Commit**: YES
  - Message: `ci: simplify GitHub Action workflow`

---

- [ ] 6. 提交并推送所有更改

  **What to do**:
  - 提交所有更改到 main 分支
  
  **Recommended Agent Profile**:
  - **Category**: `git-master`
  
  **Acceptance Criteria**:
  - [ ] 所有更改推送到 origin/main
  - [ ] 分支状态干净

---

## Execution Strategy

### Execution Order
```
Task 1 (delete installation.yaml)
    ↓
Task 2 (rewrite update.sh) ──┬── Task 3 (update.bat, parallel)
    ↓                         │
Task 4 (update README) ←──────┘
    ↓
Task 5 (update GitHub Action)
    ↓
Task 6 (commit & push)
```

---

## Success Criteria

### Verification Commands
```bash
# 测试同步
cd ~/git/rime-xi
bash update.sh

# 验证系统目录
ls ~/.config/ibus/rime/

# 验证排除文件
cat ~/.config/ibus/rime/installation.yaml  # 应该保持原样
```

### Final Checklist
- [ ] `installation.yaml` 不在仓库中
- [ ] `update.sh` 可正常同步
- [ ] 用户独有文件被保护
- [ ] README 说明清晰
