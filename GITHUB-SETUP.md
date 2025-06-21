# 发布到GitHub指南

## 准备工作

1. 确保您已经有GitHub账户
2. 在GitHub上创建一个新的仓库

## 步骤

### 1. 在GitHub上创建仓库

1. 登录GitHub
2. 点击右上角的 "+" 按钮，选择 "New repository"
3. 填写仓库信息：
   - Repository name: `universal-arm64-cross-builder`
   - Description: `通用ARM64交叉编译Docker容器 - Universal ARM64 Cross-Compilation Docker Container`
   - 选择 Public 或 Private
   - 不要初始化README、.gitignore或license（因为我们本地已经有了）

### 2. 添加远程仓库并推送

```bash
# 添加远程仓库（替换为您的GitHub用户名）
git remote add origin https://github.com/YOUR_USERNAME/universal-arm64-cross-builder.git

# 推送到GitHub
git branch -M main
git push -u origin main
```

### 3. 设置仓库描述和主题

在GitHub仓库页面：

1. 点击设置按钮（⚙️）
2. 在About部分添加：
   - Description: `通用ARM64交叉编译Docker容器，支持多种项目类型和库的交叉编译`
   - Website: 如果有的话
   - Topics: `docker`, `cross-compilation`, `arm64`, `aarch64`, `cmake`, `qt`, `linux`

### 4. 创建Release（可选）

1. 在仓库页面点击 "Releases"
2. 点击 "Create a new release"
3. 填写版本号：`v1.0.0`
4. 标题：`首个正式版本`
5. 描述版本特性

## 维护

### 持续更新

```bash
# 进行更改后
git add .
git commit -m "描述更改内容"
git push origin main
```

### 版本标签

```bash
# 创建新版本标签
git tag -a v1.0.0 -m "版本 1.0.0"
git push origin v1.0.0
```

## 推荐的GitHub Actions

可以考虑添加CI/CD工作流来自动构建和测试Docker镜像。
