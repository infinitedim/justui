'use client';

import { useCallback, useEffect, useState } from 'react';
import { Check, Copy } from 'lucide-react';
import { cn } from '@/lib/cn';
import type { CopyButtonProps } from './copy-button.types';

const FEEDBACK_MS = 2000;

/**
 * Copy-to-clipboard molecule. Shows a check for two seconds after a
 * successful write and announces it to screen readers; a failed write shows
 * nothing, so the UI never claims a copy that did not happen.
 */
export function CopyButton({
  text,
  label = 'Copy to clipboard',
  copiedLabel = 'Copied',
  className,
}: CopyButtonProps) {
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    if (!copied) return;
    const id = window.setTimeout(() => setCopied(false), FEEDBACK_MS);
    return () => window.clearTimeout(id);
  }, [copied]);

  const handleCopy = useCallback(async () => {
    try {
      await navigator.clipboard.writeText(text);
      setCopied(true);
    } catch {
      // Clipboard can be blocked (insecure context, permissions); stay silent.
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
