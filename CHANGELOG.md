# Xcode File Manager - Change Log

## [0.2.0] - 2026-01-15

### Added

- **Rename Operations**:
  - Rename file and automatically update Xcode project references
  - Rename folder and update all file paths in Xcode project
  - Smart path updates for all affected files and subfolders

- **Fix Xcode References**:
  - Manually fix broken references after moving files/folders
  - Smart file matching algorithm to find relocated files
  - Automatic empty group cleanup
  - Can be triggered from context menu or command palette

- **Auto-Sync File Moves** (Default Enabled):
  - Automatically detect and sync file/folder moves to Xcode
  - Intelligent move detection (delete + create within 2 seconds)
  - Only monitors files within Xcode project directory
  - Configurable via `xcodeFileManager.autoSync` setting
  - Toggle on/off with "Toggle Xcode Auto-Sync" command
  - 500ms debounce to optimize performance
  - Background processing without interrupting workflow

- **Unified Menu Structure**:
  - All commands organized under "Xcode File Manager" submenu
  - Categorized groups: Add, Create, Rename, Remove, Delete, Fix
  - Context-aware commands (file vs folder)

### Changed

- Default auto-sync enabled for better user experience
- Improved file watcher to only monitor Xcode project directory
- Enhanced error handling with detailed logging
- Better JSON output validation from Ruby scripts

### Fixed

- File reference paths correctly updated when moving files
- Empty groups automatically cleaned up after file moves
- Folder moves now properly update all contained files
- Improved error messages for debugging

## [0.1.1] - 2026-01-11

### Fixed

- **Target Type Compatibility**: Fixed issue where script would fail on PBXAggregateTarget and other special target types
  - Added `respond_to?` checks before accessing build phases
  - Added nil checks for build phase objects
  - Improved handling of different Xcode project target types
- **Enhanced Logging**: Improved diagnostic logging for project path discovery
  - Added detailed logs to `find_xcodeproj` function
  - Better visibility into project search process
  - More informative error messages

### Changed

- Updated remove_from_xcodeproj.rb script for better compatibility
- Enhanced error reporting in extension commands

## [0.1.0] - 2026-01-11

### Added

- **Enhanced File Creation**: Support for multiple Objective-C file types
  - Cocoa Touch Class with custom base class support
  - Objective-C File (Empty, Category, Extension, Protocol)
  - Header File only
- **Category Support**:
  - Automatic file naming with `ClassName+CategoryName` format
  - Smart system framework detection and import
  - Support for lowercase category names
- **Custom Base Class**: Allow users to input custom base classes for Cocoa Touch files
- **System Framework Auto-Import**: Automatically import correct framework based on class prefix
  - 40+ Apple frameworks supported (UIKit, Foundation, CoreGraphics, ARKit, etc.)
  - Smart detection for UI*, NS*, CA*, AV*, and many more prefixes
- **Delete Operations**:
  - Remove file/folder reference from Xcode only
  - Delete file/folder and remove from Xcode (move to trash)
  - Batch operation support for multiple selections
  - Confirmation dialog with item preview
- **Batch Operations**: Select multiple files/folders for simultaneous operations
- **Error Handling**: Better error messages and operation summaries

### Changed

- Improved validation for file and class names
- Enhanced user prompts with better placeholders and descriptions
- Cocoa Touch template now uses fallback for custom base classes

### Fixed

- TypeScript type errors for optional parameters
- File name validation to support underscores in category names
- Import statements now correctly replaced in all template types

## [0.0.1] - 2026-01-11

### Added

- Initial release
- Add file to Xcode project via context menu
- Add folder to Xcode project via context menu
- Create new Objective-C files from templates
- Create new folders and add to Xcode
- Support for UIViewController, NSObject, UIView, and UITableViewCell base classes
- Automatic file addition to Xcode build phases
