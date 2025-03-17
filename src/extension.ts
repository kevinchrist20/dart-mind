import * as vscode from 'vscode';
import { analyzeDartCode } from './index';

let decorationType: vscode.TextEditorDecorationType;

export function activate(context: vscode.ExtensionContext) {
	decorationType = vscode.window.createTextEditorDecorationType({
		before: {
			margin: '0 0 0 1em',
			textDecoration: 'none; display: inline-block; border-radius: 3px; padding: 0 3px; background-color: rgba(100, 100, 100, 0.3);'
		},
		rangeBehavior: vscode.DecorationRangeBehavior.ClosedOpen
	});

	// Register command to analyze current file
	let disposable = vscode.commands.registerCommand('dart-code-complexity.analyze', () => {
		const editor = vscode.window.activeTextEditor;
		if (editor) {
			updateComplexityDecorations(editor);
		}
	});

	// Listen to document changes
	vscode.workspace.onDidChangeTextDocument(event => {
		const editor = vscode.window.activeTextEditor;
		if (editor && event.document === editor.document &&
			event.document.languageId === 'dart') {
			updateComplexityDecorations(editor);
		}
	});

	// Listen to editor changes
	vscode.window.onDidChangeActiveTextEditor(editor => {
		if (editor && editor.document.languageId === 'dart') {
			updateComplexityDecorations(editor);
		}
	});

	// Initial analysis of open editors
	if (vscode.window.activeTextEditor &&
		vscode.window.activeTextEditor.document.languageId === 'dart') {
		updateComplexityDecorations(vscode.window.activeTextEditor);
	}

	context.subscriptions.push(disposable);
}

async function updateComplexityDecorations(editor: vscode.TextEditor) {
	const isEnabled = vscode.workspace.getConfiguration('dartCodeComplexity').get('enabled', true);
	if (!isEnabled || editor.document.languageId !== 'dart') {
		return;
	}

	const text = editor.document.getText();
	const results = await analyzeDartCode(text);

	const decorations: vscode.DecorationOptions[] = [];

	results.forEach(result => {
		const startPos = editor.document.positionAt(result.startPosition - 1);
		decorations.push({
			range: new vscode.Range(startPos, startPos),
			renderOptions: {
				before: {
					contentText: `Complexity is ${result.cognitiveComplexity}. ${result.message}`,
					color: getComplexityColor(result.cognitiveComplexity)
				}
			}
		});
	});

	editor.setDecorations(decorationType, decorations);
}

function getComplexityColor(complexity: number): string {
	if (complexity <= 8) return '#4caf50'; // Green
	if (complexity <= 15) return '#ff9800'; // Orange
	return '#f44336'; // Red
}

export function deactivate() {
	if (decorationType) {
		decorationType.dispose();
	}
}
