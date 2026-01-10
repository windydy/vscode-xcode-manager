# Testing Guide

This guide helps you test the Xcode File Manager extension functionality.

## Setup Test Environment

1. Open the extension folder in VS Code
2. Press `F5` to launch Extension Development Host
3. In the new window, open your Xcode project workspace

## Test Cases

### Test 1: Add Single File to Xcode ✅

**Steps:**
1. Create a new file in VS Code (e.g., `TestFile.m`)
2. Right-click the file in Explorer
3. Select "Add File to Xcode"

**Expected Result:**
- ✅ Success message appears
- ✅ File appears in Xcode project navigator
- ✅ .m file is added to "Compile Sources" build phase

### Test 2: Add Folder to Xcode ✅

**Steps:**
1. Create a folder with multiple files:
   ```
   TestFolder/
   ├── File1.h
   ├── File1.m
   ├── File2.h
   └── File2.m
   ```
2. Right-click the folder
3. Select "Add Folder to Xcode"

**Expected Result:**
- ✅ All files added to project
- ✅ Folder hierarchy preserved in Xcode
- ✅ Source files in compile phase, resources in resources phase

### Test 3: Create UIViewController ✅

**Steps:**
1. Press `Cmd+Shift+P`
2. Type "Create File and Add to Xcode"
3. Class name: `TestViewController`
4. Base class: `UIViewController`
5. Output directory: `FigmaUIToCodeDemo/FigmaUIToCodeDemo`

**Expected Result:**
- ✅ `TestViewController.h` created
- ✅ `TestViewController.m` created
- ✅ Both files added to Xcode project
- ✅ Files contain correct template code
- ✅ Class inherits from UIViewController

**Verify Template Contents:**

TestViewController.h should contain:
```objc
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
```

TestViewController.m should contain:
```objc
#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

@end
```

### Test 4: Create NSObject ✅

**Steps:**
1. Press `Cmd+Shift+P`
2. Select "Create File and Add to Xcode"
3. Class name: `TestModel`
4. Base class: `NSObject`
5. Output directory: `FigmaUIToCodeDemo/FigmaUIToCodeDemo`

**Expected Result:**
- ✅ `TestModel.h` created
- ✅ `TestModel.m` created
- ✅ Class inherits from NSObject

### Test 5: Create UIView ✅

**Steps:**
1. Create with base class `UIView`
2. Class name: `TestCustomView`

**Expected Result:**
- ✅ Files created and added
- ✅ Contains initWithFrame: and initWithCoder: methods

### Test 6: Create UITableViewCell ✅

**Steps:**
1. Create with base class `UITableViewCell`
2. Class name: `TestCell`

**Expected Result:**
- ✅ Files created and added
- ✅ Contains awakeFromNib and setSelected methods

### Test 7: Create Folder ✅

**Steps:**
1. Press `Cmd+Shift+P`
2. Select "Create Folder and Add to Xcode"
3. Folder name: `TestModule`
4. Parent directory: `FigmaUIToCodeDemo/FigmaUIToCodeDemo`

**Expected Result:**
- ✅ Folder created on filesystem
- ✅ Folder added to Xcode project

### Test 8: Duplicate File Handling ⚠️

**Steps:**
1. Try to add a file that already exists in the project
2. Or create a class with an existing name

**Expected Result:**
- ✅ Warning message shown
- ✅ Existing file not overwritten
- ✅ No duplicate in Xcode project

### Test 9: Invalid Input Handling ❌

**Test 9a: Invalid Class Name**
- Try class name: `123Invalid` (starts with number)
- Expected: Validation error

**Test 9b: Empty Input**
- Leave class name empty
- Expected: Validation error

**Test 9c: Special Characters**
- Try class name: `My-ViewController`
- Expected: Validation error

### Test 10: Multi-level Directory ✅

**Steps:**
1. Create in nested directory: `FigmaUIToCodeDemo/FigmaUIToCodeDemo/Features/Login`
2. Create `LoginViewController`

**Expected Result:**
- ✅ All parent groups created in Xcode
- ✅ File appears in correct location

## Regression Tests

After making changes, run all tests above to ensure nothing broke.

## Manual Verification in Xcode

After each test:
1. Open the `.xcodeproj` in Xcode
2. Verify files appear in correct groups
3. Check Build Phases → Compile Sources (for .m files)
4. Build the project to ensure no errors

## Performance Tests

**Large Folder:**
- Create folder with 50+ files
- Add to Xcode
- Should complete within 10 seconds

**Multiple Operations:**
- Add 10 files sequentially
- Each should complete successfully

## Error Scenarios

### No Xcode Project
- Open workspace without .xcodeproj
- Try to add file
- Expected: Clear error message

### Ruby Not Installed
- Temporarily rename ruby binary
- Try to add file
- Expected: Clear error about missing Ruby

### xcodeproj Gem Missing
- Uninstall gem temporarily
- Expected: Clear error message

## Debug Mode Testing

1. Set breakpoints in extension.ts
2. Press F5 to debug
3. Trigger commands
4. Verify correct code paths

## Logging

Check VS Code Developer Tools:
- `Help → Toggle Developer Tools`
- Console tab shows extension logs

## Test Checklist

Before release:
- [ ] All test cases pass
- [ ] No console errors
- [ ] Files added correctly to Xcode
- [ ] Templates generate correct code
- [ ] Error messages are clear
- [ ] Success messages appear
- [ ] No duplicate files created
- [ ] Build phases updated correctly
- [ ] Works with multiple Xcode projects
- [ ] Works with nested directories

## Automated Testing (Future)

Consider adding:
- Unit tests for TypeScript code
- Integration tests for Ruby scripts
- Mock Xcode project for testing
