import * as path from 'path';
import * as vscode from 'vscode';
import {
	LanguageClient,
	LanguageClientOptions,
	ServerOptions,
} from 'vscode-languageclient/node';
import { RefactorPanel } from './refactor-panel';

let client: LanguageClient;

export function activate(context: vscode.ExtensionContext) {
	const serverScript = path.join(context.extensionPath, 'server', 'bin', 'main.dart');

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

	client = new LanguageClient(
		'dart-guide',
		'Dart Guide',
		serverOptions,
		clientOptions
	);

	// Register command handler for complexity details
	const commandHandler = vscode.commands.registerCommand(
		'complexity.showComplexity',
		(details) => {
			if (details) {
				const {
					name,
					type,
					complexityCategory,
					cognitiveComplexity,
					nestingLevel,
					numberOfParameters,
					refactoringSuggestions
				} = details;
				
				RefactorPanel.createOrShow(
					context.extensionUri,
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
	);

	client.start();

	context.subscriptions.push(commandHandler);
	context.subscriptions.push(client);
}

export function deactivate(): Thenable<void> | undefined {
	if (!client) {
		return undefined;
	}
	return client.stop();
}