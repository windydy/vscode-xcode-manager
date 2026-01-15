import * as vscode from 'vscode';
import { 
  addFileToXcode, 
  addFolderToXcode, 
  createFileAndAddToXcode, 
  createFolderAndAddToXcode,
  removeFileReferenceFromXcode,
  removeFolderReferenceFromXcode,
  deleteFileFromXcode,
  deleteFolderFromXcode,
  renameFileInXcode,
  renameFolderInXcode,
  fixXcodeReferences
} from './commands/xcodeCommands';
import { XcodeFileWatcher } from './fileWatcher';

export function activate(context: vscode.ExtensionContext) {
  console.log('Xcode File Manager extension is now active');

  // Initialize file watcher
  const fileWatcher = new XcodeFileWatcher(context);
  
  // Auto-start file watcher if enabled in settings
  const config = vscode.workspace.getConfiguration('xcodeFileManager');
  if (config.get('autoSync', true)) {
    fileWatcher.start();
  }

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
    (uri?: vscode.Uri) => createFileAndAddToXcode(context, uri)
  );

  // Register command: Create Folder and Add to Xcode
  const createFolderCommand = vscode.commands.registerCommand(
    'extension.createFolderAndAddToXcode',
    (uri?: vscode.Uri) => createFolderAndAddToXcode(context, uri)
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

  // Register command: Rename File in Xcode
  const renameFileCommand = vscode.commands.registerCommand(
    'extension.renameFileInXcode',
    (uri: vscode.Uri) => renameFileInXcode(context, uri)
  );

  // Register command: Rename Folder in Xcode
  const renameFolderCommand = vscode.commands.registerCommand(
    'extension.renameFolderInXcode',
    (uri: vscode.Uri) => renameFolderInXcode(context, uri)
  );

  // Register command: Fix Xcode References
  const fixReferencesCommand = vscode.commands.registerCommand(
    'extension.fixXcodeReferences',
    (uri?: vscode.Uri) => fixXcodeReferences(context, uri)
  );

  // Register command: Toggle Auto Sync
  const toggleAutoSyncCommand = vscode.commands.registerCommand(
    'extension.toggleXcodeAutoSync',
    () => {
      fileWatcher.toggle();
      
      // Update configuration
      const config = vscode.workspace.getConfiguration('xcodeFileManager');
      config.update('autoSync', fileWatcher.isEnabled(), vscode.ConfigurationTarget.Workspace);
    }
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
    deleteFolderCommand,
    renameFileCommand,
    renameFolderCommand,
    fixReferencesCommand,
    toggleAutoSyncCommand,
    fileWatcher
  );
}

export function deactivate() {
  console.log('Xcode File Manager extension is now deactivated');
}

