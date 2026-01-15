# Xcode File Manager

A Visual Studio Code extension to manage Xcode project files and folders directly from VS Code.

> 📚 **[Complete Documentation Index](DOCS_INDEX.md)** | 🚀 **[Quick Start Guide](QUICKSTART.md)** | 📦 **[Installation Guide](INSTALLATION.md)**

## Features

### File & Folder Management
- **Add File to Xcode**: Right-click any file in the explorer and add it to your Xcode project
- **Add Folder to Xcode**: Right-click any folder and add it (with all contents) to your Xcode project
- **Create New File**: Create new Objective-C files (.h and .m) from templates and automatically add them to Xcode
- **Create New Folder**: Create a new folder and add it to your Xcode project
- **Rename File/Folder**: Rename files or folders and automatically update all Xcode project references
- **Delete File/Folder**: Remove files/folders from both disk and Xcode project, or just remove references

### Smart File Sync ✨
- **Auto-Sync** (Default Enabled): Automatically detect and sync file/folder moves to Xcode project
  - Monitors files within Xcode project directory only
  - Intelligent move detection without manual intervention
  - Works with drag-and-drop, cut-paste, or any file manager operations
  - Toggle on/off with "Toggle Xcode Auto-Sync" command

### Reference Management
- **Fix Xcode References**: Manually repair broken references after moving files externally
  - Smart file matching to locate moved files
  - Automatic group structure updates
  - Empty group cleanup

## Requirements

- Ruby (2.7 or higher)
- `xcodeproj` gem: Install with `gem install xcodeproj`
- An Xcode project (`.xcodeproj`) in your workspace

## Usage

### Add File to Xcode

1. Right-click on any file in the VS Code Explorer
2. Select **"Add File to Xcode"**
3. The file will be added to your Xcode project

### Add Folder to Xcode

1. Right-click on any folder in the VS Code Explorer
2. Select **"Add Folder to Xcode"**
3. All files in the folder will be recursively added to your Xcode project

### Create New File and Add to Xcode

1. Open the Command Palette (`Cmd+Shift+P` on macOS)
2. Type and select **"Create File and Add to Xcode"**
3. Enter the class name (e.g., `MyViewController`)
4. Select a base class (UIViewController, NSObject, UIView, or UITableViewCell)
5. Enter the output directory (relative to workspace root)
6. The .h and .m files will be generated and added to Xcode

### Create New Folder and Add to Xcode

1. Open the Command Palette (`Cmd+Shift+P` on macOS)
2. Type and select **"Create Folder and Add to Xcode"**
3. Enter the folder name
4. Enter the parent directory
5. The folder will be created and added to Xcode

### Rename File or Folder

1. Right-click on a file or folder in the VS Code Explorer
2. Select **"Xcode File Manager" → "Rename File/Folder in Xcode"**
3. Enter the new name
4. The item will be renamed and all Xcode references updated automatically

### Fix Broken References

1. Right-click anywhere in the VS Code Explorer (or use Command Palette)
2. Select **"Xcode File Manager" → "Fix Xcode References"**
3. The extension will scan and repair all broken file references

### Auto-Sync (Enabled by Default)

File and folder moves are automatically detected and synced to Xcode:
- Simply drag and drop files/folders in VS Code or Finder
- The extension detects moves and updates Xcode project automatically
- Toggle with: **"Toggle Xcode Auto-Sync"** command

## Extension Settings

This extension contributes the following settings:

- `xcodeFileManager.autoSync`: Enable/disable automatic file move synchronization (default: `true`)

## Known Issues

- Only supports Objective-C files currently
- Requires Ruby and xcodeproj gem to be installed

## Release Notes

### 0.2.0

- Added rename file/folder with automatic Xcode reference updates
- Added "Fix Xcode References" command for manual repair
- Added auto-sync for file/folder moves (enabled by default)
- Unified all commands under "Xcode File Manager" submenu
- Improved monitoring to only watch Xcode project directory

### 0.1.1

Fixed compatibility with different Xcode target types.

### 0.1.0

Enhanced file creation with multiple templates and delete operations.

### 0.0.1

Initial release with basic file and folder management features.

## Development

### Building the Extension

```bash
cd vscode-xcode-manager
npm install
npm run compile
```

### Running in Debug Mode

1. Open the extension folder in VS Code
2. Press F5 to start debugging
3. A new VS Code window will open with the extension loaded

### Packaging the Extension

```bash
npm install -g vsce
vsce package
```

This will create a `.vsix` file that can be installed in VS Code.

## License

MIT
