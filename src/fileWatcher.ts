import * as vscode from 'vscode';
import * as path from 'path';
import { execFile } from 'child_process';
import { promisify } from 'util';

const execFileAsync = promisify(execFile);

interface FileChangeEvent {
  uri: vscode.Uri;
  type: 'created' | 'deleted' | 'changed';
  timestamp: number;
}

interface MoveDetection {
  oldUri?: vscode.Uri;
  newUri?: vscode.Uri;
  filename: string;
  timestamp: number;
}

export class XcodeFileWatcher {
  private watcher: vscode.FileSystemWatcher | null = null;
  private changeEvents: Map<string, FileChangeEvent[]> = new Map();
  private debounceTimer: NodeJS.Timeout | null = null;
  private readonly debounceDelay = 500; // 500ms
  private context: vscode.ExtensionContext;
  private enabled: boolean = false;
  private xcodeProjectRoot: string | null = null;

  constructor(context: vscode.ExtensionContext) {
    this.context = context;
  }

  private async findXcodeProjectRoot(): Promise<string | null> {
    if (!vscode.workspace.workspaceFolders) {
      return null;
    }

    const workspaceRoot = vscode.workspace.workspaceFolders[0].uri.fsPath;
    
    // Search for .xcodeproj in workspace
    const files = await vscode.workspace.findFiles('**/*.xcodeproj', '**/node_modules/**', 1);
    
    if (files.length > 0) {
      // Return the directory containing the .xcodeproj
      return path.dirname(files[0].fsPath);
    }
    
    return workspaceRoot;
  }

  public async start() {
    if (this.watcher || !vscode.workspace.workspaceFolders) {
      return;
    }

    // Find Xcode project root
    this.xcodeProjectRoot = await this.findXcodeProjectRoot();
    
    if (!this.xcodeProjectRoot) {
      console.warn('No Xcode project found, file watcher not started');
      return;
    }

    this.enabled = true;

    console.log(`Watching Xcode project at: ${this.xcodeProjectRoot}`);

    // Watch all files in the Xcode project directory
    const pattern = new vscode.RelativePattern(
      this.xcodeProjectRoot,
      '**/*'
    );

    this.watcher = vscode.workspace.createFileSystemWatcher(pattern);

    // Listen to file system events
    this.watcher.onDidCreate((uri) => this.onFileChanged(uri, 'created'));
    this.watcher.onDidDelete((uri) => this.onFileChanged(uri, 'deleted'));
    this.watcher.onDidChange((uri) => this.onFileChanged(uri, 'changed'));

    console.log('Xcode File Watcher started');
    vscode.window.showInformationMessage('📡 Xcode auto-sync enabled');
  }

  public stop() {
    if (this.watcher) {
      this.watcher.dispose();
      this.watcher = null;
    }

    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer);
      this.debounceTimer = null;
    }

    this.changeEvents.clear();
    this.enabled = false;

    console.log('Xcode File Watcher stopped');
    vscode.window.showInformationMessage('📡 Xcode auto-sync disabled');
  }

  public isEnabled(): boolean {
    return this.enabled;
  }

  public toggle() {
    if (this.enabled) {
      this.stop();
    } else {
      this.start();
    }
  }

  public dispose() {
    this.stop();
  }

  private shouldIgnore(uri: vscode.Uri): boolean {
    const filePath = uri.fsPath;
    
    // Check if the file is within the Xcode project root
    if (this.xcodeProjectRoot && !filePath.startsWith(this.xcodeProjectRoot)) {
      return true;
    }
    
    const ignorePaths = [
      '.xcodeproj',
      '.xcworkspace',
      'build/',
      'Pods/',
      'node_modules/',
      '.git/',
      'DerivedData/',
      '.DS_Store',
      '.swiftpm',
      'out/'
    ];

    return ignorePaths.some(ignore => filePath.includes(ignore));
  }

  private onFileChanged(uri: vscode.Uri, type: 'created' | 'deleted' | 'changed') {
    // Ignore certain paths
    if (this.shouldIgnore(uri)) {
      return;
    }

    // Get the path - could be file or folder
    const itemPath = uri.fsPath;
    const itemName = path.basename(itemPath);
    
    // Store the event
    if (!this.changeEvents.has(itemName)) {
      this.changeEvents.set(itemName, []);
    }
    
    this.changeEvents.get(itemName)!.push({
      uri,
      type,
      timestamp: Date.now()
    });

    // Reset debounce timer
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer);
    }

    this.debounceTimer = setTimeout(() => {
      this.processChanges();
    }, this.debounceDelay);
  }

  private async processChanges() {
    const moves: MoveDetection[] = [];
    const creates: vscode.Uri[] = [];
    const deletes: vscode.Uri[] = [];

    // Analyze events to detect moves
    for (const [itemName, events] of this.changeEvents.entries()) {
      // Look for delete + create within short time window (move operation)
      const deleteEvent = events.find(e => e.type === 'deleted');
      const createEvent = events.find(e => e.type === 'created');

      if (deleteEvent && createEvent) {
        const timeDiff = Math.abs(createEvent.timestamp - deleteEvent.timestamp);
        
        // If events happened within 2 seconds, treat as move
        if (timeDiff < 2000) {
          moves.push({
            oldUri: deleteEvent.uri,
            newUri: createEvent.uri,
            filename: itemName,
            timestamp: createEvent.timestamp
          });
          continue;
        }
      }

      // Otherwise, process as individual create/delete
      if (createEvent && !deleteEvent) {
        creates.push(createEvent.uri);
      }
      
      if (deleteEvent && !createEvent) {
        deletes.push(deleteEvent.uri);
      }
    }

    // Clear processed events
    this.changeEvents.clear();

    // Process moves
    for (const move of moves) {
      if (move.newUri) {
        await this.handleMove(move.newUri, move.filename);
      }
    }

    // Note: Creates and deletes are handled by user's manual commands
    // We only auto-fix moves here
  }

  private async handleMove(newUri: vscode.Uri, itemName: string) {
    try {
      const scriptPath = path.join(this.context.extensionPath, 'src', 'scripts', 'auto_fix_file.rb');
      const itemPath = newUri.fsPath;

      console.log(`Auto-fixing moved item: ${itemName}`);

      const { stdout, stderr } = await execFileAsync('ruby', [scriptPath, itemPath, 'moved']);
      
      if (stderr && stderr.trim()) {
        console.warn(`Ruby script stderr: ${stderr}`);
      }

      if (!stdout || !stdout.trim()) {
        console.warn(`No output from Ruby script for: ${itemName}`);
        return;
      }

      let result;
      try {
        result = JSON.parse(stdout);
      } catch (parseError) {
        console.error(`Failed to parse JSON output for ${itemName}:`, stdout);
        return;
      }
      
      if (result.success) {
        console.log(`✅ Auto-fixed: ${itemName} - ${result.message}`);
        // Silent success - don't show notification for every file
      } else if (result.error && result.error !== 'File not in project' && result.error !== 'No files to fix') {
        console.error(`Failed to auto-fix ${itemName}:`, result.error);
      }
    } catch (error: any) {
      // Only log real errors, not network/telemetry issues
      if (error.code === 'ENOENT') {
        console.error(`Ruby not found. Please ensure Ruby is installed.`);
      } else if (error.stderr) {
        console.error(`Ruby script error for ${itemName}:`, error.stderr);
      } else {
        console.error(`Error auto-fixing ${itemName}:`, error.message);
      }
    }
  }
}
