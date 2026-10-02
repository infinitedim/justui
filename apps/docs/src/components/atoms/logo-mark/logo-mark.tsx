import { cn } from '@/lib/cn';
import type { LogoMarkProps } from './logo-mark.types';

/**
 * JustUI brand glyph atom. Renders a geometric token-styled logo mark.
 * Uses CSS variables so it adapts seamlessly across light/dark and default/neobrutalism.
 */
export function LogoMark({ size = 22, className }: LogoMarkProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={cn('shrink-0', className)}
      aria-hidden="true"
    >
      <rect
        x="2.5"
        y="2.5"
        width="19"
        height="19"
        rx="4"
        className="stroke-border fill-card"
        strokeWidth="2"
      />
      <rect
        x="6"
        y="6"
        width="5"
        height="5"
        rx="1"
        className="fill-accent"
      />
      <path
        d="M15 7v7a3 3 0 0 1-3 3H9"
        className="stroke-foreground"
        strokeWidth="2"
        strokeLinecap="round"
      />
    </svg>
  );
}
