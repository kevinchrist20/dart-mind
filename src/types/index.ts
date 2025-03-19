/**
 * Represents the result of a code complexity analysis
 */
export interface ComplexityResult {
    name: string;
    type: 'function' | 'method';
    complexityCategory: string;
    cognitiveComplexity: number;
    nestingLevel: number;
    numberOfParameters: number;
    refactoringSuggestions: string[];
    lineCount?: number;
    startPosition?: number;
    endPosition?: number;
    riskAssessment?: string;
  }

export interface PanelData {
  document: any;
  position: any;
  data: any;
}

// Command identifiers
export const COMMANDS = {
    SHOW_COMPLEXITY: 'dartmind.showComplexity',
    ANALYZE_WORKSPACE: 'dartmind.analyzeWorkspace',
    OPEN_SETTINGS: 'dartmind.openSettings',
  };
  
  // View identifiers
  export const VIEWS = {
    REFACTOR_PANEL: 'dartmind.refactorPanel',
  };
  
  // Risk levels
  export const RISK_LEVELS = {
    HIGH: {
      color: '#e51400',
      icon: '❌',
      name: 'High',
      threshold: 15,
    },
    MEDIUM: {
      color: '#f09000',
      icon: '⚠️',
      name: 'Medium',
      threshold: 8,
    },
    LOW: {
      color: '#008000',
      icon: '✅',
      name: 'Low',
      threshold: 0,
    },
  };
  