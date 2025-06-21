#!/bin/bash
# package-manager.sh - ARM64库包管理脚本
# ARM64 Library Package Manager Script

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# 显示帮助信息
show_help() {
    cat << EOF
ARM64库包管理脚本

用法: $0 [命令] [选项]

命令:
    install PACKAGE         安装ARM64版本的包
    search KEYWORD          搜索可用的ARM64包
    list                    列出已安装的ARM64包
    info PACKAGE            显示包信息
    remove PACKAGE          移除包
    update                  更新包列表
    upgrade                 升级所有包
    build-from-source PKG   从源码构建包
    
特殊包管理:
    install-qt5 [VERSION]   安装Qt5 (默认版本5.12)
    install-qt6 [VERSION]   安装Qt6 (默认版本6.2)
    install-boost [VERSION] 安装Boost (默认版本1.74)
    install-opencv [VERSION] 安装OpenCV (默认版本4.5)
    install-eigen [VERSION] 安装Eigen (默认版本3.4)
    
选项:
    -h, --help              显示此帮助信息
    -v, --verbose           详细输出
    -y, --yes              自动确认所有询问
    --prefix DIR           安装前缀 (默认: /opt/arm64-libs)
    --temp-dir DIR         临时目录 (默认: /tmp/arm64-build)

示例:
    $0 install libssl-dev:arm64             # 安装OpenSSL开发库
    $0 install-qt5 5.15                     # 安装Qt5.15
    $0 build-from-source opencv 4.6.0       # 从源码构建OpenCV 4.6.0
    $0 search opencv                        # 搜索OpenCV相关包

EOF
}

# 默认参数
COMMAND=""
VERBOSE=false
AUTO_YES=false
PREFIX="/opt/arm64-libs"
TEMP_DIR="/tmp/arm64-build"

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -y|--yes)
            AUTO_YES=true
            shift
            ;;
        --prefix)
            PREFIX="$2"
            shift 2
            ;;
        --temp-dir)
            TEMP_DIR="$2"
            shift 2
            ;;
        install|search|list|info|remove|update|upgrade|build-from-source|install-qt5|install-qt6|install-boost|install-opencv|install-eigen)
            COMMAND="$1"
            shift
            break
            ;;
        *)
            log_error "未知选项: $1"
            exit 1
            ;;
    esac
done

if [[ -z "$COMMAND" ]]; then
    log_error "请指定命令"
    show_help
    exit 1
fi

# 创建必要的目录
mkdir -p "$PREFIX"
mkdir -p "$TEMP_DIR"

# APT包管理
apt_install() {
    local package="$1"
    log_step "安装APT包: $package"
    
    if [[ "$AUTO_YES" == true ]]; then
        sudo apt-get install -y "$package"
    else
        sudo apt-get install "$package"
    fi
}

apt_search() {
    local keyword="$1"
    log_step "搜索包: $keyword"
    apt-cache search "$keyword" | grep arm64
}

apt_info() {
    local package="$1"
    apt-cache show "$package"
}

# 从源码构建通用函数
build_from_source() {
    local name="$1"
    local version="$2"
    local url="$3"
    local configure_opts="$4"
    local build_opts="$5"
    
    log_step "从源码构建 $name $version"
    
    cd "$TEMP_DIR"
    
    # 下载源码
    if [[ "$url" == *.git ]]; then
        if [[ -d "$name" ]]; then
            rm -rf "$name"
        fi
        git clone "$url" "$name"
        cd "$name"
        if [[ -n "$version" && "$version" != "latest" ]]; then
            git checkout "$version"
        fi
    else
        local filename=$(basename "$url")
        if [[ ! -f "$filename" ]]; then
            wget "$url"
        fi
        
        # 解压
        if [[ "$filename" == *.tar.gz || "$filename" == *.tgz ]]; then
            tar -xzf "$filename"
        elif [[ "$filename" == *.tar.bz2 ]]; then
            tar -xjf "$filename"
        elif [[ "$filename" == *.zip ]]; then
            unzip "$filename"
        fi
        
        # 查找解压后的目录
        local extracted_dir=$(find . -maxdepth 1 -type d -name "*$name*" | head -1)
        if [[ -z "$extracted_dir" ]]; then
            extracted_dir=$(find . -maxdepth 1 -type d ! -name "." | head -1)
        fi
        cd "$extracted_dir"
    fi
    
    # 创建构建目录
    mkdir -p build-arm64
    cd build-arm64
    
    # 配置构建
    if [[ -f "../CMakeLists.txt" ]]; then
        log_step "使用CMake配置..."
        cmake .. \
            -DCMAKE_TOOLCHAIN_FILE=/usr/share/cmake/Toolchains/arm64-toolchain.cmake \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_INSTALL_PREFIX="$PREFIX" \
            $configure_opts
        
        log_step "编译..."
        make -j$(nproc) $build_opts
        
        log_step "安装..."
        make install
        
    elif [[ -f "../configure" ]]; then
        log_step "使用Autotools配置..."
        ../configure \
            --host=aarch64-linux-gnu \
            --prefix="$PREFIX" \
            CC=aarch64-linux-gnu-gcc \
            CXX=aarch64-linux-gnu-g++ \
            $configure_opts
        
        log_step "编译..."
        make -j$(nproc) $build_opts
        
        log_step "安装..."
        make install
    else
        log_error "不支持的构建系统"
        return 1
    fi
    
    log_info "$name $version 构建完成!"
}

# Qt5安装
install_qt5() {
    local version="${1:-5.12}"
    log_step "安装Qt5 $version"
    
    if [[ -d "/opt/qt5-arm64" ]]; then
        log_info "Qt5已经存在于 /opt/qt5-arm64"
        return 0
    fi
    
    # 如果有预编译版本，优先使用
    if [[ -d "/workspace/Qt5.12.8-arm64" ]]; then
        log_step "发现预编译的Qt5，正在复制..."
        sudo cp -r "/workspace/Qt5.12.8-arm64" "/opt/qt5-arm64"
        return 0
    fi
    
    # 从源码构建Qt5
    log_warn "将从源码构建Qt5，这可能需要很长时间..."
    if [[ "$AUTO_YES" != true ]]; then
        read -p "继续吗? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    
    build_from_source "qt5" "$version" \
        "https://download.qt.io/archive/qt/5.12/5.12.8/single/qt-everywhere-src-5.12.8.tar.xz" \
        "-DCMAKE_INSTALL_PREFIX=/opt/qt5-arm64 -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF"
}

# Qt6安装
install_qt6() {
    local version="${1:-6.2}"
    log_step "安装Qt6 $version"
    
    if [[ -d "/opt/qt6-arm64" ]]; then
        log_info "Qt6已经存在于 /opt/qt6-arm64"
        return 0
    fi
    
    build_from_source "qt6" "$version" \
        "https://download.qt.io/archive/qt/6.2/6.2.4/single/qt-everywhere-src-6.2.4.tar.xz" \
        "-DCMAKE_INSTALL_PREFIX=/opt/qt6-arm64 -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF"
}

# Boost安装
install_boost() {
    local version="${1:-1.74.0}"
    log_step "安装Boost $version"
    
    local version_underscore=${version//\./_}
    build_from_source "boost" "$version" \
        "https://boostorg.jfrog.io/artifactory/main/release/$version/source/boost_$version_underscore.tar.gz" \
        "" \
        ""
}

# OpenCV安装
install_opencv() {
    local version="${1:-4.5.0}"
    log_step "安装OpenCV $version"
    
    build_from_source "opencv" "$version" \
        "https://github.com/opencv/opencv/archive/$version.tar.gz" \
        "-DCMAKE_INSTALL_PREFIX=/opt/opencv-arm64 -DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF"
}

# Eigen安装
install_eigen() {
    local version="${1:-3.4.0}"
    log_step "安装Eigen $version"
    
    build_from_source "eigen" "$version" \
        "https://gitlab.com/libeigen/eigen/-/archive/$version/eigen-$version.tar.gz" \
        "-DCMAKE_INSTALL_PREFIX=/opt/eigen-arm64"
}

# 主命令处理
case $COMMAND in
    install)
        if [[ $# -eq 0 ]]; then
            log_error "请指定要安装的包"
            exit 1
        fi
        apt_install "$1"
        ;;
    search)
        if [[ $# -eq 0 ]]; then
            log_error "请指定搜索关键词"
            exit 1
        fi
        apt_search "$1"
        ;;
    list)
        dpkg -l | grep arm64
        ;;
    info)
        if [[ $# -eq 0 ]]; then
            log_error "请指定包名"
            exit 1
        fi
        apt_info "$1"
        ;;
    remove)
        if [[ $# -eq 0 ]]; then
            log_error "请指定要移除的包"
            exit 1
        fi
        sudo apt-get remove "$1"
        ;;
    update)
        sudo apt-get update
        ;;
    upgrade)
        sudo apt-get upgrade
        ;;
    build-from-source)
        if [[ $# -lt 2 ]]; then
            log_error "用法: build-from-source PACKAGE VERSION [URL]"
            exit 1
        fi
        build_from_source "$1" "$2" "$3"
        ;;
    install-qt5)
        install_qt5 "$1"
        ;;
    install-qt6)
        install_qt6 "$1"
        ;;
    install-boost)
        install_boost "$1"
        ;;
    install-opencv)
        install_opencv "$1"
        ;;
    install-eigen)
        install_eigen "$1"
        ;;
    *)
        log_error "未知命令: $COMMAND"
        exit 1
        ;;
esac

log_info "操作完成!"
