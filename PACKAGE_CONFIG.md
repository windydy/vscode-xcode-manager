# Package.json Configuration Guide

This document explains the key configurations in package.json for the Xcode File Manager extension.

## Basic Information

```json
{
  "name": "vscode-xcode-manager",
  "displayName": "Xcode File Manager",
  "description": "Manage Xcode project files and folders directly from VS Code",
  "version": "0.0.1"
}
```

- **name**: Internal identifier (kebab-case)
- **displayName**: Name shown in VS Code Extensions marketplace
- **description**: Brief description of functionality
- **version**: Semantic versioning (MAJOR.MINOR.PATCH)

## Engine Requirements

```json
{
  "engines": {
    "vscode": "^1.75.0"
  }
}
```

Specifies minimum VS Code version required. Version 1.75.0 ensures compatibility with modern VS Code features.

## Activation Events

```json
{
  "activationEvents": []
}
```

Empty array means the extension activates on any of the registered commands. VS Code automatically determines activation based on `contributes.commands`.

## Entry Point

```json
{
  "main": "./out/extension.js"
}
```

Points to the compiled JavaScript entry file. TypeScript source is in `src/extension.ts`, but the runtime uses the compiled version.

## Commands

```json
{
  "contributes": {
    "commands": [
      {
        "command": "extension.addFileToXcode",
        "title": "Add File to Xcode"
      }
    ]
  }
}
```

Each command has:
- **command**: Unique identifier used in code
- **title**: Display name in Command Palette

## Menus

### Explorer Context Menu

```json
{
  "menus": {
    "explorer/context": [
      {
        "command": "extension.addFileToXcode",
        "group": "xcode@1",
        "when": "!explorerResourceIsFolder"
      }
    ]
  }
}
```

- **explorer/context**: Right-click menu in Explorer
- **group**: Menu group name (xcode@1, xcode@2 for ordering)
- **when**: Conditional expression
  - `!explorerResourceIsFolder`: Show only for files
  - `explorerResourceIsFolder`: Show only for folders

### Command Palette

```json
{
  "menus": {
    "commandPalette": [
      {
        "command": "extension.addFileToXcode",
        "when": "false"
      }
    ]
  }
}
```

- `"when": "false"`: Hide from Command Palette (context-menu only)
- Omit the entry to show in both places

## Scripts

```json
{
  "scripts": {
    "vscode:prepublish": "npm run compile",
    "compile": "tsc -p ./",
    "watch": "tsc -watch -p ./",
    "lint": "eslint src --ext ts"
  }
}
```

- **vscode:prepublish**: Runs before packaging
- **compile**: One-time compilation
- **watch**: Continuous compilation on file changes
- **lint**: Check code quality

## DevDependencies

```json
{
  "devDependencies": {
    "@types/vscode": "^1.75.0",
    "@types/node": "16.x",
    "typescript": "^4.9.3"
  }
}
```

- **@types/vscode**: VS Code API type definitions
- **@types/node**: Node.js type definitions
- **typescript**: TypeScript compiler

## When Clauses Reference

Common `when` clause expressions:

- `!explorerResourceIsFolder` - File selected
- `explorerResourceIsFolder` - Folder selected
- `resourceLangId == javascript` - JavaScript file
- `editorTextFocus` - Editor has focus
- `resourceExtname == .ts` - TypeScript file

## Custom Groups

Our custom group `xcode` keeps all commands together in the context menu:

```json
{
  "group": "xcode@1"
}
```

The `@1`, `@2` suffix controls ordering within the group.

## Publishing

Before publishing to marketplace:

1. Update version in package.json
2. Update CHANGELOG.md
3. Add publisher field:
   ```json
   {
     "publisher": "your-publisher-name"
   }
   ```
4. Add repository, license, etc.
5. Run `vsce publish`

## Icon (Optional)

Add an icon for the extension:

```json
{
  "icon": "images/icon.png"
}
```

Icon should be 128x128 PNG.

## Categories

```json
{
  "categories": ["Other"]
}
```

Available categories:
- Programming Languages
- Snippets
- Linters
- Themes
- Debuggers
- Formatters
- Keymaps
- SCM Providers
- Other
- Extension Packs
- Language Packs

## Keywords (for search)

```json
{
  "keywords": [
    "xcode",
    "objective-c",
    "ios",
    "macos",
    "project management"
  ]
}
```

Helps users find your extension in the marketplace.
