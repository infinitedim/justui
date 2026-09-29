import type { ButtonHTMLAttributes, ReactNode } from 'react';
import { cn } from '@/lib/cn';

export type JustButtonVariant =
  | 'primary'
  | 'secondary'
  | 'ghost'
  | 'destructive'
  | 'link';
export type JustButtonSize = 'xs' | 'sm' | 'md' | 'lg' | 'xl';

const border = 'border-(length:--just-border-width)';

const VARIANT: Record<JustButtonVariant, string> = {
  primary: `bg-accent text-accent-foreground ${border} border-border shadow-sm`,
  secondary: `bg-card text-foreground ${border} border-border shadow-sm`,
  ghost: `text-secondary hover:bg-card ${border} border-transparent bg-transparent`,
  destructive: `bg-destructive-solid text-on-destructive ${border} border-border shadow-sm`,
  link: `text-accent-text ${border} border-transparent bg-transparent underline underline-offset-4`,
};

const SIZE: Record<JustButtonSize, string> = {
  xs: 'h-7 px-2.5 text-xs',
  sm: 'h-8 px-3 text-[13px]',
  md: 'h-9 px-4 text-sm',
  lg: 'h-11 px-5 text-base',
  xl: 'h-[52px] px-6 text-lg',
};

interface JustButtonPreviewProps
  extends Omit<ButtonHTMLAttributes<HTMLButtonElement>, 'children'> {
  variant?: JustButtonVariant;
  size?: JustButtonSize;
  loading?: boolean;
  fullWidth?: boolean;
  leading?: ReactNode;
  trailing?: ReactNode;
  children?: ReactNode;
}

/**
 * Docs-only visual stand-in for the Flutter JustButton. It reproduces the
 * documented variants, sizes and states with --just-* tokens, so it follows
 * whichever preset scope it is rendered in.
 */
export function JustButtonPreview({
  variant = 'primary',
  size = 'md',
  loading = false,
  fullWidth = false,
  disabled,
  leading,
  trailing,
  className,
  children,
  ...rest
}: JustButtonPreviewProps) {
  const inert = disabled || loading;
  return (
    <button
      type="button"
      disabled={inert}
      aria-busy={loading || undefined}
      className={cn(
        'just-press inline-flex items-center justify-center gap-2 rounded-(--just-radius-md) font-medium',
        VARIANT[variant],
        SIZE[size],
        fullWidth && 'w-full',
        disabled && 'opacity-50',
        inert ? 'cursor-not-allowed' : 'cursor-pointer',
        className
      )}
      {...rest}
    >
      {loading ? (
        <span
          className="inline-block h-4 w-4 animate-spin rounded-full border-2 border-current border-t-transparent"
          aria-hidden="true"
        />
      ) : (
        <>
          {leading}
          <span>{children}</span>
          {trailing}
        </>
      )}
    </button>
  );
}
