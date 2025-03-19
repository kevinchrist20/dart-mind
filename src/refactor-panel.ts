import * as vscode from 'vscode';

export class RefactorPanel {
  public static currentPanel: RefactorPanel | undefined;
  private readonly _panel: vscode.WebviewPanel;
  private readonly _extensionUri: vscode.Uri;

  private constructor(panel: vscode.WebviewPanel, extensionUri: vscode.Uri) {
    this._panel = panel;
    this._extensionUri = extensionUri;
    
    this._panel.onDidDispose(() => this.dispose(), null);

    this._panel.webview.html = this._getHtmlForWebview();
  }

  public static createOrShow(extensionUri: vscode.Uri, document: vscode.TextDocument, position: vscode.Position, complexityScore: number) {
    if (RefactorPanel.currentPanel) {
      RefactorPanel.currentPanel._panel.reveal(vscode.ViewColumn.Beside);
      return;
    }

    const panel = vscode.window.createWebviewPanel(
      'refactorPanel',
      'DartMind - Refactoring Suggestions',
      vscode.ViewColumn.Beside,
      {
        enableScripts: true
      }
    );

    RefactorPanel.currentPanel = new RefactorPanel(panel, extensionUri);
  }

  public dispose() {
    RefactorPanel.currentPanel = undefined;
    this._panel.dispose();
  }

  private _getHtmlForWebview(): string {
    return `
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Refactoring Suggestions</title>
        <style>
          body { font-family: Arial, sans-serif; padding: 20px; }
          h2 { color: #007acc; }
          .suggestion { margin-bottom: 10px; padding: 10px; background: #f3f3f3; border-radius: 5px; }
        </style>
      </head>
      <body>
        <h2>Refactoring Suggestions</h2>
        <div class="suggestion">🔹 Consider splitting this method into smaller functions.</div>
        <div class="suggestion">🔹 Reduce the number of nested conditions.</div>
        <div class="suggestion">🔹 Use early returns to simplify branching.</div>
        <div class="suggestion">🔹 Extract common logic into reusable functions.</div>
      </body>
      </html>
    `;
  }
}
