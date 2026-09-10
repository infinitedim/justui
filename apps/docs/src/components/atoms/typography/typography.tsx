import { cn } from '@/lib/cn';
import type { TypographyProps, TypographyVariant, TypographyWeight, TypographyColor } from './typography.types';
import type { ElementType } from 'react';

const variantTagMap: Record<TypographyVariant, ElementType> = {
  h1: 'h1',
  h2: 'h2',
  h3: 'h3',
  h4: 'h4',
  body: 'p',
  'body-sm': 'p',
  caption: 'span',
  overline: 'span',
  mono: 'span',
};

const variantClassMap: Record<TypographyVariant, string> = {
  h1: 'text-4xl font-bold tracking-tight md:text-5xl',
  h2: 'text-2xl font-semibold tracking-tight md:text-3xl',
  h3: 'text-xl font-semibold',
  h4: 'text-lg font-medium',
  body: 'text-base leading-7',
  'body-sm': 'text-sm leading-6',
  caption: 'text-xs leading-5',
  overline: 'text-[11px] font-semibold uppercase tracking-widest',
  mono: 'font-mono text-sm',
};

const weightClassMap: Record<TypographyWeight, string> = {
  normal: 'font-normal',
  medium: 'font-medium',
  semibold: 'font-semibold',
  bold: 'font-bold',
};

const colorClassMap: Record<TypographyColor, string> = {
  primary: 'text-foreground',
  secondary: 'text-secondary',
  muted: 'text-muted',
  accent: 'text-accent',
  error: 'text-error',
  success: 'text-success',
  warning: 'text-warning',
  inherit: '',
};

/**
 * A polymorphic typography atom that maps semantic variants to HTML elements
 * and applies JustUI design tokens via Tailwind utility classes.
 *
 * Server Component by default (no 'use client' directive).
 */
export function Typography({
  variant = 'body',
  as,
  weight,
  color = 'primary',
  truncate = false,
  className,
  children,
  ...rest
}: TypographyProps) {
  const Tag = as ?? variantTagMap[variant];

  return (
    <Tag
      className={cn(
        variantClassMap[variant],
        weight && weightClassMap[weight],
        colorClassMap[color],
        truncate && 'truncate',
        className,
      )}
      {...rest}
    >
      {children}
    </Tag>
  );
}
