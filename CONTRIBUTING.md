# 贡献指南

感谢您考虑为通用ARM64交叉编译Docker容器项目做出贡献！

## 如何贡献

### 报告问题

如果您发现了bug或有功能建议，请：

1. 在提交issue之前先搜索现有的issues
2. 使用清晰的标题和详细的描述
3. 提供复现步骤（如果是bug）
4. 包含您的环境信息（操作系统、Docker版本等）

### 提交代码

1. Fork此项目
2. 创建功能分支：`git checkout -b feature/amazing-feature`
3. 提交您的更改：`git commit -m 'Add amazing feature'`
4. 推送到分支：`git push origin feature/amazing-feature`
5. 提交Pull Request

### 代码规范

- 使用清晰的变量和函数名
- 添加适当的注释
- 遵循现有的代码风格
- 为新功能添加文档

### 测试

在提交之前，请确保：

- 您的更改不会破坏现有功能
- 新功能有适当的测试覆盖
- Docker镜像能够成功构建

## 开发环境设置

1. 克隆项目
2. 修改代码
3. 测试构建：`docker build -f Dockerfile -t test-image .`
4. 测试功能

感谢您的贡献！
