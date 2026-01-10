# Installation Guide

## Prerequisites

Before using this extension, you need to install the required dependencies:

### 1. Ruby

Make sure Ruby is installed on your system:

```bash
ruby -v
```

If not installed, on macOS:

```bash
brew install ruby
```

### 2. XcodeProj Gem

Install the xcodeproj gem:

```bash
gem install xcodeproj
```

## Installing the Extension

### Method 1: From Source (Development)

1. Clone or copy the `vscode-xcode-manager` folder to your local machine
2. Open the folder in VS Code
3. Install dependencies:
   ```bash
   npm install
   ```
4. Compile the extension:
   ```bash
   npm run compile
   ```
5. Press `F5` to open a new VS Code window with the extension loaded

### Method 2: Install VSIX Package

1. Package the extension:
   ```bash
   npm install -g vsce
   vsce package
   ```
2. This will create a `.vsix` file in the project directory
3. Install the extension:
   - In VS Code, go to Extensions view (`Cmd+Shift+X`)
   - Click the `...` menu at the top
   - Select "Install from VSIX..."
   - Choose the `.vsix` file

### Method 3: Install from Marketplace (Future)

Once published to the VS Code Marketplace, you can install it directly from the Extensions view.

## Usage

After installation:

1. Open a workspace containing an Xcode project
2. Right-click on any file or folder in the Explorer
3. You'll see the Xcode-related commands in the context menu

For creating new files:
- Open Command Palette (`Cmd+Shift+P`)
- Type "Create File and Add to Xcode" or "Create Folder and Add to Xcode"

## Troubleshooting

### Ruby not found
If you get a "ruby not found" error, make sure Ruby is in your PATH:
```bash
which ruby
```

### xcodeproj gem not found
Install or reinstall the gem:
```bash
gem install xcodeproj
```

### No Xcode project found
Make sure your workspace contains a `.xcodeproj` file. The extension searches up to 5 levels from the current file/folder.

### Permission errors
If you encounter permission errors when running Ruby scripts, ensure the scripts are executable:
```bash
chmod +x vscode-xcode-manager/src/scripts/*.rb
```
