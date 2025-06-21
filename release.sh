#!/bin/bash
# release.sh - 自动化发布脚本

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查参数
if [[ $# -eq 0 ]]; then
    echo "用法: $0 <version> [remote-name]"
    echo "示例: $0 v1.0.0"
    echo "示例: $0 v1.0.1 origin"
    exit 1
fi

VERSION="$1"
REMOTE="${2:-origin}"

log_info "准备发布版本: $VERSION"

# 检查git状态
if [[ -n $(git status --porcelain) ]]; then
    log_error "工作区有未提交的更改，请先提交或储藏"
    git status --short
    exit 1
fi

# 检查分支
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "main" && "$CURRENT_BRANCH" != "master" ]]; then
    log_warn "当前不在主分支 ($CURRENT_BRANCH)，确认要继续吗？"
    read -p "继续? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 拉取最新代码
log_info "拉取最新代码..."
git pull $REMOTE $CURRENT_BRANCH

# 运行测试（如果存在）
if [[ -f "test.sh" ]]; then
    log_info "运行测试..."
    ./test.sh
fi

# 构建Docker镜像进行测试
log_info "测试构建Docker镜像..."
docker build -f Dockerfile -t test-universal-cross-builder .
docker build -f Dockerfile.lite -t test-universal-cross-builder-lite .

log_info "测试基本功能..."
docker run --rm test-universal-cross-builder aarch64-linux-gnu-gcc --version
docker run --rm test-universal-cross-builder-lite aarch64-linux-gnu-gcc --version

# 清理测试镜像
docker rmi test-universal-cross-builder test-universal-cross-builder-lite

# 更新CHANGELOG
log_info "更新CHANGELOG..."
if [[ -f "CHANGELOG.md" ]]; then
    # 在CHANGELOG中添加新版本信息
    DATE=$(date +%Y-%m-%d)
    sed -i "3i\\## [$VERSION] - $DATE\\n\\n### 更改\\n- 发布版本 $VERSION\\n" CHANGELOG.md
    
    log_info "请编辑CHANGELOG.md来添加版本更改信息"
    read -p "按回车键继续..."
fi

# 创建发布提交
log_info "创建发布提交..."
git add .
git commit -m "chore: 发布版本 $VERSION" || log_warn "没有新的更改需要提交"

# 创建标签
log_info "创建标签..."
git tag -a "$VERSION" -m "发布版本 $VERSION"

# 推送到远程仓库
log_info "推送到远程仓库..."
git push $REMOTE $CURRENT_BRANCH
git push $REMOTE "$VERSION"

log_info "✅ 版本 $VERSION 发布完成！"
log_info "请前往GitHub创建Release并发布到Docker Hub"

echo ""
echo "下一步："
echo "1. 访问 https://github.com/YOUR_USERNAME/universal-arm64-cross-builder/releases"
echo "2. 点击 'Create a new release'"
echo "3. 选择标签: $VERSION"
echo "4. 填写Release notes"
echo "5. 发布Release"
