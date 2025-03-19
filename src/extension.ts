import * as vscode from 'vscode';
import * as path from 'path';
import {
	LanguageClient,
	LanguageClientOptions,
	ServerOptions,
} from 'vscode-languageclient/node';

let client: LanguageClient;

export function activate(context: vscode.ExtensionContext) {
	const serverOptions: ServerOptions = {
		command: 'dart',
		args: [path.join(context.extensionPath, 'server', 'bin', 'main.dart')],
	};

	const clientOptions: LanguageClientOptions = {
		documentSelector: [{ scheme: 'file', language: 'dart' }],
		synchronize: {
			fileEvents: vscode.workspace.createFileSystemWatcher('**/*.dart')
		},
		middleware: {
			provideCodeLenses: async (document, token, next) => {
				const codeLenses = await next(document, token);
				return codeLenses;
			}
		}
	};

	client = new LanguageClient(
		'dart-guide-server',
		'Dart Guide Server',
		serverOptions,
		clientOptions
	);

	client.start();
}

export async function deactivate(): Promise<void> {
	if (client) {
		await client.stop();
	}
}
