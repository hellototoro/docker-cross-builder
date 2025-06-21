# 通用ARM64交叉编译Docker容器

这是一个功能强大的通用ARM64交叉编译Docker容器，支持多种项目类型和库的交叉编译。

## 特性

- **基于Ubuntu 22.04**，提供稳定的构建环境
- **完整的ARM64工具链**：aarch64-linux-gnu-gcc/g++
- **多种项目类型支持**：CMake、QMake、Autotools、Meson、Make
- **丰富的预安装库**：OpenGL、X11、音频、网络、图像处理等ARM64版本
- **智能构建脚本**：自动检测项目类型并选择合适的构建方法
- **包管理器**：方便安装和管理ARM64库
- **Qt支持**：可以轻松集成Qt5/Qt6进行GUI应用开发
- **部署工具**：集成linuxdeploy和AppImage打包工具

## 快速开始

### 1. 构建容器

```bash
# 使用新的通用Dockerfile
docker build -f Dockerfile.universal -t universal-cross-builder .

# 或使用docker-compose
docker-compose -f docker-compose-universal.yml build
```

### 2. 运行容器

```bash
# 直接运行
docker run -it --rm \
  -v $(pwd)/workspace:/workspace \
  -v $(pwd)/output:/output \
  universal-cross-builder

# 使用docker-compose
docker-compose -f docker-compose-universal.yml up -d
docker-compose -f docker-compose-universal.yml exec cross-builder bash
```

### 3. 构建项目

容器启动后，可以使用内置的构建脚本：

```bash
# 自动检测项目类型并构建
build-universal.sh /path/to/your/project

# 指定构建类型和选项
build-universal.sh -t Release -j 8 --install /path/to/project

# 构建并创建AppImage包
build-universal.sh --qt-deploy --package-type appimage /path/to/qt-project

# 显示帮助
build-universal.sh --help
```

## 支持的项目类型

### CMake项目
```bash
build-universal.sh /path/to/cmake-project
```

### Qt项目（QMake）
```bash
# 确保已安装Qt
package-manager.sh install-qt5 5.15
build-universal.sh /path/to/qt-project
```

### Autotools项目
```bash
build-universal.sh /path/to/autotools-project
```

### Meson项目
```bash
build-universal.sh /path/to/meson-project
```

### 普通Makefile项目
```bash
build-universal.sh /path/to/makefile-project
```

## 库管理

使用内置的包管理器安装和管理ARM64库：

```bash
# 搜索包
package-manager.sh search opencv

# 安装APT包
package-manager.sh install libopencv-dev:arm64

# 安装特殊库
package-manager.sh install-qt5 5.15
package-manager.sh install-opencv 4.6.0
package-manager.sh install-boost 1.78.0

# 从源码构建
package-manager.sh build-from-source eigen 3.4.0

# 显示帮助
package-manager.sh --help
```

## 预编译库集成

### 从主机复制预编译库

1. 将预编译的库放在主机的`prebuilt-libs`目录中：
```
prebuilt-libs/
├── qt5-arm64/
├── boost-arm64/
├── opencv-arm64/
└── custom-libs/
```

2. 修改Dockerfile.universal，取消注释相关的COPY指令：
```dockerfile
COPY ./prebuilt-libs/qt5-arm64 /opt/qt5-arm64/
COPY ./prebuilt-libs/boost-arm64 /opt/boost-arm64/
```

3. 重新构建容器

### 通过挂载卷使用

在运行容器时挂载主机的库目录：
```bash
docker run -it --rm \
  -v $(pwd)/workspace:/workspace \
  -v /host/path/to/qt5-arm64:/opt/qt5-arm64:ro \
  universal-cross-builder
```

## 环境变量

容器已预设了以下环境变量：

- `CC=aarch64-linux-gnu-gcc`
- `CXX=aarch64-linux-gnu-g++`
- `AR=aarch64-linux-gnu-ar`
- `STRIP=aarch64-linux-gnu-strip`
- `PKG_CONFIG_PATH` - 包含ARM64库的pkgconfig路径
- `CMAKE_PREFIX_PATH` - 包含所有可选库的路径

## CMake工具链

使用提供的CMake工具链文件：

```bash
cmake -DCMAKE_TOOLCHAIN_FILE=/usr/share/cmake/Toolchains/arm64-toolchain.cmake ..
```

或者设置环境变量：
```bash
export CMAKE_TOOLCHAIN_FILE=/usr/share/cmake/Toolchains/arm64-toolchain.cmake
cmake ..
```

## 示例项目

### 简单的C++项目

```bash
# 创建项目目录
mkdir -p workspace/hello-world
cd workspace/hello-world

# 创建源文件
cat > main.cpp << EOF
#include <iostream>
int main() {
    std::cout << "Hello, ARM64 World!" << std::endl;
    return 0;
}
EOF

# 创建CMakeLists.txt
cat > CMakeLists.txt << EOF
cmake_minimum_required(VERSION 3.16)
project(HelloWorld)
set(CMAKE_CXX_STANDARD 17)
add_executable(hello-world main.cpp)
EOF

# 构建
build-universal.sh .
```

### Qt应用项目

```bash
# 安装Qt5
package-manager.sh install-qt5

# 构建Qt项目
build-universal.sh --qt-deploy --package-type appimage /path/to/qt-project
```

## 高级配置

### 自定义工具链

可以创建自己的工具链文件并通过`--toolchain`参数使用：

```bash
build-universal.sh --toolchain /path/to/custom-toolchain.cmake /path/to/project
```

### 并行构建

利用多核CPU加速构建：

```bash
build-universal.sh -j $(nproc) /path/to/project
```

### 调试构建

```bash
build-universal.sh -t Debug --cmake-args "-DCMAKE_VERBOSE_MAKEFILE=ON" /path/to/project
```

## 故障排除

### 常见问题

1. **找不到库文件**
   - 检查`PKG_CONFIG_PATH`是否正确设置
   - 确认库已正确安装到ARM64版本

2. **交叉编译器未找到**
   - 确认容器正确构建
   - 检查环境变量设置

3. **Qt应用无法运行**
   - 使用`--qt-deploy`选项进行部署
   - 检查Qt插件和库是否正确打包

### 调试技巧

```bash
# 检查交叉编译器
aarch64-linux-gnu-gcc --version

# 检查库安装
ls -la /usr/aarch64-linux-gnu/lib/

# 检查pkg-config
pkg-config --list-all | grep -i qt

# 验证二进制文件架构
file build-arm64/your-executable
```

## 贡献

欢迎提交Issue和Pull Request来改进这个项目。

## 许可证

MIT License
