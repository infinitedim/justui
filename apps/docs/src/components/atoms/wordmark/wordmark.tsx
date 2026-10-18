import { cn } from '@/lib/cn';
import type { WordmarkProps } from './wordmark.types';

/** The lowercase "justui" wordmark set in Plus Jakarta Sans. */
export function Wordmark({ className }: WordmarkProps) {
  return (
    <span
      className={cn(
        'text-ip-text-primary text-xl font-bold tracking-[-0.03em]',
        className
      )}
    >
      justui
    </span>
  );
}
