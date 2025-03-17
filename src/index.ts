import { exec } from 'child_process';
import { promisify } from 'util';
import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';

const execAsync = promisify(exec);

export interface ComplexityResult {
    name: string;
    type: 'function' | 'method';
    cognitiveComplexity: number;
    nestingLevel: number;
    numberOfParameters: number;
    lineCount: number;
    message: string;
    category: string;
    startPosition: number;
    endPosition: number;
}

export async function analyzeDartCode(code: string): Promise<ComplexityResult[]> {
    const tempFile = path.join(os.tmpdir(), `dart_analysis_${Date.now()}.dart`);
    fs.writeFileSync(tempFile, code);

    // Use absolute path to the analyzer script
    const analyzerPath = path.resolve(__dirname, '../src/analyzer/bin/main.dart');

    try {
        const { stdout } = await execAsync(`dart run "${analyzerPath}" "${tempFile}"`);
        try {
            return JSON.parse(stdout);
        } catch (e) {
            console.error('Failed to parse analyzer output:', stdout);
            return [];
        }
    } catch (error) {
        console.error('Error running dart analyzer:', error);
        return [];
    } finally {
        // Clean up temp file
        try {
            fs.unlinkSync(tempFile);
        } catch (e) {
            // Ignore errors while removing temp file
        }
    }
}