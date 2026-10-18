import type { ButtonHTMLAttributes, ReactNode } from 'react';

export type KitButtonVariant = 'primary' | 'secondary' | 'destructive';

export type KitButtonSize = 'md' | 'sm';

export interface KitButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: KitButtonVariant;
  size?: KitButtonSize;
  children: ReactNode;
}

export interface KitIconButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  /** Accessible name; the button shows only an icon. */
  label: string;
  children: ReactNode;
}
