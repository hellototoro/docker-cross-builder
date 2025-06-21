# 通用ARM64交叉编译Docker容器项目

## 项目结构

```
.
├── Dockerfile              # 主Dockerfile（功能完整版）
├── Dockerfile.lite         # 轻量级版本
├── docker-compose.yml      # Docker Compose配置
├── arm64-toolchain.cmake   # CMake工具链文件
├── build-universal.sh      # 通用构建脚本
├── package-manager.sh      # 包管理脚本
├── quick-start.sh          # 快速启动脚本
├── sources.list            # APT源配置
├── workspace/              # 项目工作目录
├── output/                 # 构建输出目录
└── prebuilt-libs/          # 预编译库目录（可选）
    ├── qt5-arm64/
    ├── qt6-arm64/
    ├── boost-arm64/
    └── opencv-arm64/
```

## 快速开始

1. 克隆项目：
```bash
git clone https://github.com/your-username/universal-arm64-cross-builder.git
cd universal-arm64-cross-builder
```

2. 一键启动：
```bash
./quick-start.sh
```

3. 开始构建项目：
```bash
# 在容器内
build-universal.sh /path/to/your/project
```

详细使用说明请参考 [README.md](README.md)。
