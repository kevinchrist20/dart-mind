import * as vscode from 'vscode';
import { ComplexityResult } from './utils';

export class RefactorPanel {
  public static currentPanel: RefactorPanel | undefined;
  private readonly _panel: vscode.WebviewPanel;
  private readonly _extensionUri: vscode.Uri;
  private _complexityData: ComplexityResult | undefined;

  private constructor(panel: vscode.WebviewPanel, extensionUri: vscode.Uri) {
    this._panel = panel;
    this._extensionUri = extensionUri;
    
    this._panel.onDidDispose(() => this.dispose(), null);

    // Set initial HTML content
    this._panel.webview.html = this._getHtmlForWebview();
  }

  public static createOrShow(
    extensionUri: vscode.Uri, 
    document: vscode.TextDocument, 
    position: vscode.Position, 
    complexityData: ComplexityResult
  ) {
    const columnToShowIn = vscode.window.activeTextEditor 
      ? vscode.ViewColumn.Beside 
      : vscode.ViewColumn.One;

    if (RefactorPanel.currentPanel) {
      RefactorPanel.currentPanel._panel.reveal(columnToShowIn);
      RefactorPanel.currentPanel._updateContent(complexityData);
      return;
    }

    const panel = vscode.window.createWebviewPanel(
      'refactorPanel',
      'DartMind - Refactoring Suggestions',
      columnToShowIn,
      {
        enableScripts: true
      }
    );

    RefactorPanel.currentPanel = new RefactorPanel(panel, extensionUri);
    RefactorPanel.currentPanel._updateContent(complexityData);
  }

  private _updateContent(complexityData: ComplexityResult) {
    this._complexityData = complexityData;
    this._panel.webview.html = this._getHtmlForWebview();
  }

  public dispose() {
    RefactorPanel.currentPanel = undefined;
    this._panel.dispose();
  }

  private _getHtmlForWebview(): string {
    const data = this._complexityData;
    
    if (!data) {
      return `
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Refactoring Suggestions</title>
          <style>
            body { font-family: Arial, sans-serif; padding: 20px; color: #333; line-height: 1.6; }
            h2 { color: #007acc; border-bottom: 1px solid #eee; padding-bottom: 10px; }
            .loading { text-align: center; font-style: italic; color: #666; }
          </style>
        </head>
        <body>
          <h2>Refactoring Suggestions</h2>
          <div class="loading">Loading complexity data...</div>
        </body>
        </html>
      `;
    }

    // Determine styles and icons based on complexity category
    let headerColor = '#007acc';
    let headerIcon = '🔍';
    
    switch (data.complexityCategory.toLowerCase()) {
      case 'high':
        headerColor = '#e51400';
        headerIcon = '❌';
        break;
      case 'medium':
        headerColor = '#f09000';
        headerIcon = '⚠️';
        break;
      case 'low':
        headerColor = '#008000';
        headerIcon = '✅';
        break;
    }

    // Generate suggestions HTML
    let suggestionsHtml = '';
    if (data.refactoringSuggestions && data.refactoringSuggestions.length > 0) {
      suggestionsHtml = data.refactoringSuggestions
        .map(suggestion => `<div class="suggestion">🔹 ${suggestion}</div>`)
        .join('');
    } else {
      suggestionsHtml = '<div class="no-suggestions">No specific suggestions available.</div>';
    }

    return `
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Refactoring Suggestions</title>
        <style>
          body { 
            font-family: Arial, sans-serif; 
            padding: 20px; 
            color: #333; 
            line-height: 1.6;
            max-width: 800px;
            margin: 0 auto;
          }
          h2 { 
            color: ${headerColor}; 
            border-bottom: 1px solid #eee; 
            padding-bottom: 10px; 
          }
          .metrics-box {
            background-color: #f8f8f8;
            border-radius: 5px;
            padding: 15px;
            margin-bottom: 20px;
            border-left: 4px solid ${headerColor};
          }
          .metrics-table {
            width: 100%;
            border-collapse: collapse;
          }
          .metrics-table td {
            padding: 8px;
            border-bottom: 1px solid #eee;
          }
          .metrics-table td:first-child {
            font-weight: bold;
            width: 40%;
          }
          .suggestion { 
            margin-bottom: 15px; 
            padding: 12px; 
            background: #f8f8f8; 
            border-radius: 5px; 
            border-left: 4px solid #007acc;
          }
          .suggestions-container {
            margin-top: 20px;
          }
          .no-suggestions {
            font-style: italic;
            color: #666;
          }
        </style>
      </head>
      <body>
        <h2>${headerIcon} ${data.type.charAt(0).toUpperCase() + data.type.slice(1)} Complexity Analysis</h2>
        
        <div class="metrics-box">
          <table class="metrics-table">
            <tr>
              <td>Name:</td>
              <td><strong>${data.name}</strong></td>
            </tr>
            <tr>
              <td>Type:</td>
              <td>${data.type.charAt(0).toUpperCase() + data.type.slice(1)}</td>
            </tr>
            <tr>
              <td>Complexity Score:</td>
              <td><strong>${data.cognitiveComplexity}</strong> (${data.complexityCategory})</td>
            </tr>
            <tr>
              <td>Nesting Level:</td>
              <td>${data.nestingLevel}</td>
            </tr>
            <tr>
              <td>Number of Parameters:</td>
              <td>${data.numberOfParameters}</td>
            </tr>
          </table>
        </div>
        
        <h3>Refactoring Suggestions</h3>
        <div class="suggestions-container">
          ${suggestionsHtml}
        </div>
      </body>
      </html>
    `;
  }
}
