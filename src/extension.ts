import * as vscode from 'vscode';
import { LspService, ComplexityService } from './services';

/**
 * Extension activation
 */
export function activate(context: vscode.ExtensionContext) {
  // Initialize LSP service
  const lspService = new LspService(context.extensionPath);
  const client = lspService.start();
  
  // Initialize complexity service
  const complexityService = new ComplexityService(context);
  const complexityCommands = complexityService.registerCommands();
  
  // Register disposables
  context.subscriptions.push(client);
  context.subscriptions.push(...complexityCommands);
}

/**
 * Extension deactivation
 */
export function deactivate(): Thenable<void> | undefined {
  // Get all registered language clients
  const lspService = new LspService('');
  return lspService.stop();
}