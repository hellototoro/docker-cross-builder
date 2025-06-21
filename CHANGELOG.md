# 更新日志

## [1.0.0] - 2025-06-21

### 新增功能
- 基于Ubuntu 22.04的通用ARM64交叉编译容器
- 自动项目类型检测和构建脚本
- 多种构建系统支持：CMake、QMake、Autotools、Meson、Make
- ARM64包管理器，支持从源码构建常用库
- 集成linuxdeploy和AppImage打包工具
- 完整的CMake工具链文件
- 一键启动脚本
- 轻量级和完整版两种容器选择

### 支持的库
- Qt5/Qt6
- Boost
- OpenCV
- Eigen
- OpenSSL
- 图像处理库（libpng、libjpeg等）
- OpenGL/图形库
- X11库
- 音频库

### 文档
- 详细的使用文档
- 项目结构说明
- 贡献指南
- MIT许可证

## 即将到来的功能

- [ ] 支持更多架构（armv7、RISC-V）
- [ ] 预构建的常用库镜像
- [ ] CI/CD集成示例
- [ ] VS Code开发容器配置
- [ ] 性能优化和镜像大小减少
