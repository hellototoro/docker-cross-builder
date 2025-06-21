#!/bin/bash
# quick-start.sh - 快速启动脚本

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示欢迎信息
cat << 'EOF'
================================================
    通用ARM64交叉编译容器快速启动脚本
================================================
EOF

echo_info "检查Docker是否安装..."
if ! command -v docker &> /dev/null; then
    echo_error "Docker未安装，请先安装Docker"
    exit 1
fi

echo_info "检查docker-compose是否安装..."
if ! command -v docker-compose &> /dev/null; then
    echo_warn "docker-compose未安装，将使用docker命令"
    USE_COMPOSE=false
else
    USE_COMPOSE=true
fi

# 创建必要的目录
echo_info "创建工作目录..."
mkdir -p workspace output prebuilt-libs

# 构建镜像
echo_info "构建Docker镜像..."
if [[ "$USE_COMPOSE" == true ]]; then
    docker-compose build
else
    docker build -f Dockerfile -t universal-cross-builder .
fi

echo_info "构建完成！"

# 询问是否立即启动容器
read -p "是否立即启动容器? (Y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo_info "您可以稍后使用以下命令启动容器："
    if [[ "$USE_COMPOSE" == true ]]; then
        echo "docker-compose up -d"
        echo "docker-compose exec cross-builder bash"
    else
        echo "docker run -it --rm -v \$(pwd)/workspace:/workspace -v \$(pwd)/output:/output universal-cross-builder"
    fi
    exit 0
fi

# 启动容器
echo_info "启动容器..."
if [[ "$USE_COMPOSE" == true ]]; then
    docker-compose up -d
    echo_info "容器已启动，使用以下命令进入容器："
    echo "docker-compose exec cross-builder bash"
    echo ""
    echo_info "正在进入容器..."
    docker-compose exec cross-builder bash
else
    docker run -it --rm \
        -v $(pwd)/workspace:/workspace \
        -v $(pwd)/output:/output \
        universal-cross-builder
fi
