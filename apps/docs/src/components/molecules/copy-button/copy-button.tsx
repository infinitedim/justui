'use client';

import { useState, useCallback, useEffect, useRef } from 'react';
import { Check, Copy } from 'lucide-react';
import { cn } from '@/lib/cn';
import type { CopyButtonProps } from './copy-button.types';

/**
 * Copy-to-clipboard molecule. Swaps the icon for a check for 2s after a
 * successful copy and announces it to screen readers.
 */
export function CopyButton({
  text,
  label = 'Copy to clipboard',
  copiedLabel = 'Copied',
  className,
}: CopyButtonProps) {
  const [copied, setCopied] = useState(false);
  const timeoutRef = useRef<number | undefined>(undefined);

  useEffect(() => () => window.clearTimeout(timeoutRef.current), []);

  const handleCopy = useCallback(async () => {
    try {
      await navigator.clipboard.writeText(text);
      setCopied(true);
      window.clearTimeout(timeoutRef.current);
      timeoutRef.current = window.setTimeout(() => setCopied(false), 2000);
    } catch {
      // Ignore clipboard permission errors in non-secure or restricted contexts
    }
  }, [text]);

  return (
    <button
      type="button"
      onClick={handleCopy}
      aria-label={label}
      className={cn(
        'inline-flex h-7 w-7 items-center justify-center rounded-(--just-radius-md) transition-colors',
        'border-border border-(length:--just-border-width)',
        'text-muted hover:text-foreground hover:bg-card',
        'focus-visible:outline-accent focus-visible:outline-2 focus-visible:outline-offset-2',
        className
      )}
    >
      {copied ? (
        <Check size={14} className="text-accent-text" aria-hidden="true" />
      ) : (
        <Copy size={14} aria-hidden="true" />
      )}
      <span className="sr-only" aria-live="polite">
        {copied ? copiedLabel : ''}
      </span>
    </button>
  );
}
