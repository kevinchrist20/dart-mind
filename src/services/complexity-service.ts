import * as vscode from 'vscode';
import { COMMANDS } from '../types';
import { RefactorPanel } from '../panels';

export class ComplexityService {
  private readonly context: vscode.ExtensionContext;

  constructor(context: vscode.ExtensionContext) {
    this.context = context;
  }

  /**
   * Register complexity analysis commands
   */
  public registerCommands(): vscode.Disposable[] {
    const commandHandler = vscode.commands.registerCommand(
      COMMANDS.SHOW_COMPLEXITY,
      this.handleShowComplexity.bind(this)
    );

    return [commandHandler];
  }

  /**
   * Handle the show complexity command
   */
  private handleShowComplexity(details: any): void {
    if (!details) {
      return;
    }

    const {
      name,
      type,
      complexityCategory,
      cognitiveComplexity,
      nestingLevel,
      numberOfParameters,
      refactoringSuggestions
    } = details;
    
    // Pass all data to the refactor panel
    RefactorPanel.createOrShow(
      this.context.extensionUri,
      vscode.window.activeTextEditor?.document!,
      vscode.window.activeTextEditor?.selection.active!,
      {
        name,
        type,
        complexityCategory,
        cognitiveComplexity,
        nestingLevel,
        numberOfParameters,
        refactoringSuggestions: refactoringSuggestions || []
      }
    );
  }
}
