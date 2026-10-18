import { cn } from '@/lib/cn';
import {
  kitButtonBase,
  kitButtonSizes,
  kitButtonVariants,
} from '@/lib/kit-classes';
import type { KitButtonProps, KitIconButtonProps } from './kit-actions.types';

/**
 * Demo button. Default preset: ink fill, scale on press. Neobrutalism:
 * Rule A (surface fill, ink border, flat offset, translate on press).
 */
export function KitButton({
  variant = 'primary',
  size = 'md',
  className,
  type = 'button',
  children,
  ...rest
}: KitButtonProps) {
  return (
    <button
      type={type}
      className={cn(
        kitButtonBase,
        kitButtonSizes[size],
        kitButtonVariants[variant],
        className
      )}
      {...rest}
    >
      {children}
    </button>
  );
}

/** Square secondary button that holds one icon. */
export function KitIconButton({
  label,
  className,
  type = 'button',
  children,
  ...rest
}: KitIconButtonProps) {
  return (
    <button
      type={type}
      aria-label={label}
      className={cn(
        kitButtonBase,
        kitButtonSizes.icon,
        kitButtonVariants.secondary,
        className
      )}
      {...rest}
    >
      {children}
    </button>
  );
}
