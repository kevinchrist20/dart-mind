import * as vscode from 'vscode';
import { BasePanel } from './base-panel';
import { ComplexityResult, VIEWS } from '../types';
import { getComplexityDecoration, capitalize } from '../utils';

export class RefactorPanel extends BasePanel {
  private static instance: RefactorPanel | undefined;
  
  private constructor(extensionUri: vscode.Uri, column: vscode.ViewColumn) {
    super(
      VIEWS.REFACTOR_PANEL,
      'DartMind - Refactoring Suggestions',
      column,
      extensionUri,
      { enableScripts: true }
    );
  }

  /**
   * Creates or shows the refactor panel
   */
  public static createOrShow(
    extensionUri: vscode.Uri, 
    document: vscode.TextDocument, 
    position: vscode.Position, 
    complexityData: ComplexityResult
  ): RefactorPanel {
    const column = vscode.window.activeTextEditor 
      ? vscode.ViewColumn.Beside 
      : vscode.ViewColumn.One;

    // If we already have a panel, show it
    if (RefactorPanel.instance) {
      RefactorPanel.instance.reveal(column);
      RefactorPanel.instance.updateContent(complexityData);
      return RefactorPanel.instance;
    }

    // Otherwise, create a new panel
    RefactorPanel.instance = new RefactorPanel(extensionUri, column);
    RefactorPanel.instance.updateContent(complexityData);
    
    return RefactorPanel.instance;
  }

  /**
   * Disposes the panel
   */
  public dispose(): void {
    RefactorPanel.instance = undefined;
    super.dispose();
  }

  /**
   * Generates HTML content for the refactor panel
   */
  protected getHtmlContent(): string {
    const data = this.data as ComplexityResult;
    
    if (!data) {
      return this.getLoadingHtml();
    }

    const { color, icon } = getComplexityDecoration(data.complexityCategory);
    
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
            color: ${color}; 
            border-bottom: 1px solid #eee; 
            padding-bottom: 10px; 
          }
          .metrics-box {
            background-color: #f8f8f8;
            border-radius: 5px;
            padding: 15px;
            margin-bottom: 20px;
            border-left: 4px solid ${color};
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
        <h2>${icon} ${capitalize(data.type)} Complexity Analysis</h2>
        
        <div class="metrics-box">
          <table class="metrics-table">
            <tr>
              <td>Name:</td>
              <td><strong>${data.name}</strong></td>
            </tr>
            <tr>
              <td>Type:</td>
              <td>${capitalize(data.type)}</td>
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

  /**
   * Generates HTML for loading state
   */
  private getLoadingHtml(): string {
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
}
