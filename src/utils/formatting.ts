/**
 * Capitalizes the first letter of a string
 */
export function capitalize(text: string): string {
  if (!text || text.length === 0) {
    return '';
  }
  return text.charAt(0).toUpperCase() + text.slice(1);
}
