# Universal Cross-Compilation Container for ARM64
# 通用ARM64交叉编译容器
FROM ubuntu:22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV CROSS_COMPILE=aarch64-linux-gnu-
ENV ARCH=arm64
ENV LANG=C.UTF-8

# 启用多架构支持
RUN dpkg --add-architecture arm64

# 复制源列表配置
COPY sources.list /etc/apt/sources.list

# 更新包管理器缓存
RUN apt-get update && apt-get upgrade -y

# ============================================================================
# 安装基础开发工具
# ============================================================================
RUN apt-get install -y \
    # 基础工具
    build-essential \
    wget \
    curl \
    git \
    unzip \
    tar \
    gzip \
    xz-utils \
    vim \
    nano \
    tree \
    file \
    rsync \
    ssh \
    ca-certificates \
    software-properties-common \
    gnupg \
    lsb-release \
    # 编译工具
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    gcc-aarch64-linux-gnu-base \
    libc6-dev-arm64-cross \
    linux-libc-dev-arm64-cross \
    # 构建系统
    ninja-build \
    make \
    autoconf \
    automake \
    libtool \
    pkg-config \
    # Python工具
    python3 \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    # 版本控制
    git-lfs \
    subversion \
    # 调试工具
    gdb-multiarch \
    strace \
    ltrace \
    valgrind

# ============================================================================
# 安装常用开发库 (arm64版本)
# ============================================================================
RUN apt-get install -y \
    # 系统库
    libc6-dev:arm64 \
    libgcc-s1:arm64 \
    libstdc++6:arm64 \
    # 图像处理库
    libpng-dev:arm64 \
    libjpeg-dev:arm64 \
    libtiff-dev:arm64 \
    libwebp-dev:arm64 \
    libavcodec-dev:arm64 \
    libavformat-dev:arm64 \
    libavutil-dev:arm64 \
    libswscale-dev:arm64 \
    # OpenGL/图形库
    libgl1-mesa-dev:arm64 \
    libglu1-mesa-dev:arm64 \
    libegl1-mesa-dev:arm64 \
    libgles2-mesa-dev:arm64 \
    libdrm-dev:arm64 \
    # X11库
    libx11-dev:arm64 \
    libxext-dev:arm64 \
    libxrender-dev:arm64 \
    libxrandr-dev:arm64 \
    libxinerama-dev:arm64 \
    libxcursor-dev:arm64 \
    libxfixes-dev:arm64 \
    libxi-dev:arm64 \
    libxss-dev:arm64 \
    libxtst-dev:arm64 \
    libxkbcommon-dev:arm64 \
    libxkbcommon-x11-dev:arm64 \
    # 音频库
    libasound2-dev:arm64 \
    libpulse-dev:arm64 \
    # 网络库
    libssl-dev:arm64 \
    libcurl4-openssl-dev:arm64 \
    # 压缩库
    zlib1g-dev:arm64 \
    libbz2-dev:arm64 \
    liblzma-dev:arm64 \
    # 数据库
    libsqlite3-dev:arm64 \
    # 国际化
    libicu-dev:arm64 \
    # 正则表达式
    libpcre2-dev:arm64 \
    libpcre3-dev:arm64 \
    # 字体库
    libfontconfig1-dev:arm64 \
    libfreetype6-dev:arm64 \
    # 其他常用库
    libglib2.0-dev:arm64 \
    libdbus-1-dev:arm64 \
    libudev-dev:arm64 \
    libusb-1.0-0-dev:arm64 \
    libxml2-dev:arm64 \
    libxslt1-dev:arm64

# ============================================================================
# 可选：从主机复制预编译的Qt或其他库
# ============================================================================
# 创建可选的挂载点目录
RUN mkdir -p /opt/arm64-libs \
    /opt/qt5-arm64 \
    /opt/qt6-arm64 \
    /opt/boost-arm64 \
    /opt/opencv-arm64 \
    /opt/custom-libs

# 如果主机有预编译的库，可以通过以下方式复制：
# COPY ./prebuilt-libs/qt5-arm64 /opt/qt5-arm64/
# COPY ./prebuilt-libs/boost-arm64 /opt/boost-arm64/
# COPY ./prebuilt-libs/opencv-arm64 /opt/opencv-arm64/

# ============================================================================
# 安装额外的构建工具
# ============================================================================
# 安装最新版本的CMake
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | \
    gpg --dearmor - | \
    tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null && \
    apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" && \
    apt-get update && \
    apt-get install -y cmake

# 安装Conan包管理器 (可选)
RUN pip3 install conan

# 安装vcpkg (可选) - 注释掉，因为会增加镜像大小
# RUN git clone https://github.com/Microsoft/vcpkg.git /opt/vcpkg && \
#     cd /opt/vcpkg && \
#     ./bootstrap-vcpkg.sh

# ============================================================================
# 配置交叉编译环境
# ============================================================================
# 设置环境变量
ENV AR=aarch64-linux-gnu-ar \
    CC=aarch64-linux-gnu-gcc \
    CXX=aarch64-linux-gnu-g++ \
    LINK=aarch64-linux-gnu-g++ \
    STRIP=aarch64-linux-gnu-strip \
    RANLIB=aarch64-linux-gnu-ranlib \
    OBJCOPY=aarch64-linux-gnu-objcopy \
    OBJDUMP=aarch64-linux-gnu-objdump \
    NM=aarch64-linux-gnu-nm \
    AS=aarch64-linux-gnu-as \
    LD=aarch64-linux-gnu-ld

# PKG_CONFIG配置
ENV PKG_CONFIG_PATH="/usr/lib/aarch64-linux-gnu/pkgconfig:/opt/arm64-libs/lib/pkgconfig:/opt/qt5-arm64/lib/pkgconfig:/opt/qt6-arm64/lib/pkgconfig"
ENV PKG_CONFIG_LIBDIR="/usr/lib/aarch64-linux-gnu/pkgconfig"

# CMAKE配置
ENV CMAKE_PREFIX_PATH="/usr/aarch64-linux-gnu:/opt/arm64-libs:/opt/qt5-arm64:/opt/qt6-arm64:/opt/boost-arm64:/opt/opencv-arm64"
ENV CMAKE_FIND_ROOT_PATH="/usr/aarch64-linux-gnu:/opt/arm64-libs"

# ============================================================================
# 安装部署工具
# ============================================================================
# 安装linuxdeploy和相关插件
RUN wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage -O /usr/local/bin/linuxdeploy && \
    chmod +x /usr/local/bin/linuxdeploy && \
    wget https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage -O /usr/local/bin/linuxdeploy-plugin-qt && \
    chmod +x /usr/local/bin/linuxdeploy-plugin-qt

# 安装AppImage工具
RUN wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -O /usr/local/bin/appimagetool && \
    chmod +x /usr/local/bin/appimagetool

# ============================================================================
# 复制构建脚本和工具链文件
# ============================================================================
# 创建工具链目录
RUN mkdir -p /usr/share/cmake/Toolchains

# 复制CMake工具链文件
COPY arm64-toolchain.cmake /usr/share/cmake/Toolchains/arm64-toolchain.cmake

# 复制通用构建脚本
COPY build-universal.sh /usr/local/bin/build-universal.sh
RUN chmod +x /usr/local/bin/build-universal.sh

# 复制包管理脚本
COPY package-manager.sh /usr/local/bin/package-manager.sh
RUN chmod +x /usr/local/bin/package-manager.sh

# ============================================================================
# 创建工作目录和用户
# ============================================================================
# 创建非root用户
RUN useradd -m -s /bin/bash -G sudo builder && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 创建工作目录
WORKDIR /workspace
RUN chown builder:builder /workspace

# 清理APT缓存以减小镜像大小
RUN apt-get autoremove -y && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*

# 创建构建信息文件
RUN echo "Universal ARM64 Cross-Compilation Container" > /etc/container-info && \
    echo "Built on: $(date)" >> /etc/container-info && \
    echo "Toolchain: aarch64-linux-gnu" >> /etc/container-info && \
    echo "Base OS: Ubuntu 22.04" >> /etc/container-info

# 设置默认用户
USER builder

# 显示欢迎信息
RUN echo 'echo "=== Universal ARM64 Cross-Compilation Container ==="' >> ~/.bashrc && \
    echo 'echo "Toolchain: aarch64-linux-gnu"' >> ~/.bashrc && \
    echo 'echo "Use build-universal.sh for building projects"' >> ~/.bashrc && \
    echo 'echo "Use package-manager.sh for managing libraries"' >> ~/.bashrc && \
    echo 'echo "Workspace: /workspace"' >> ~/.bashrc && \
    echo 'echo "Toolchain file: /usr/share/cmake/Toolchains/arm64-toolchain.cmake"' >> ~/.bashrc && \
    echo 'echo "=================================================="' >> ~/.bashrc

CMD ["/bin/bash"]
