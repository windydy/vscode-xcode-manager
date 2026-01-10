import * as vscode from 'vscode';
import { 
  addFileToXcode, 
  addFolderToXcode, 
  createFileAndAddToXcode, 
  createFolderAndAddToXcode,
  removeFileReferenceFromXcode,
  removeFolderReferenceFromXcode,
  deleteFileFromXcode,
  deleteFolderFromXcode
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

  // Register command: Remove File Reference from Xcode
  const removeFileReferenceCommand = vscode.commands.registerCommand(
    'extension.removeFileReferenceFromXcode',
    (uri: vscode.Uri, uris?: vscode.Uri[]) => removeFileReferenceFromXcode(context, uri, uris)
  );

  // Register command: Remove Folder Reference from Xcode
  const removeFolderReferenceCommand = vscode.commands.registerCommand(
    'extension.removeFolderReferenceFromXcode',
    (uri: vscode.Uri, uris?: vscode.Uri[]) => removeFolderReferenceFromXcode(context, uri, uris)
  );

  // Register command: Delete File from Xcode
  const deleteFileCommand = vscode.commands.registerCommand(
    'extension.deleteFileFromXcode',
    (uri: vscode.Uri, uris?: vscode.Uri[]) => deleteFileFromXcode(context, uri, uris)
  );

  // Register command: Delete Folder from Xcode
  const deleteFolderCommand = vscode.commands.registerCommand(
    'extension.deleteFolderFromXcode',
    (uri: vscode.Uri, uris?: vscode.Uri[]) => deleteFolderFromXcode(context, uri, uris)
  );

  // Add all commands to subscriptions
  context.subscriptions.push(
    addFileCommand,
    addFolderCommand,
    createFileCommand,
    createFolderCommand,
    removeFileReferenceCommand,
    removeFolderReferenceCommand,
    deleteFileCommand,
    deleteFolderCommand
  );
}

export function deactivate() {
  console.log('Xcode File Manager extension is now deactivated');
}
