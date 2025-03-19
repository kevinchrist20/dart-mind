export interface ComplexityResult {
  name: string;
  type: 'function' | 'method';
  complexityCategory: string;
  cognitiveComplexity: number;
  nestingLevel: number;
  numberOfParameters: number;
  refactoringSuggestions: string[];
}