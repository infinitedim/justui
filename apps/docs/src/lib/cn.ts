import { twMerge, type ClassNameValue } from 'tailwind-merge';

/**
 * Merges Tailwind CSS class names, resolving conflicts via tailwind-merge.
 * Falsy values are filtered out automatically.
 */
export function cn(...inputs: ClassNameValue[]): string {
  return twMerge(inputs);
}
