import * as vscode from 'vscode';
import { 
  addFileToXcode, 
  addFolderToXcode, 
  createFileAndAddToXcode, 
  createFolderAndAddToXcode 
} from './commands/xcodeCommands';

export function activate(context: vscode.ExtensionContext) {
  console.log('Xcode File Manager extension is now active');

  // Register command: Add File to Xcode
  const addFileCommand = vscode.commands.registerCommand(
    'extension.addFileToXcode',
    (uri: vscode.Uri) => addFileToXcode(context, uri)
  );

  // Register command: Add Folder to Xcode
  const addFolderCommand = vscode.commands.registerCommand(
    'extension.addFolderToXcode',
    (uri: vscode.Uri) => addFolderToXcode(context, uri)
  );

  // Register command: Create File and Add to Xcode
  const createFileCommand = vscode.commands.registerCommand(
    'extension.createFileAndAddToXcode',
    () => createFileAndAddToXcode(context)
  );

  // Register command: Create Folder and Add to Xcode
  const createFolderCommand = vscode.commands.registerCommand(
    'extension.createFolderAndAddToXcode',
    () => createFolderAndAddToXcode(context)
  );

  // Add all commands to subscriptions
  context.subscriptions.push(
    addFileCommand,
    addFolderCommand,
    createFileCommand,
    createFolderCommand
  );
}

export function deactivate() {
  console.log('Xcode File Manager extension is now deactivated');
}
