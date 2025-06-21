#!/bin/bash
# test.sh - 基本功能测试脚本

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_info "开始基本功能测试..."

# 测试脚本语法
log_info "检查脚本语法..."
bash -n build-universal.sh || { log_error "build-universal.sh 语法错误"; exit 1; }
bash -n package-manager.sh || { log_error "package-manager.sh 语法错误"; exit 1; }
bash -n quick-start.sh || { log_error "quick-start.sh 语法错误"; exit 1; }
bash -n release.sh || { log_error "release.sh 语法错误"; exit 1; }

# 测试Docker文件语法（跳过实际构建）
log_info "检查Dockerfile语法..."
log_warn "跳过Docker构建测试（网络问题）"
# docker build -f Dockerfile --no-cache -t test-syntax . > /dev/null || { log_error "Dockerfile 构建失败"; exit 1; }
# docker build -f Dockerfile.lite --no-cache -t test-syntax-lite . > /dev/null || { log_error "Dockerfile.lite 构建失败"; exit 1; }

# 清理测试镜像
# docker rmi test-syntax test-syntax-lite > /dev/null 2>&1

# 测试脚本权限
log_info "检查脚本权限..."
[[ -x build-universal.sh ]] || { log_error "build-universal.sh 不可执行"; exit 1; }
[[ -x package-manager.sh ]] || { log_error "package-manager.sh 不可执行"; exit 1; }
[[ -x quick-start.sh ]] || { log_error "quick-start.sh 不可执行"; exit 1; }
[[ -x release.sh ]] || { log_error "release.sh 不可执行"; exit 1; }

# 测试文档文件存在
log_info "检查文档文件..."
[[ -f README.md ]] || { log_error "README.md 不存在"; exit 1; }
[[ -f LICENSE ]] || { log_error "LICENSE 不存在"; exit 1; }
[[ -f CONTRIBUTING.md ]] || { log_error "CONTRIBUTING.md 不存在"; exit 1; }
[[ -f CHANGELOG.md ]] || { log_error "CHANGELOG.md 不存在"; exit 1; }

# 测试目录结构
log_info "检查目录结构..."
[[ -d workspace ]] || { log_error "workspace 目录不存在"; exit 1; }
[[ -d output ]] || { log_error "output 目录不存在"; exit 1; }
[[ -d prebuilt-libs ]] || { log_error "prebuilt-libs 目录不存在"; exit 1; }
[[ -d .github/workflows ]] || { log_error ".github/workflows 目录不存在"; exit 1; }

log_info "✅ 所有测试通过！"
