'use client';

import { useState, useCallback } from 'react';
import { Check, Copy } from 'lucide-react';
import { cn } from '@/lib/cn';
import type { CopyButtonProps } from './copy-button.types';

/**
 * Copy-to-clipboard molecule. Composes the Button atom pattern with
 * a transient "copied" feedback state (2s timeout).
 */
export function CopyButton({
  text,
  label = 'Copy to clipboard',
  className,
}: CopyButtonProps) {
  const [copied, setCopied] = useState(false);

  const handleCopy = useCallback(async () => {
    await navigator.clipboard.writeText(text);
    setCopied(true);
    const id = window.setTimeout(() => setCopied(false), 2000);
    return () => window.clearTimeout(id);
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
        <Check size={14} className="text-accent" aria-hidden="true" />
      ) : (
        <Copy size={14} aria-hidden="true" />
      )}
    </button>
  );
}
