# Xcode File Manager - VS Code Extension

## 项目概述

这是一个 Visual Studio Code 扩展，用于在 VS Code 中直接管理 Xcode 项目文件和文件夹。它集成了现有的 Ruby 脚本（`new_xcode_file.rb` 和 `add_to_xcodeproj.rb`），提供了友好的图形界面和右键菜单操作。

## 主要功能

### 1. 添加文件到 Xcode 项目
- 右键点击任何文件即可添加到 Xcode 项目
- 自动识别文件类型并添加到正确的构建阶段

### 2. 添加文件夹到 Xcode 项目
- 右键点击文件夹，递归添加所有文件
- 保留文件夹层级结构

### 3. 创建新的 Objective-C 文件
- 从命令面板创建新文件
- 支持的基类：
  - UIViewController
  - NSObject
  - UIView
  - UITableViewCell
- 自动生成 .h 和 .m 文件
- 自动添加到 Xcode 项目

### 4. 创建新文件夹
- 创建文件夹并添加到 Xcode 项目
- 支持嵌套目录结构

## 技术栈

- **前端**: TypeScript
- **运行时**: Node.js
- **后端脚本**: Ruby
- **依赖**: xcodeproj gem

## 项目结构

```
vscode-xcode-manager/
├── src/
│   ├── extension.ts              # 扩展入口文件
│   ├── commands/
│   │   └── xcodeCommands.ts      # 命令实现
│   └── scripts/
│       ├── new_xcode_file.rb     # 创建文件脚本
│       └── add_to_xcodeproj.rb   # 添加文件脚本
├── templates/
│   └── objc/
│       └── cocoa_touch/          # Objective-C 模板
├── out/                          # 编译输出
├── package.json                  # 扩展配置
├── tsconfig.json                 # TypeScript 配置
└── README.md                     # 文档

```

## 快速开始

### 安装依赖

```bash
# 安装 Ruby（macOS）
brew install ruby

# 安装 xcodeproj gem
gem install xcodeproj

# 安装 Node.js 依赖
cd vscode-xcode-manager
npm install
```

### 开发模式

```bash
# 编译 TypeScript
npm run compile

# 或监听模式
npm run watch

# 在 VS Code 中按 F5 启动调试
```

### 打包安装

```bash
# 使用提供的构建脚本
./build.sh

# 或手动打包
npm install -g vsce
vsce package

# 生成的 .vsix 文件可以在 VS Code 中安装
```

## 使用方法

### 添加现有文件

1. 在 VS Code 资源管理器中右键点击文件
2. 选择 "Add File to Xcode"
3. 完成！

### 添加文件夹

1. 右键点击文件夹
2. 选择 "Add Folder to Xcode"
3. 所有文件递归添加

### 创建新文件

1. 按 `Cmd+Shift+P` 打开命令面板
2. 输入 "Create File and Add to Xcode"
3. 输入类名（如 `MyViewController`）
4. 选择基类
5. 选择输出目录
6. 完成！.h 和 .m 文件已创建并添加到 Xcode

## 文档

- [README.md](README.md) - 项目介绍和功能说明
- [INSTALLATION.md](INSTALLATION.md) - 详细安装指南
- [QUICKSTART.md](QUICKSTART.md) - 快速入门教程
- [TESTING.md](TESTING.md) - 测试指南
- [CHANGELOG.md](CHANGELOG.md) - 更新日志

## 关键特性

### 自动化工作流
- 无需手动在 Xcode 中添加文件
- 自动识别文件类型
- 自动添加到正确的构建阶段

### 模板系统
- 预定义的 Objective-C 模板
- 支持多种基类
- 可扩展的模板系统

### 智能处理
- 防止重复添加
- 文件已存在时跳过
- 自动创建父目录组

### 用户友好
- 右键菜单集成
- 清晰的提示消息
- 输入验证

## 命令列表

| 命令 | 描述 | 触发方式 |
|------|------|---------|
| `extension.addFileToXcode` | 添加文件到 Xcode | 右键菜单 |
| `extension.addFolderToXcode` | 添加文件夹到 Xcode | 右键菜单 |
| `extension.createFileAndAddToXcode` | 创建新文件 | 命令面板 |
| `extension.createFolderAndAddToXcode` | 创建新文件夹 | 命令面板 |

## 配置

此扩展无需额外配置，自动在工作区中查找 `.xcodeproj` 文件。

## 限制和已知问题

- 目前仅支持 Objective-C 文件
- 需要安装 Ruby 和 xcodeproj gem
- 仅在包含 Xcode 项目的工作区中有效

## 未来计划

- [ ] 支持 Swift 文件
- [ ] 支持更多文件模板
- [ ] 自定义模板功能
- [ ] 批量操作优化
- [ ] 更好的错误提示
- [ ] 多 Xcode 项目支持

## 贡献

欢迎提交问题和拉取请求！

## 许可证

MIT License

## 作者

Created for FigmaUIToCodeDemo project - 2026

---

## 开发笔记

### 核心实现

1. **TypeScript 命令层** (`src/commands/xcodeCommands.ts`)
   - 处理用户输入
   - 验证参数
   - 调用 Ruby 脚本
   - 显示结果

2. **Ruby 脚本层** (`src/scripts/*.rb`)
   - 文件生成逻辑
   - Xcode 项目操作
   - 使用 xcodeproj gem

3. **模板系统** (`templates/`)
   - 可替换的占位符
   - 支持多种文件类型

### 关键技术决策

- 使用 Ruby 而非纯 TypeScript：xcodeproj gem 是最成熟的 Xcode 项目操作库
- 异步执行：使用 `child_process` 的 `execFile` 与 promisify
- 用户体验：右键菜单 + 命令面板双重入口

### 调试技巧

```bash
# 查看扩展日志
# VS Code -> Help -> Toggle Developer Tools -> Console

# 测试 Ruby 脚本
ruby src/scripts/new_xcode_file.rb TestClass UIViewController /path/to/output /path/to/templates

# 检查编译输出
cat out/extension.js
```

## 总结

这个扩展成功地将现有的 Ruby 脚本集成到 VS Code 中，提供了流畅的用户体验。通过右键菜单和命令面板，开发者可以轻松管理 Xcode 项目文件，无需在两个 IDE 之间切换。
