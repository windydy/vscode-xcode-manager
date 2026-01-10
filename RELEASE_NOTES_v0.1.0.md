# Release Notes - Xcode File Manager v0.1.0

## 🎉 Major Update

This release brings significant enhancements to the Xcode File Manager extension, including advanced file creation, smart framework detection, and batch deletion operations.

## ✨ New Features

### 📝 Enhanced File Creation

- **Multiple File Types Support**
  - Cocoa Touch Class with custom base class
  - Objective-C File (Empty, Category, Extension, Protocol)
  - Header File only

### 🏷️ Intelligent Category Support

- Automatic file naming: `ClassName+CategoryName`
- Smart system framework detection and import
- Support for lowercase category names (myCategory, MyCategory, etc.)

### 🎯 Custom Base Class

- Input any base class for Cocoa Touch files
- Not limited to UIViewController, UIView, UITableViewCell, NSObject
- Examples: CALayer, UIButton, UIControl, etc.

### 🔧 Smart System Framework Auto-Import

Automatically detects and imports the correct framework based on class prefix:

- **40+ Apple Frameworks Supported**
  - UIKit (UI\*)
  - Foundation (NS\*)
  - CoreGraphics (CG\*)
  - QuartzCore (CA\*)
  - ARKit (AR\*)
  - And many more...

### 🗑️ Delete Operations

- **Remove Reference**: Remove file/folder from Xcode only (keep file)
- **Move to Trash**: Delete file/folder and remove from Xcode
- **Batch Operations**: Select multiple files/folders
- Confirmation dialog with item preview

### 📦 Batch Operations

- Select multiple files or folders
- Process all in one operation
- Summary of successful and failed operations

## 🔄 Improvements

- Better validation for file and class names
- Enhanced user prompts with clear descriptions
- Improved error handling and messages
- Template fallback for custom base classes

## 🐛 Bug Fixes

- Fixed TypeScript type errors
- Fixed file name validation for category names with underscores
- Corrected import statement replacement in templates

## 📦 Installation

Install the extension from the `.vsix` file:

```bash
code --install-extension vscode-xcode-manager-0.1.0.vsix
```

Or install through VS Code:

1. Open VS Code
2. Go to Extensions (Cmd+Shift+X)
3. Click "..." menu → "Install from VSIX..."
4. Select `vscode-xcode-manager-0.1.0.vsix`

## 🚀 Usage Examples

### Create Category

1. Right-click in Explorer → "Create File and Add to Xcode"
2. Select "Objective-C File"
3. Enter category name (e.g., "Helper")
4. Select "Category"
5. Enter class to extend (e.g., "UIViewController")
6. Result: `UIViewController+Helper.h` and `.m` with `<UIKit/UIKit.h>` imported

### Batch Delete

1. Select multiple files (Cmd+Click)
2. Right-click → "Delete File and Remove from Xcode"
3. Confirm deletion
4. All selected files removed from Xcode and moved to trash

## 📝 Requirements

- VS Code 1.75.0 or higher
- Ruby (for Xcode project manipulation)
- xcodeproj gem (`gem install xcodeproj`)

---

**Full Changelog**: See [CHANGELOG.md](CHANGELOG.md)
