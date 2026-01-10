# 📚 Documentation Index

Welcome to the Xcode File Manager VS Code Extension documentation!

## 🚀 Getting Started

1. **[INSTALLATION.md](INSTALLATION.md)** - Complete installation guide
   - Prerequisites (Ruby, xcodeproj gem)
   - Installation methods
   - Troubleshooting

2. **[QUICKSTART.md](QUICKSTART.md)** - Quick start guide
   - Prerequisites checklist
   - Common tasks with examples
   - Recommended workflows
   - Tips and tricks

3. **[setup.sh](setup.sh)** - Automated setup script
   - Run this first: `./setup.sh`
   - Checks all dependencies
   - Installs and configures everything

## 📖 Using the Extension

4. **[README.md](README.md)** - Main documentation
   - Features overview
   - Usage instructions
   - Requirements
   - Known issues

5. **[QUICKSTART.md](QUICKSTART.md)** - Hands-on examples
   - Step-by-step tutorials
   - Common scenarios
   - Example workflows

## 🔧 Development & Technical

6. **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Project overview
   - Architecture
   - Technical stack
   - Project structure
   - Development notes

7. **[PACKAGE_CONFIG.md](PACKAGE_CONFIG.md)** - Package.json explained
   - Configuration details
   - Command definitions
   - Menu contributions
   - Publishing guide

8. **[TESTING.md](TESTING.md)** - Testing guide
   - Test cases
   - Manual testing procedures
   - Debug mode
   - Test checklist

## 📝 Reference

9. **[CHANGELOG.md](CHANGELOG.md)** - Version history
   - Release notes
   - New features
   - Bug fixes

10. **[tsconfig.json](tsconfig.json)** - TypeScript configuration
11. **[.eslintrc.js](.eslintrc.js)** - ESLint rules

## 🛠️ Build & Deploy

12. **[build.sh](build.sh)** - Build and package script
    - Creates .vsix file
    - For distribution

13. **[package.json](package.json)** - NPM package configuration
    - Dependencies
    - Scripts
    - Extension metadata

## 📂 Source Code

### TypeScript Source
- **[src/extension.ts](src/extension.ts)** - Extension entry point
- **[src/commands/xcodeCommands.ts](src/commands/xcodeCommands.ts)** - Command implementations

### Ruby Scripts
- **[src/scripts/new_xcode_file.rb](src/scripts/new_xcode_file.rb)** - Create new files
- **[src/scripts/add_to_xcodeproj.rb](src/scripts/add_to_xcodeproj.rb)** - Add to Xcode project

### Templates
- **[templates/objc/cocoa_touch/](templates/objc/cocoa_touch/)** - Objective-C templates
  - UIViewController
  - NSObject
  - UIView
  - UITableViewCell

## 🎯 Quick Navigation by Task

### I want to...

#### Install the extension
→ [INSTALLATION.md](INSTALLATION.md) → [setup.sh](setup.sh)

#### Learn how to use it
→ [QUICKSTART.md](QUICKSTART.md) → [README.md](README.md)

#### Develop/modify the extension
→ [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) → [src/](src/)

#### Test the extension
→ [TESTING.md](TESTING.md)

#### Build a package
→ [build.sh](build.sh)

#### Understand configuration
→ [PACKAGE_CONFIG.md](PACKAGE_CONFIG.md) → [package.json](package.json)

#### Add new templates
→ [templates/objc/cocoa_touch/](templates/objc/cocoa_touch/)

#### Modify commands
→ [src/commands/xcodeCommands.ts](src/commands/xcodeCommands.ts)

#### Change menu items
→ [package.json](package.json) (contributes.menus section)

## 🏗️ Project Structure

```
vscode-xcode-manager/
├── 📄 Documentation
│   ├── README.md              # Main docs
│   ├── QUICKSTART.md          # Quick start
│   ├── INSTALLATION.md        # Setup guide
│   ├── TESTING.md            # Test guide
│   ├── PROJECT_SUMMARY.md    # Technical overview
│   ├── PACKAGE_CONFIG.md     # Config guide
│   └── CHANGELOG.md          # Version history
│
├── 🛠️ Scripts
│   ├── setup.sh              # Setup automation
│   └── build.sh              # Build automation
│
├── 📦 Configuration
│   ├── package.json          # Extension config
│   ├── tsconfig.json         # TypeScript config
│   ├── .eslintrc.js          # Linter config
│   ├── .editorconfig         # Editor config
│   ├── .gitignore            # Git ignore
│   └── .vscodeignore         # Package ignore
│
├── 💻 Source Code
│   └── src/
│       ├── extension.ts                    # Entry point
│       ├── commands/xcodeCommands.ts       # Commands
│       └── scripts/
│           ├── new_xcode_file.rb          # Create files
│           └── add_to_xcodeproj.rb        # Add to Xcode
│
├── 📋 Templates
│   └── templates/objc/cocoa_touch/
│       ├── UIViewController/
│       ├── NSObject/
│       ├── UIView/
│       └── UITableViewCell/
│
├── ⚙️ VS Code Config
│   └── .vscode/
│       ├── launch.json       # Debug config
│       ├── tasks.json        # Build tasks
│       ├── settings.json     # Workspace settings
│       └── extensions.json   # Recommended extensions
│
└── 📦 Build Output
    ├── out/                  # Compiled JS
    └── node_modules/         # Dependencies
```

## 🎓 Learning Path

### For Users
1. Run `./setup.sh`
2. Read [QUICKSTART.md](QUICKSTART.md)
3. Try the examples
4. Read [README.md](README.md) for details

### For Developers
1. Read [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)
2. Review source code in [src/](src/)
3. Read [PACKAGE_CONFIG.md](PACKAGE_CONFIG.md)
4. Follow [TESTING.md](TESTING.md)
5. Build with `./build.sh`

### For Contributors
1. All of the above
2. Check [CHANGELOG.md](CHANGELOG.md) for version history
3. Follow existing code patterns
4. Add tests in [TESTING.md](TESTING.md)

## 🤝 Support

If you encounter issues:
1. Check [INSTALLATION.md](INSTALLATION.md) troubleshooting section
2. Review [TESTING.md](TESTING.md) for common problems
3. Open an issue with details

## 📄 License

MIT License - See project root for details

---

**Happy Coding! 🚀**

*Generated for FigmaUIToCodeDemo project - January 2026*
