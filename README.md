# Xcode File Manager

A Visual Studio Code extension to manage Xcode project files and folders directly from VS Code.

> 📚 **[Complete Documentation Index](DOCS_INDEX.md)** | 🚀 **[Quick Start Guide](QUICKSTART.md)** | 📦 **[Installation Guide](INSTALLATION.md)**

## Features

- **Add File to Xcode**: Right-click any file in the explorer and add it to your Xcode project
- **Add Folder to Xcode**: Right-click any folder and add it (with all contents) to your Xcode project
- **Create New File**: Create new Objective-C files (.h and .m) from templates and automatically add them to Xcode
- **Create New Folder**: Create a new folder and add it to your Xcode project

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

## Extension Settings

This extension does not require any configuration. It automatically finds your Xcode project in the workspace.

## Known Issues

- Only supports Objective-C files currently
- Requires Ruby and xcodeproj gem to be installed

## Release Notes

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
