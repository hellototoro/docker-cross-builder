#!/bin/bash
# build-universal.sh - 通用交叉编译构建脚本
# Universal Cross-Compilation Build Script

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# 显示帮助信息
show_help() {
    cat << EOF
通用ARM64交叉编译构建脚本

用法: $0 [选项] [项目路径]

选项:
    -h, --help              显示此帮助信息
    -c, --clean             清理构建目录
    -t, --type TYPE         构建类型 (Debug|Release|RelWithDebInfo|MinSizeRel)
    -j, --jobs JOBS         并行编译作业数 (默认: CPU核心数)
    -o, --output DIR        输出目录 (默认: build-arm64)
    --cmake-args ARGS       额外的CMake参数
    --make-args ARGS        额外的Make参数
    --toolchain FILE        自定义工具链文件
    --install               安装到指定目录
    --install-prefix DIR    安装前缀 (默认: /opt/arm64)
    --package               创建安装包
    --package-type TYPE     包类型 (deb|rpm|tar|appimage)
    --test                  运行测试
    --deploy                部署应用
    --qt-deploy             使用Qt部署工具
    --verbose               详细输出

项目类型检测:
    - CMake项目 (CMakeLists.txt)
    - QMake项目 (*.pro)
    - Autotools项目 (configure.ac, configure.in, Makefile.am)
    - Make项目 (Makefile)
    - Meson项目 (meson.build)

示例:
    $0                                          # 在当前目录构建
    $0 /path/to/project                         # 构建指定项目
    $0 -t Release -j 8 --install               # 发布版本，8个并行作业，并安装
    $0 --cmake-args "-DWITH_EXAMPLES=ON"       # 传递额外的CMake参数
    $0 --package --package-type deb            # 构建并创建deb包
    $0 --qt-deploy --package-type appimage     # Qt应用部署为AppImage

EOF
}

# 默认参数
PROJECT_DIR=""
BUILD_TYPE="Release"
JOBS=$(nproc)
OUTPUT_DIR="build-arm64"
CMAKE_ARGS=""
MAKE_ARGS=""
TOOLCHAIN_FILE="/usr/share/cmake/Toolchains/arm64-toolchain.cmake"
DO_CLEAN=false
DO_INSTALL=false
INSTALL_PREFIX="/opt/arm64"
DO_PACKAGE=false
PACKAGE_TYPE="tar"
DO_TEST=false
DO_DEPLOY=false
DO_QT_DEPLOY=false
VERBOSE=false

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--clean)
            DO_CLEAN=true
            shift
            ;;
        -t|--type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        -j|--jobs)
            JOBS="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --cmake-args)
            CMAKE_ARGS="$2"
            shift 2
            ;;
        --make-args)
            MAKE_ARGS="$2"
            shift 2
            ;;
        --toolchain)
            TOOLCHAIN_FILE="$2"
            shift 2
            ;;
        --install)
            DO_INSTALL=true
            shift
            ;;
        --install-prefix)
            INSTALL_PREFIX="$2"
            shift 2
            ;;
        --package)
            DO_PACKAGE=true
            shift
            ;;
        --package-type)
            PACKAGE_TYPE="$2"
            shift 2
            ;;
        --test)
            DO_TEST=true
            shift
            ;;
        --deploy)
            DO_DEPLOY=true
            shift
            ;;
        --qt-deploy)
            DO_QT_DEPLOY=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -*)
            log_error "未知选项: $1"
            exit 1
            ;;
        *)
            PROJECT_DIR="$1"
            shift
            ;;
    esac
done

# 如果没有指定项目目录，使用当前目录
if [[ -z "$PROJECT_DIR" ]]; then
    PROJECT_DIR=$(pwd)
fi

# 转换为绝对路径
PROJECT_DIR=$(realpath "$PROJECT_DIR")
OUTPUT_DIR="$PROJECT_DIR/$OUTPUT_DIR"

log_info "Universal ARM64 Cross-Compilation Build Script"
log_info "================================================"
log_info "项目目录: $PROJECT_DIR"
log_info "构建目录: $OUTPUT_DIR"
log_info "构建类型: $BUILD_TYPE"
log_info "并行作业: $JOBS"
log_info "工具链文件: $TOOLCHAIN_FILE"

# 检查项目目录
if [[ ! -d "$PROJECT_DIR" ]]; then
    log_error "项目目录不存在: $PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR"

# 检测项目类型
detect_project_type() {
    if [[ -f "CMakeLists.txt" ]]; then
        echo "cmake"
    elif [[ -f "meson.build" ]]; then
        echo "meson"
    elif [[ -f "configure.ac" || -f "configure.in" || -f "Makefile.am" ]]; then
        echo "autotools"
    elif [[ -f "Makefile" ]]; then
        echo "make"
    elif ls *.pro >/dev/null 2>&1; then
        echo "qmake"
    else
        echo "unknown"
    fi
}

PROJECT_TYPE=$(detect_project_type)
log_info "检测到项目类型: $PROJECT_TYPE"

# 清理构建目录
if [[ "$DO_CLEAN" == true && -d "$OUTPUT_DIR" ]]; then
    log_step "清理构建目录..."
    rm -rf "$OUTPUT_DIR"
fi

# 创建构建目录
mkdir -p "$OUTPUT_DIR"

# 设置环境变量
export CC=aarch64-linux-gnu-gcc
export CXX=aarch64-linux-gnu-g++
export AR=aarch64-linux-gnu-ar
export STRIP=aarch64-linux-gnu-strip
export RANLIB=aarch64-linux-gnu-ranlib
export PKG_CONFIG_PATH="/usr/lib/aarch64-linux-gnu/pkgconfig:/opt/arm64-libs/lib/pkgconfig"

# 根据项目类型构建
case $PROJECT_TYPE in
    cmake)
        log_step "配置CMake项目..."
        cd "$OUTPUT_DIR"
        
        CMAKE_CMD="cmake"
        CMAKE_CMD="$CMAKE_CMD -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_FILE"
        CMAKE_CMD="$CMAKE_CMD -DCMAKE_BUILD_TYPE=$BUILD_TYPE"
        CMAKE_CMD="$CMAKE_CMD -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX"
        
        if [[ -n "$CMAKE_ARGS" ]]; then
            CMAKE_CMD="$CMAKE_CMD $CMAKE_ARGS"
        fi
        
        CMAKE_CMD="$CMAKE_CMD .."
        
        log_debug "CMake命令: $CMAKE_CMD"
        eval $CMAKE_CMD
        
        log_step "构建项目..."
        make -j$JOBS $MAKE_ARGS
        ;;
        
    meson)
        log_step "配置Meson项目..."
        meson setup "$OUTPUT_DIR" \
            --cross-file /usr/share/meson/cross/aarch64-linux-gnu \
            --buildtype=$BUILD_TYPE \
            --prefix=$INSTALL_PREFIX
        
        log_step "构建项目..."
        cd "$OUTPUT_DIR"
        ninja -j$JOBS
        ;;
        
    qmake)
        log_step "配置QMake项目..."
        cd "$OUTPUT_DIR"
        
        # 检查Qt版本
        if [[ -d "/opt/qt5-arm64" ]]; then
            QMAKE="/opt/qt5-arm64/bin/qmake"
        elif [[ -d "/opt/qt6-arm64" ]]; then
            QMAKE="/opt/qt6-arm64/bin/qmake"
        else
            log_error "未找到Qt安装"
            exit 1
        fi
        
        $QMAKE ..
        make -j$JOBS $MAKE_ARGS
        ;;
        
    autotools)
        log_step "配置Autotools项目..."
        if [[ ! -f "configure" ]]; then
            if [[ -f "autogen.sh" ]]; then
                ./autogen.sh
            elif [[ -f "bootstrap" ]]; then
                ./bootstrap
            else
                autoreconf -fiv
            fi
        fi
        
        mkdir -p "$OUTPUT_DIR"
        cd "$OUTPUT_DIR"
        
        ../configure \
            --host=aarch64-linux-gnu \
            --prefix=$INSTALL_PREFIX \
            CC=aarch64-linux-gnu-gcc \
            CXX=aarch64-linux-gnu-g++
        
        log_step "构建项目..."
        make -j$JOBS $MAKE_ARGS
        ;;
        
    make)
        log_step "构建Make项目..."
        make -j$JOBS $MAKE_ARGS \
            CC=aarch64-linux-gnu-gcc \
            CXX=aarch64-linux-gnu-g++
        ;;
        
    *)
        log_error "未知的项目类型，无法自动构建"
        exit 1
        ;;
esac

log_info "构建完成！"

# 运行测试
if [[ "$DO_TEST" == true ]]; then
    log_step "运行测试..."
    cd "$OUTPUT_DIR"
    case $PROJECT_TYPE in
        cmake)
            ctest -j$JOBS
            ;;
        meson)
            ninja test
            ;;
        *)
            log_warn "当前项目类型不支持自动测试"
            ;;
    esac
fi

# 安装
if [[ "$DO_INSTALL" == true ]]; then
    log_step "安装项目..."
    cd "$OUTPUT_DIR"
    case $PROJECT_TYPE in
        cmake|autotools|make)
            make install
            ;;
        meson)
            ninja install
            ;;
        qmake)
            make install
            ;;
    esac
fi

# Qt部署
if [[ "$DO_QT_DEPLOY" == true ]]; then
    log_step "Qt应用部署..."
    cd "$OUTPUT_DIR"
    
    # 查找可执行文件
    EXECUTABLE=$(find . -type f -executable -not -path "./CMakeFiles/*" -not -name "*.so*" | head -1)
    
    if [[ -n "$EXECUTABLE" ]]; then
        log_info "部署可执行文件: $EXECUTABLE"
        
        # 创建AppDir结构
        mkdir -p AppDir/usr/bin
        cp "$EXECUTABLE" AppDir/usr/bin/
        
        # 使用linuxdeploy部署
        /usr/local/bin/linuxdeploy \
            --appdir AppDir \
            --plugin qt \
            --executable "$EXECUTABLE"
            
        if [[ "$PACKAGE_TYPE" == "appimage" ]]; then
            /usr/local/bin/linuxdeploy \
                --appdir AppDir \
                --output appimage
        fi
    else
        log_warn "未找到可执行文件进行部署"
    fi
fi

# 创建包
if [[ "$DO_PACKAGE" == true ]]; then
    log_step "创建安装包..."
    cd "$OUTPUT_DIR"
    
    case $PACKAGE_TYPE in
        deb)
            cpack -G DEB
            ;;
        rpm)
            cpack -G RPM
            ;;
        tar)
            cpack -G TGZ
            ;;
        *)
            log_warn "不支持的包类型: $PACKAGE_TYPE"
            ;;
    esac
fi

log_info "==============================================="
log_info "构建过程完成！"
log_info "构建目录: $OUTPUT_DIR"

if [[ "$DO_INSTALL" == true ]]; then
    log_info "安装目录: $INSTALL_PREFIX"
fi

if [[ "$DO_PACKAGE" == true ]]; then
    log_info "查找生成的包文件:"
    find "$OUTPUT_DIR" -name "*.deb" -o -name "*.rpm" -o -name "*.tar.gz" -o -name "*.AppImage" 2>/dev/null || true
fi
