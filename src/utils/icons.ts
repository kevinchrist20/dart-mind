import { RISK_LEVELS } from '../types';

/**
 * Gets color and icon based on the complexity category
 */
export function getComplexityDecoration(
    complexityCategory: string
): { color: string; icon: string } {
    const category = complexityCategory.toLowerCase();

    switch (category) {
        case 'high':
            return {
                color: RISK_LEVELS.HIGH.color,
                icon: RISK_LEVELS.HIGH.icon
            };
        case 'medium':
            return {
                color: RISK_LEVELS.MEDIUM.color,
                icon: RISK_LEVELS.MEDIUM.icon
            };
        case 'low':
            return {
                color: RISK_LEVELS.LOW.color,
                icon: RISK_LEVELS.LOW.icon
            };
        default:
            return {
                color: '#007acc',
                icon: '🔍'
            };
    }
}
