import * as vscode from 'vscode';
import { COMMANDS } from '../types';
import { RefactorPanel } from '../panels';

export class ComplexityService {
  private readonly context: vscode.ExtensionContext;

  constructor(context: vscode.ExtensionContext) {
    this.context = context;
  }

  public registerCommands(): vscode.Disposable[] {
    const commandHandler = vscode.commands.registerCommand(
      COMMANDS.SHOW_COMPLEXITY,
      this.handleShowComplexity.bind(this)
    );

    return [commandHandler];
  }

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
