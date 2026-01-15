# Release Notes - Xcode File Manager v0.2.0

**Release Date**: 2026-01-15

## 🎉 Major Features

### 1. **Rename File & Folder with Xcode Sync**

Now you can rename files and folders directly from VS Code, and all Xcode project references will be updated automatically!

**How to use:**
- Right-click file/folder → `Xcode File Manager` → `Rename File/Folder in Xcode`
- Enter new name
- All references in `.xcodeproj` updated automatically

**What it does:**
- Updates file references in Xcode project
- Maintains group structure
- Handles all subfiles when renaming folders
- Preserves build phase associations

---

### 2. **Auto-Sync File Moves** ⭐ (Default Enabled)

The most requested feature! File and folder moves are now automatically detected and synced to your Xcode project.

**Key Features:**
- 🎯 Intelligent move detection (detects delete + create as move)
- 📁 Works with drag-and-drop, cut-paste, or any file operation
- 🔍 Only monitors files within Xcode project directory
- ⚡ 500ms debounce for optimal performance
- 🔕 Silent operation - no interruptions to your workflow
- 🎛️ Toggle on/off with `Toggle Xcode Auto-Sync` command

**How it works:**
1. Move a file or folder in VS Code or Finder
2. Extension automatically detects the move
3. Updates Xcode project references in the background
4. Cleans up empty groups automatically

**Configuration:**
```json
{
  "xcodeFileManager.autoSync": true  // Enabled by default
}
```

---

### 3. **Fix Xcode References**

Manually repair broken references when files are moved outside of the auto-sync system.

**Use cases:**
- Files moved before installing the extension
- Bulk operations from external tools
- Git branch switches that move files
- Manual cleanup needed

**How to use:**
- Right-click anywhere → `Xcode File Manager` → `Fix Xcode References`
- Or use Command Palette: `Fix Xcode References`

**What it does:**
- Scans for broken file references
- Smart matching algorithm finds relocated files
- Updates references to new locations
- Cleans up empty groups
- Shows summary of fixes applied

---

### 4. **Unified Menu Structure**

All commands are now organized under a single "Xcode File Manager" submenu for better organization.

**Menu Groups:**
1. **Add** - Add existing files/folders to Xcode
2. **Create** - Create new files/folders and add to Xcode
3. **Rename** - Rename with Xcode sync
4. **Remove** - Remove references only (keep files)
5. **Delete** - Delete files and remove from Xcode
6. **Fix** - Fix broken references

---

## 🔧 Improvements

### Enhanced File Watcher
- Only monitors files within Xcode project directory (better performance)
- Automatic project root detection
- Excludes build outputs, dependencies, and system folders

### Better Error Handling
- Improved JSON parsing from Ruby scripts
- More informative error messages
- Stderr capture for debugging
- Graceful handling of edge cases

### Code Quality
- Cleaner separation of concerns
- Better async handling
- Comprehensive error recovery
- Detailed logging for troubleshooting

---

## 📝 All Commands

| Command | Description | Shortcut |
|---------|-------------|----------|
| Add File to Xcode | Add existing file | Right-click menu |
| Add Folder to Xcode | Add existing folder | Right-click menu |
| Create File and Add to Xcode | Create new file from template | Command Palette |
| Create Folder and Add to Xcode | Create new folder | Command Palette |
| Rename File in Xcode | Rename file + sync | Right-click menu |
| Rename Folder in Xcode | Rename folder + sync | Right-click menu |
| Remove File Reference | Remove ref only | Right-click menu |
| Remove Folder Reference | Remove ref only | Right-click menu |
| Delete File from Xcode | Delete + remove ref | Right-click menu |
| Delete Folder from Xcode | Delete + remove ref | Right-click menu |
| Fix Xcode References | Repair broken refs | Context/Command Palette |
| Toggle Xcode Auto-Sync | Enable/disable auto-sync | Command Palette |

---

## 🐛 Bug Fixes

- Fixed file reference paths when moving files between folders
- Corrected group path updates to prevent broken references
- Empty groups now properly cleaned up after moves
- Folder moves correctly update all contained files
- Improved handling of relative paths in Xcode project

---

## ⚙️ Technical Details

### New Scripts
- `rename_file.rb` - Handles single file renames
- `rename_folder.rb` - Handles folder renames with recursive updates
- `auto_fix_file.rb` - Auto-fixes moved files/folders
- `fix_references.rb` - Manual reference repair tool

### New Components
- `fileWatcher.ts` - File system change monitoring
- Auto-sync engine with move detection
- Debounced event processing
- Smart project root detection

---

## 📦 Installation

```bash
# Install from VS Code Marketplace
ext install windydy.vscode-xcode-manager

# Or install from VSIX
code --install-extension vscode-xcode-manager-0.2.0.vsix
```

---

## 🚀 Getting Started

1. Open a workspace containing an Xcode project
2. Auto-sync is enabled by default
3. Right-click files/folders to access Xcode File Manager commands
4. Move files around - they'll sync automatically!

---

## 📖 Documentation

- [Complete Documentation](DOCS_INDEX.md)
- [Quick Start Guide](QUICKSTART.md)
- [Installation Guide](INSTALLATION.md)
- [Change Log](CHANGELOG.md)

---

## 🙏 Feedback

Found a bug or have a feature request? Please open an issue on [GitHub](https://github.com/windydy/vscode-xcode-manager).

---

**Enjoy the new features!** 🎊
