# Universal ARM64 Cross-Compilation Toolchain
# 通用ARM64交叉编译工具链文件
# 
# 使用方法:
# cmake -DCMAKE_TOOLCHAIN_FILE=/usr/share/cmake/Toolchains/arm64-toolchain.cmake ..
# 或者设置环境变量: export CMAKE_TOOLCHAIN_FILE=/usr/share/cmake/Toolchains/arm64-toolchain.cmake

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# 指定交叉编译器
set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)
set(CMAKE_ASM_COMPILER aarch64-linux-gnu-gcc)

# 设置工具链工具
set(CMAKE_AR aarch64-linux-gnu-ar)
set(CMAKE_LINKER aarch64-linux-gnu-ld)
set(CMAKE_NM aarch64-linux-gnu-nm)
set(CMAKE_OBJCOPY aarch64-linux-gnu-objcopy)
set(CMAKE_OBJDUMP aarch64-linux-gnu-objdump)
set(CMAKE_STRIP aarch64-linux-gnu-strip)
set(CMAKE_RANLIB aarch64-linux-gnu-ranlib)

# 设置编译器标志
set(CMAKE_C_FLAGS_INIT "-march=armv8-a")
set(CMAKE_CXX_FLAGS_INIT "-march=armv8-a")

# 设置根路径用于查找库和头文件
set(CMAKE_FIND_ROOT_PATH 
    /usr/aarch64-linux-gnu
    /opt/arm64-libs
    /opt/qt5-arm64
    /opt/qt6-arm64
    /opt/boost-arm64
    /opt/opencv-arm64
    /opt/custom-libs
)

# 搜索模式设置
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)  # 不在目标系统中搜索程序
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)   # 只在目标系统中搜索库
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)   # 只在目标系统中搜索头文件
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)   # 只在目标系统中搜索包

# 设置PKG_CONFIG
set(ENV{PKG_CONFIG_LIBDIR} "/usr/lib/aarch64-linux-gnu/pkgconfig")
set(ENV{PKG_CONFIG_PATH} "/usr/lib/aarch64-linux-gnu/pkgconfig:/opt/arm64-libs/lib/pkgconfig:/opt/qt5-arm64/lib/pkgconfig:/opt/qt6-arm64/lib/pkgconfig")

# Qt配置 (如果有Qt库)
if(EXISTS "/opt/qt5-arm64/lib/cmake/Qt5")
    set(Qt5_DIR "/opt/qt5-arm64/lib/cmake/Qt5")
    list(APPEND CMAKE_PREFIX_PATH "/opt/qt5-arm64")
endif()

if(EXISTS "/opt/qt6-arm64/lib/cmake/Qt6")
    set(Qt6_DIR "/opt/qt6-arm64/lib/cmake/Qt6")
    list(APPEND CMAKE_PREFIX_PATH "/opt/qt6-arm64")
endif()

# Boost配置 (如果有Boost库)
if(EXISTS "/opt/boost-arm64")
    set(BOOST_ROOT "/opt/boost-arm64")
    set(Boost_NO_SYSTEM_PATHS ON)
endif()

# OpenCV配置 (如果有OpenCV库)
if(EXISTS "/opt/opencv-arm64")
    set(OpenCV_DIR "/opt/opencv-arm64/lib/cmake/opencv4")
endif()

# 设置一些常用的编译选项
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")

# 针对ARM64优化
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mtune=cortex-a72")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mtune=cortex-a72")

# 调试信息设置
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -g -O0")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g -O0")

# 发布版本优化
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -O3 -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -DNDEBUG")

# 禁用一些可能有问题的优化
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-strict-aliasing")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-strict-aliasing")

# 设置RPATH
set(CMAKE_BUILD_RPATH_USE_ORIGIN TRUE)
set(CMAKE_INSTALL_RPATH "\$ORIGIN:\$ORIGIN/../lib")

message(STATUS "ARM64 Cross-Compilation Toolchain Loaded")
message(STATUS "Target System: ${CMAKE_SYSTEM_NAME}")
message(STATUS "Target Processor: ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "C Compiler: ${CMAKE_C_COMPILER}")
message(STATUS "CXX Compiler: ${CMAKE_CXX_COMPILER}")
