import * as vscode from 'vscode';
import * as path from 'path';
import { execFile } from 'child_process';
import { promisify } from 'util';

const execFileAsync = promisify(execFile);

/**
 * Execute Ruby script with arguments
 */
async function executeRubyScript(scriptPath: string, args: string[]): Promise<string> {
  try {
    const { stdout, stderr } = await execFileAsync('ruby', [scriptPath, ...args]);
    if (stderr) {
      // 将 stderr 也视为有用的调试信息，不仅是在错误情况下
      console.error('Ruby script stderr/output:', stderr);
    }
    if (stdout) {
      console.log('Ruby script stdout:', stdout);
    }
    return stdout;
  } catch (error: any) {
    // 在错误情况下也输出完整的 stderr
    console.error('Ruby script execution error:', error);
    console.error('Full stderr from Ruby script:', error.stderr || '');
    throw new Error(`Ruby script failed: ${error.message}\n${error.stderr || ''}`);
  }
}

/**
 * Get the extension's script directory
 */
function getScriptPath(context: vscode.ExtensionContext, scriptName: string): string {
  return path.join(context.extensionPath, 'src', 'scripts', scriptName);
}

/**
 * Add file to Xcode project
 */
export async function addFileToXcode(context: vscode.ExtensionContext, uri: vscode.Uri) {
  try {
    const scriptPath = getScriptPath(context, 'add_to_xcodeproj.rb');
    const filePath = uri.fsPath;
    
    vscode.window.showInformationMessage(`Adding file to Xcode: ${path.basename(filePath)}`);
    
    const output = await executeRubyScript(scriptPath, [filePath]);
    vscode.window.showInformationMessage(`✅ Successfully added to Xcode: ${path.basename(filePath)}`);
    console.log(output);
  } catch (error: any) {
    vscode.window.showErrorMessage(`Failed to add file to Xcode: ${error.message}`);
  }
}

/**
 * Add folder to Xcode project
 */
export async function addFolderToXcode(context: vscode.ExtensionContext, uri: vscode.Uri) {
  try {
    const scriptPath = getScriptPath(context, 'add_to_xcodeproj.rb');
    const folderPath = uri.fsPath;
    
    vscode.window.showInformationMessage(`Adding folder to Xcode: ${path.basename(folderPath)}`);
    
    const output = await executeRubyScript(scriptPath, [folderPath]);
    vscode.window.showInformationMessage(`✅ Successfully added folder to Xcode: ${path.basename(folderPath)}`);
    console.log(output);
  } catch (error: any) {
    vscode.window.showErrorMessage(`Failed to add folder to Xcode: ${error.message}`);
  }
}

/**
 * Create new file and add to Xcode
 */
export async function createFileAndAddToXcode(context: vscode.ExtensionContext) {
  try {
    // Get template type
    const templateType = await vscode.window.showQuickPick(
      [
        { label: 'Cocoa Touch Class', value: 'cocoa_touch', description: 'UIViewController, UIView, NSObject, etc.' },
        { label: 'Objective-C File', value: 'objc_file', description: 'Header, Implementation, Category, Extension, Protocol' },
        { label: 'Header File', value: 'header_file', description: 'Empty .h file only' }
      ],
      {
        placeHolder: 'Select a template type',
        canPickMany: false
      }
    );

    if (!templateType) {
      return;
    }

    // For Objective-C File: get file name first
    let fileName = '';
    let fileType = '';
    let className = '';
    let baseClass = 'NSObject';

    if (templateType.value === 'objc_file') {
      // Step 1: File Name
      const inputFileName = await vscode.window.showInputBox({
        prompt: 'Enter the file name (e.g., MyCategory or MyExtension)',
        placeHolder: 'FileName',
        validateInput: (value) => {
          if (!value || value.trim().length === 0) {
            return 'File name cannot be empty';
          }
          if (!/^[A-Za-z][A-Za-z0-9_]*$/.test(value)) {
            return 'File name must start with a letter and contain only alphanumeric characters and underscores';
          }
          return null;
        }
      });

      if (!inputFileName) {
        return;
      }
      fileName = inputFileName;

      // Step 2: File Type
      const selectedFileType = await vscode.window.showQuickPick(
        [
          { label: 'Empty File', value: 'empty', description: 'Empty .h and .m files' },
          { label: 'Category', value: 'category', description: 'Category for an existing class' },
          { label: 'Extension', value: 'extension', description: 'Class extension (private interface)' },
          { label: 'Protocol', value: 'protocol', description: 'Protocol definition (.h only)' }
        ],
        {
          placeHolder: 'Select file type',
          canPickMany: false
        }
      );

      if (!selectedFileType) {
        return;
      }
      fileType = selectedFileType.value;

      // Step 3: Class (only for Category and Extension)
      if (fileType === 'category' || fileType === 'extension') {
        const inputClassName = await vscode.window.showInputBox({
          prompt: `Enter the class name to ${fileType === 'category' ? 'extend' : 'add extension to'} (e.g., UIViewController)`,
          placeHolder: 'UIViewController',
          validateInput: (value) => {
            if (!value || value.trim().length === 0) {
              return 'Class name cannot be empty';
            }
            if (!/^[A-Z][A-Za-z0-9]*$/.test(value)) {
              return 'Class name must start with an uppercase letter';
            }
            return null;
          }
        });

        if (!inputClassName) {
          return;
        }
        className = inputClassName;
        // Ruby script will handle the file naming (e.g., ClassName+CategoryName)
      } else {
        // For empty file and protocol, use fileName as className
        className = fileName;
      }
    } else if (templateType.value === 'cocoa_touch') {
      // Original Cocoa Touch Class flow
      const inputClassName = await vscode.window.showInputBox({
        prompt: 'Enter the class name (e.g., MyViewController)',
        placeHolder: 'MyViewController',
        validateInput: (value) => {
          if (!value || value.trim().length === 0) {
            return 'Class name cannot be empty';
          }
          if (!/^[A-Za-z][A-Za-z0-9]*$/.test(value)) {
            return 'Class name must start with a letter and contain only alphanumeric characters';
          }
          return null;
        }
      });

      if (!inputClassName) {
        return;
      }
      className = inputClassName;

      // Allow custom base class input with quick pick suggestions
      const selectedBaseClass = await vscode.window.showQuickPick(
        [
          { label: 'UIViewController', value: 'UIViewController' },
          { label: 'NSObject', value: 'NSObject' },
          { label: 'UIView', value: 'UIView' },
          { label: 'UITableViewCell', value: 'UITableViewCell' },
          { label: 'Custom...', value: '__custom__', description: 'Enter a custom base class' }
        ],
        {
          placeHolder: 'Select a base class or choose Custom to enter your own',
          canPickMany: false
        }
      );

      if (!selectedBaseClass) {
        return;
      }

      if (selectedBaseClass.value === '__custom__') {
        // Allow user to input custom base class
        const customBaseClass = await vscode.window.showInputBox({
          prompt: 'Enter the custom base class (e.g., CALayer, UIButton)',
          placeHolder: 'BaseClassName',
          validateInput: (value) => {
            if (!value || value.trim().length === 0) {
              return 'Base class name cannot be empty';
            }
            if (!/^[A-Z][A-Za-z0-9]*$/.test(value)) {
              return 'Base class name must start with an uppercase letter and contain only alphanumeric characters';
            }
            return null;
          }
        });

        if (!customBaseClass) {
          return;
        }
        baseClass = customBaseClass;
      } else {
        baseClass = selectedBaseClass.value;
      }
      
      fileName = className;
    } else {
      // Header File
      const inputClassName = await vscode.window.showInputBox({
        prompt: 'Enter the file name (e.g., MyHeader)',
        placeHolder: 'MyHeader',
        validateInput: (value) => {
          if (!value || value.trim().length === 0) {
            return 'File name cannot be empty';
          }
          if (!/^[A-Za-z][A-Za-z0-9]*$/.test(value)) {
            return 'File name must start with a letter and contain only alphanumeric characters';
          }
          return null;
        }
      });

      if (!inputClassName) {
        return;
      }
      className = inputClassName;
      fileName = className;
    }

    // Get output directory
    const workspaceFolders = vscode.workspace.workspaceFolders;
    if (!workspaceFolders) {
      vscode.window.showErrorMessage('No workspace folder opened');
      return;
    }

    const outputDir = await vscode.window.showInputBox({
      prompt: 'Enter the output directory (relative to workspace)',
      placeHolder: '/',
      value: '/'
    });

    if (!outputDir) {
      return;
    }

    const fullOutputPath = path.join(workspaceFolders[0].uri.fsPath, outputDir);

    // Execute Ruby script
    const scriptPath = getScriptPath(context, 'new_xcode_file.rb');
    const templatePath = path.join(context.extensionPath, 'templates');
    
    vscode.window.showInformationMessage(`Creating ${fileName} files...`);
    
    const output = await executeRubyScript(scriptPath, [
      fileName,
      baseClass,
      fullOutputPath,
      templatePath,
      templateType.value,
      fileType || '',
      className || ''
    ]);
    
    vscode.window.showInformationMessage(`✅ Successfully created and added ${fileName} to Xcode`);
    console.log(output);
  } catch (error: any) {
    vscode.window.showErrorMessage(`Failed to create file: ${error.message}`);
  }
}

/**
 * Create new folder and add to Xcode
 */
export async function createFolderAndAddToXcode(context: vscode.ExtensionContext) {
  try {
    const folderName = await vscode.window.showInputBox({
      prompt: 'Enter the folder name',
      placeHolder: 'NewFolder',
      validateInput: (value) => {
        if (!value || value.trim().length === 0) {
          return 'Folder name cannot be empty';
        }
        return null;
      }
    });

    if (!folderName) {
      return;
    }

    const workspaceFolders = vscode.workspace.workspaceFolders;
    if (!workspaceFolders) {
      vscode.window.showErrorMessage('No workspace folder opened');
      return;
    }

    const parentDir = await vscode.window.showInputBox({
      prompt: 'Enter the parent directory (relative to workspace)',
      placeHolder: '/',
      value: '/'
    });

    if (!parentDir) {
      return;
    }

    const fullParentPath = path.join(workspaceFolders[0].uri.fsPath, parentDir);
    const newFolderPath = path.join(fullParentPath, folderName);

    // Create directory using VS Code API
    const uri = vscode.Uri.file(newFolderPath);
    await vscode.workspace.fs.createDirectory(uri);

    // Add to Xcode
    const scriptPath = getScriptPath(context, 'add_to_xcodeproj.rb');
    const output = await executeRubyScript(scriptPath, [newFolderPath]);
    
    vscode.window.showInformationMessage(`✅ Successfully created and added folder: ${folderName}`);
    console.log(output);
  } catch (error: any) {
    vscode.window.showErrorMessage(`Failed to create folder: ${error.message}`);
  }
}

/**
 * Remove file/folder from Xcode and optionally delete from filesystem
 */
export async function removeFromXcode(context: vscode.ExtensionContext, uri: vscode.Uri, uris?: vscode.Uri[], moveToTrash: boolean = false) {
  try {
    // Handle multiple selections
    const targetUris = uris && uris.length > 0 ? uris : [uri];
    
    const mode = moveToTrash ? 'trash' : 'reference';
    const action = moveToTrash ? 'delete and remove from' : 'remove from';
    
    // Get all target paths and names
    const targets = await Promise.all(targetUris.map(async (targetUri) => {
      const targetPath = targetUri.fsPath;
      const isDirectory = (await vscode.workspace.fs.stat(targetUri)).type === vscode.FileType.Directory;
      const targetName = path.basename(targetPath);
      return { path: targetPath, name: targetName, isDirectory };
    }));
    
    // Confirm with user
    const itemCount = targets.length;
    const itemType = itemCount === 1 
      ? (targets[0].isDirectory ? 'Folder' : 'File')
      : 'items';
    
    let confirmMessage: string;
    if (itemCount === 1) {
      confirmMessage = `Are you sure you want to ${action} Xcode project?\n${itemType}: ${targets[0].name}`;
    } else {
      const names = targets.slice(0, 5).map(t => `  • ${t.name}`).join('\n');
      const remaining = itemCount > 5 ? `\n  ... and ${itemCount - 5} more` : '';
      confirmMessage = `Are you sure you want to ${action} Xcode project?\n${itemCount} ${itemType}:\n${names}${remaining}`;
    }
    
    const confirm = await vscode.window.showWarningMessage(
      confirmMessage,
      { modal: true },
      'Yes',
      'No'
    );
    
    if (confirm !== 'Yes') {
      return;
    }

    const scriptPath = getScriptPath(context, 'remove_from_xcodeproj.rb');
    
    // Process each target
    let successCount = 0;
    let failCount = 0;
    const errors: string[] = [];
    
    for (const target of targets) {
      try {
        vscode.window.showInformationMessage(`Removing ${target.name} from Xcode...`);
        await executeRubyScript(scriptPath, [target.path, mode]);
        successCount++;
      } catch (error: any) {
        failCount++;
        errors.push(`${target.name}: ${error.message}`);
        console.error(`Failed to remove ${target.name}:`, error);
      }
    }
    
    // Show summary
    if (successCount > 0) {
      const successMessage = moveToTrash
        ? `✅ Successfully deleted and removed ${successCount} item(s) from Xcode`
        : `✅ Successfully removed ${successCount} item(s) from Xcode`;
      vscode.window.showInformationMessage(successMessage);
    }
    
    if (failCount > 0) {
      const errorMessage = `❌ Failed to remove ${failCount} item(s):\n${errors.slice(0, 3).join('\n')}${errors.length > 3 ? '\n...' : ''}`;
      vscode.window.showErrorMessage(errorMessage);
    }
  } catch (error: any) {
    vscode.window.showErrorMessage(`Failed to remove from Xcode: ${error.message}`);
  }
}

/**
 * Remove file from Xcode (reference only)
 */
export async function removeFileReferenceFromXcode(context: vscode.ExtensionContext, uri: vscode.Uri, uris?: vscode.Uri[]) {
  return removeFromXcode(context, uri, uris, false);
}

/**
 * Remove folder from Xcode (reference only)
 */
export async function removeFolderReferenceFromXcode(context: vscode.ExtensionContext, uri: vscode.Uri, uris?: vscode.Uri[]) {
  return removeFromXcode(context, uri, uris, false);
}

/**
 * Delete file and remove from Xcode
 */
export async function deleteFileFromXcode(context: vscode.ExtensionContext, uri: vscode.Uri, uris?: vscode.Uri[]) {
  return removeFromXcode(context, uri, uris, true);
}

/**
 * Delete folder and remove from Xcode
 */
export async function deleteFolderFromXcode(context: vscode.ExtensionContext, uri: vscode.Uri, uris?: vscode.Uri[]) {
  return removeFromXcode(context, uri, uris, true);
}
