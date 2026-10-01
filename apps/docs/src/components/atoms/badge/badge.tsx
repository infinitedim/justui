import { cn } from '@/lib/cn';
import type { BadgeProps, BadgeVariant } from './badge.types';

const variantClassMap: Record<BadgeVariant, string> = {
  default:
    'bg-card text-secondary border border-[length:var(--just-border-width)] border-border',
  // Status variants tint the background and border; the text stays in the
  // foreground token so small labels keep AA contrast in every theme.
  accent:
    'bg-accent-muted text-foreground border border-[length:var(--just-border-width)] border-accent',
  success:
    'bg-success/10 text-foreground border border-[length:var(--just-border-width)] border-success',
  warning:
    'bg-warning/10 text-foreground border border-[length:var(--just-border-width)] border-warning',
  error:
    'bg-error/10 text-foreground border border-[length:var(--just-border-width)] border-error',
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
        'inline-flex items-center rounded-(--just-radius-sm) px-2 py-0.5 text-xs font-medium',
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
