'use client';

// Client leaf: clipboard access and the copied state.
import { useEffect, useRef, useState } from 'react';
import { Check, Copy } from 'lucide-react';
import { cn } from '@/lib/cn';
import type {
  CopyControlProps,
  CopyControlVariant,
} from './copy-control.types';

const RESET_MS = 1600;

const variants = {
  labelled:
    'border-ip-border-control bg-ip-surface text-ip-text-primary hover:bg-ip-hover h-10 gap-2 rounded-[8px] border px-3.5 text-sm font-semibold',
  icon: 'text-ip-text-secondary hover:bg-ip-selection hover:text-ip-text-primary size-9 rounded-[8px]',
  boxed:
    'border-ip-border-control text-ip-text-primary hover:bg-ip-hover size-10 rounded-[8px] border',
  row: 'text-ip-text-primary hover:bg-ip-hover h-12 w-full justify-between gap-3 px-3 text-left',
} as const satisfies Record<CopyControlVariant, string>;

/**
 * Copy-to-clipboard button for the Ink and Paper pages. Shows a check for
 * 1.6s after copying and announces the result to screen readers.
 */
export function CopyControl({
  text,
  label,
  copyText,
  copiedText,
  variant = 'icon',
  className,
  children,
}: CopyControlProps) {
  const [copied, setCopied] = useState(false);
  const timer = useRef<number | undefined>(undefined);

  useEffect(() => () => window.clearTimeout(timer.current), []);

  async function copy() {
    try {
      await navigator.clipboard.writeText(text);
      setCopied(true);
      window.clearTimeout(timer.current);
      timer.current = window.setTimeout(() => setCopied(false), RESET_MS);
    } catch {
      // Intentional fallback: clipboard access can be denied (insecure
      // context, permissions); the command stays visible to select by hand.
    }
  }

  const Icon = copied ? Check : Copy;
  return (
    <button
      type="button"
      aria-label={label}
      onClick={() => void copy()}
      className={cn(
        'flex shrink-0 cursor-pointer items-center justify-center transition-colors',
        variants[variant],
        className
      )}
    >
      {children}
      <Icon size={variant === 'row' ? 15 : 16} aria-hidden="true" />
      {variant === 'labelled' ? (
        <span aria-hidden="true">{copied ? copiedText : copyText}</span>
      ) : null}
      <span className="sr-only" aria-live="polite">
        {copied ? copiedText : ''}
      </span>
    </button>
  );
}
