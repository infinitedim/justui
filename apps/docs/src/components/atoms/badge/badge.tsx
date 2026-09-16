import { cn } from '@/lib/cn';
import type { BadgeProps, BadgeVariant } from './badge.types';

const variantClassMap: Record<BadgeVariant, string> = {
  default:
    'bg-card text-secondary border border-[length:var(--just-border-width)] border-border',
  accent:
    'bg-accent-muted text-accent-dark dark:text-accent-light border border-[length:var(--just-border-width)] border-accent',
  success:
    'bg-success/10 text-success border border-[length:var(--just-border-width)] border-success/30',
  warning:
    'bg-warning/10 text-warning border border-[length:var(--just-border-width)] border-warning/30',
  error:
    'bg-error/10 text-error border border-[length:var(--just-border-width)] border-error/30',
  outline:
    'bg-transparent text-foreground border border-[length:var(--just-border-width)] border-border',
};

/**
 * A small status indicator badge. Server Component.
 * Adapts to neobrutalism via --just-border-width and --just-shadow-solid.
 */
export function Badge({
  variant = 'default',
  className,
  children,
  ...rest
}: BadgeProps) {
  return (
    <span
      className={cn(
        'inline-flex items-center rounded-(--just-radius-md) px-2 py-0.5 font-mono text-[11px] font-medium',
        'shadow-solid',
        variantClassMap[variant],
        className
      )}
      {...rest}
    >
      {children}
    </span>
  );
}
