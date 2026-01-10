# Quick Start Guide

## 🚀 Getting Started

This guide will help you quickly start using the Xcode File Manager extension.

## 📋 Prerequisites Checklist

- [ ] Ruby installed (`ruby -v` should work)
- [ ] xcodeproj gem installed (`gem install xcodeproj`)
- [ ] Xcode project in your workspace (`.xcodeproj` file)

## 🎯 Common Tasks

### Adding an Existing File to Xcode

1. In VS Code Explorer, find the file you want to add
2. **Right-click** on the file
3. Select **"Add File to Xcode"**
4. Done! The file is now in your Xcode project

### Adding a Folder to Xcode

1. In VS Code Explorer, find the folder
2. **Right-click** on the folder
3. Select **"Add Folder to Xcode"**
4. All files in the folder are added recursively

### Creating a New View Controller

1. Press `Cmd+Shift+P` (macOS) or `Ctrl+Shift+P` (Windows/Linux)
2. Type: `Create File and Add to Xcode`
3. Enter class name: `MyViewController`
4. Select base class: `UIViewController`
5. Enter output directory: `FigmaUIToCodeDemo/FigmaUIToCodeDemo`
6. Done! Both `.h` and `.m` files are created and added to Xcode

### Creating a New Custom View

Same as above, but:
- Class name: `MyCustomView`
- Base class: `UIView`

### Creating a New Model Class

Same as above, but:
- Class name: `MyModel`
- Base class: `NSObject`

## 📁 Recommended Workflow

### For New Features:

1. Create a folder for the feature:
   ```
   Cmd+Shift+P → "Create Folder and Add to Xcode"
   Folder name: "Login"
   Parent: "FigmaUIToCodeDemo/FigmaUIToCodeDemo"
   ```

2. Create view controller:
   ```
   Cmd+Shift+P → "Create File and Add to Xcode"
   Class: "LoginViewController"
   Base: "UIViewController"
   Output: "FigmaUIToCodeDemo/FigmaUIToCodeDemo/Login"
   ```

3. Create custom views as needed:
   ```
   Class: "LoginButton"
   Base: "UIView"
   Output: "FigmaUIToCodeDemo/FigmaUIToCodeDemo/Login"
   ```

## 🔧 Tips

- **Tab completion** works in directory input fields (when running from terminal)
- Files are automatically added to the appropriate build phase (.m → Sources, .xib → Resources)
- The extension finds your `.xcodeproj` automatically (searches up to 5 levels)
- If a file already exists, it won't be overwritten

## ⚠️ Important Notes

- Always make sure your Xcode project is closed or saved before adding files
- The extension modifies your `.xcodeproj` file directly
- Consider using version control (git) to track changes

## 🆘 Need Help?

Check the troubleshooting section in [INSTALLATION.md](INSTALLATION.md)

## 📝 Example Directory Structure

After using the extension, your project might look like:

```
FigmaUIToCodeDemo/
├── FigmaUIToCodeDemo/
│   ├── AppDelegate.h
│   ├── AppDelegate.m
│   ├── SceneDelegate.h
│   ├── SceneDelegate.m
│   ├── Login/                    ← Created via extension
│   │   ├── LoginViewController.h ← Created via extension
│   │   ├── LoginViewController.m ← Created via extension
│   │   ├── LoginButton.h         ← Created via extension
│   │   └── LoginButton.m         ← Created via extension
│   └── Home/                     ← Created via extension
│       ├── HomeViewController.h
│       └── HomeViewController.m
└── FigmaUIToCodeDemo.xcodeproj/
```

## 🎉 You're Ready!

Start adding and creating files in your Xcode project directly from VS Code!
