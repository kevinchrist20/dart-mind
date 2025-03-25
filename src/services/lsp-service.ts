import * as path from 'path';
import * as vscode from 'vscode';
import {
  LanguageClient,
  LanguageClientOptions,
  ServerOptions,
} from 'vscode-languageclient/node';

export class LspService {
  private client: LanguageClient | undefined;
  private readonly extensionPath: string;

  constructor(extensionPath: string) {
    this.extensionPath = extensionPath;
  }

  public start(): LanguageClient {
    const serverScript = path.join(this.extensionPath, 'server', 'bin', 'main.dart');

    const serverOptions: ServerOptions = {
      run: {
        command: 'dart',
        args: [serverScript],
      },
      debug: {
        command: 'dart',
        args: [serverScript, '--debug'],
      },
    };

    const clientOptions: LanguageClientOptions = {
      documentSelector: [{ scheme: 'file', language: 'dart' }],
      synchronize: {
        fileEvents: vscode.workspace.createFileSystemWatcher('**/*.dart'),
      },
    };

    this.client = new LanguageClient(
      'dart-mind',
      'DartMind',
      serverOptions,
      clientOptions
    );

    this.client.start();

    return this.client;
  }

  /**
   * Stop the LSP client
   */
  public stop(): Thenable<void> | undefined {
    if (!this.client) {
      return undefined;
    }
    return this.client.stop();
  }
}
