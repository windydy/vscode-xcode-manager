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
      console.error('Ruby script stderr:', stderr);
    }
    return stdout;
  } catch (error: any) {
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
    // Get class name
    const className = await vscode.window.showInputBox({
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

    if (!className) {
      return;
    }

    // Get base class
    const baseClass = await vscode.window.showQuickPick(
      ['UIViewController', 'NSObject', 'UIView', 'UITableViewCell'],
      {
        placeHolder: 'Select a base class',
        canPickMany: false
      }
    );

    if (!baseClass) {
      return;
    }

    // Get output directory
    const workspaceFolders = vscode.workspace.workspaceFolders;
    if (!workspaceFolders) {
      vscode.window.showErrorMessage('No workspace folder opened');
      return;
    }

    const outputDir = await vscode.window.showInputBox({
      prompt: 'Enter the output directory (relative to workspace)',
      placeHolder: 'FigmaUIToCodeDemo/FigmaUIToCodeDemo',
      value: 'FigmaUIToCodeDemo/FigmaUIToCodeDemo'
    });

    if (!outputDir) {
      return;
    }

    const fullOutputPath = path.join(workspaceFolders[0].uri.fsPath, outputDir);

    // Execute Ruby script
    const scriptPath = getScriptPath(context, 'new_xcode_file.rb');
    const templatePath = path.join(context.extensionPath, 'templates');
    
    vscode.window.showInformationMessage(`Creating ${className} files...`);
    
    const output = await executeRubyScript(scriptPath, [
      className,
      baseClass,
      fullOutputPath,
      templatePath
    ]);
    
    vscode.window.showInformationMessage(`✅ Successfully created and added ${className} to Xcode`);
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
      placeHolder: 'FigmaUIToCodeDemo/FigmaUIToCodeDemo',
      value: 'FigmaUIToCodeDemo/FigmaUIToCodeDemo'
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
