#!/bin/bash
#
# Rime Configuration Update Script
# 支持本地更新和 AI 工具（opencode、claude code）使用
#
# 使用方法:
#   1. 在 Rime 配置目录运行：bash update.sh
#   2. 或指定配置目录：bash update.sh ~/.config/ibus/rime
#   3. AI 工具可直接调用此脚本进行更新
#

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 配置变量
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RIME_CONFIG_DIR="${1:-}"
REPO_URL="https://github.com/Mintimate/oh-my-rime.git"
WANXIANG_URL="https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/wanxiang-lts-zh-hans.gram"

# 需要排除的文件（每台电脑独立配置）
EXCLUDE_FILES=(
    "installation.yaml"
    ".git"
)

# 检测 AI 工具环境
detect_ai_tool() {
    if [ -n "$OPENCODE_ENV" ]; then
        echo "opencode"
    elif [ -n "$CLAUDE_CODE_ENV" ]; then
        echo "claude_code"
    else
        echo "shell"
    fi
}

# 检查依赖
check_dependencies() {
    log_info "Checking dependencies..."
    
    local missing_deps=()
    
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi
    
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_info "Install with: sudo apt install ${missing_deps[*]}"
        exit 1
    fi
    
    log_success "All dependencies installed"
}

# 确定 Rime 配置目录
determine_config_dir() {
    if [ -n "$RIME_CONFIG_DIR" ]; then
        log_info "Using specified config directory: $RIME_CONFIG_DIR"
        return
    fi
    
    # 自动检测常见 Rime 配置路径
    local common_paths=(
        "$HOME/.config/ibus/rime"
        "$HOME/.config/fcitx/rime"
        "$HOME/Library/Rime"
        "$HOME/.config/weasel"
    )
    
    for path in "${common_paths[@]}"; do
        if [ -d "$path" ]; then
            RIME_CONFIG_DIR="$path"
            log_info "Auto-detected Rime config directory: $RIME_CONFIG_DIR"
            return
        fi
    done
    
    # 如果都没找到，使用当前目录
    if [ -z "$RIME_CONFIG_DIR" ]; then
        RIME_CONFIG_DIR="$(pwd)"
        log_warning "No standard Rime config directory found, using current directory: $RIME_CONFIG_DIR"
    fi
}

# 更新 oh-my-rime (git subtree)
update_oh_my_rime() {
    log_info "Updating oh-my-rime..."
    
    # 检查是否已有 oh-my-rime 目录
    if [ ! -d "$SCRIPT_DIR/oh-my-rime" ]; then
        log_info "Initializing oh-my-rime subtree..."
        git subtree add --prefix oh-my-rime "$REPO_URL" main --squash || {
            log_warning "oh-my-rime subtree already exists, pulling instead..."
        }
    fi
    
    # 执行 subtree pull
    log_info "Pulling latest oh-my-rime changes..."
    git subtree pull --prefix oh-my-rime "$REPO_URL" main --squash || {
        log_warning "oh-my-rime is up to date or no remote changes"
    }
    
    log_success "oh-my-rime updated"
}

# 更新万象词库
update_wanxiang_dictionary() {
    log_info "Updating Wanxiang dictionary..."
    
    local temp_file=$(mktemp)
    
    if curl -L -o "$temp_file" "$WANXIANG_URL" 2>/dev/null; then
        if [ -s "$temp_file" ]; then
            # 复制到 oh-my-rime 目录
            mkdir -p "$SCRIPT_DIR/oh-my-rime"
            cp "$temp_file" "$SCRIPT_DIR/oh-my-rime/wanxiang-lts-zh-hans.gram"
            log_success "Wanxiang dictionary downloaded and updated"
        else
            log_error "Downloaded file is empty"
            rm -f "$temp_file"
            return 1
        fi
    else
        log_error "Failed to download Wanxiang dictionary"
        rm -f "$temp_file"
        return 1
    fi
    
    rm -f "$temp_file"
}

# 同步配置到目标目录
sync_to_config_dir() {
    log_info "Syncing configuration to: $RIME_CONFIG_DIR"
    
    # 创建目标目录（如果不存在）
    mkdir -p "$RIME_CONFIG_DIR"
    
    # 构建 rsync 排除参数
    local exclude_args=()
    for file in "${EXCLUDE_FILES[@]}"; do
        exclude_args+=("--exclude" "$file")
    done
    
    # 使用 rsync 同步（排除独立配置文件）
    if command -v rsync &> /dev/null; then
        rsync -av --delete "${exclude_args[@]}" "$SCRIPT_DIR/" "$RIME_CONFIG_DIR/" || {
            log_warning "rsync failed, falling back to cp"
            fallback_sync
        }
    else
        log_info "rsync not available, using cp"
        fallback_sync
    fi
    
    log_success "Configuration synced to $RIME_CONFIG_DIR"
}

# 备用同步方案（cp）
fallback_sync() {
    log_info "Using cp for synchronization..."
    
    # 复制所有文件（除了排除列表）
    for item in "$SCRIPT_DIR"/*; do
        local basename=$(basename "$item")
        local skip=false
        
        for exclude in "${EXCLUDE_FILES[@]}"; do
            if [ "$basename" = "$exclude" ]; then
                skip=true
                break
            fi
        done
        
        if [ "$skip" = false ]; then
            if [ -d "$item" ]; then
                cp -r "$item" "$RIME_CONFIG_DIR/"
            else
                cp "$item" "$RIME_CONFIG_DIR/"
            fi
        fi
    done
}

# 重新部署 Rime
redeploy_rime() {
    log_info "Redeploying Rime..."
    
    # 检测 Rime 环境
    if command -v ibus &> /dev/null; then
        log_info "Detected IBus, triggering redeployment..."
        ibus restart || log_warning "Failed to restart IBus"
    elif command -v fcitx5-remote &> /dev/null; then
        log_info "Detected Fcitx5, triggering redeployment..."
        fcitx5-remote -r || log_warning "Failed to restart Fcitx5"
    elif command -v fcitx-remote &> /dev/null; then
        log_info "Detected Fcitx, triggering redeployment..."
        fcitx-remote -r || log_warning "Failed to restart Fcitx"
    else
        log_info "No Rime frontend detected, manual redeployment may be required"
        log_info "On Linux: ibus restart 或重新登录"
        log_info "On Windows (Weasel): 右键系统托盘图标 -> 重新部署"
        log_info "On macOS (Squirrel): 右键系统托盘图标 -> 重新部署"
    fi
}

# 主函数
main() {
    local ai_tool=$(detect_ai_tool)
    log_info "Running in $ai_tool mode"
    
    echo ""
    log_info "=== Rime Configuration Update ==="
    echo ""
    
    check_dependencies
    determine_config_dir
    
    echo ""
    log_info "Step 1: Update oh-my-rime..."
    update_oh_my_rime
    
    echo ""
    log_info "Step 2: Update Wanxiang dictionary..."
    update_wanxiang_dictionary
    
    echo ""
    log_info "Step 3: Sync to config directory..."
    sync_to_config_dir
    
    echo ""
    log_info "Step 4: Redeploy Rime..."
    redeploy_rime
    
    echo ""
    log_success "=== Update Complete ==="
    echo ""
    log_info "Configuration directory: $RIME_CONFIG_DIR"
    log_info "Repository directory: $SCRIPT_DIR"
    echo ""
    log_info "Note: installation.yaml was preserved (not overwritten)"
    log_info "If you encounter issues, run: ibus restart (Linux) or re-deploy from system tray"
}

# 执行主函数
main "$@"
