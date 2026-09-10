'use client';

import { cn } from '@/lib/cn';
import type { ButtonProps, ButtonVariant, ButtonSize } from './button.types';

const variantClassMap: Record<ButtonVariant, string> = {
  primary:
    'bg-accent text-foreground hover:bg-accent-dark active:bg-accent-deep',
  secondary:
    'bg-card text-foreground border border-[length:var(--just-border-width)] border-border hover:bg-elevated',
  ghost: 'bg-transparent text-secondary hover:bg-card hover:text-foreground',
  outline:
    'bg-transparent text-foreground border border-[length:var(--just-border-width)] border-border hover:bg-card',
  danger: 'bg-error text-white hover:opacity-90 active:opacity-80',
};

const sizeClassMap: Record<ButtonSize, string> = {
  sm: 'h-8 px-3 text-xs gap-1.5',
  md: 'h-9 px-4 text-sm gap-2',
  lg: 'h-11 px-6 text-base gap-2.5',
  icon: 'h-9 w-9 p-0 justify-center',
};

/**
 * Interactive button atom. Consumes --just-* CSS variables and respects
 * the .theme-neobrutalism class for border-width and shadow overrides.
 */
export function Button({
  variant = 'primary',
  size = 'md',
  loading = false,
  disabled,
  className,
  children,
  ...rest
}: ButtonProps) {
  const isDisabled = disabled || loading;

  return (
    <button
      type="button"
      disabled={isDisabled}
      className={cn(
        'inline-flex items-center justify-center font-medium transition-colors',
        'rounded-(--just-radius-md)',
        'shadow-solid',
        'focus-visible:outline-accent focus-visible:outline-2 focus-visible:outline-offset-2',
        'disabled:pointer-events-none disabled:opacity-50',
        variantClassMap[variant],
        sizeClassMap[size],
        className
      )}
      {...rest}
    >
      {loading ? (
        <span
          className="inline-block h-4 w-4 animate-spin rounded-full border-2 border-current border-t-transparent"
          aria-hidden="true"
        />
      ) : null}
      {children}
    </button>
  );
}
