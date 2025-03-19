export interface ComplexityResult {
    name: string;
    type: 'function' | 'method';
    cognitiveComplexity: number;
    nestingLevel: number;
    numberOfParameters: number;
    complexityCategory: string;
}