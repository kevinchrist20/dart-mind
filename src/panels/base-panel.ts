import * as vscode from 'vscode';

/**
 * Base class for webview panels
 */
export abstract class BasePanel {
  protected panel: vscode.WebviewPanel;
  protected extensionUri: vscode.Uri;
  protected data: any;

  constructor(
    viewType: string,
    title: string,
    column: vscode.ViewColumn, 
    extensionUri: vscode.Uri,
    options: vscode.WebviewPanelOptions & vscode.WebviewOptions = { enableScripts: true }
  ) {
    this.extensionUri = extensionUri;
    
    this.panel = vscode.window.createWebviewPanel(
      viewType,
      title,
      column,
      options
    );
    
    this.panel.onDidDispose(() => this.dispose());
    
    // Set initial HTML content
    this.updateContent(null);
  }

  /**
   * Update panel content with new data
   */
  public updateContent(data: any): void {
    this.data = data;
    this.panel.webview.html = this.getHtmlContent();
  }

  /**
   * Reveal the panel
   */
  public reveal(column?: vscode.ViewColumn): void {
    this.panel.reveal(column);
  }

  /**
   * Dispose the panel
   */
  public dispose(): void {
    this.panel.dispose();
  }

  /**
   * Generate HTML content for the webview
   */
  protected abstract getHtmlContent(): string;
}
