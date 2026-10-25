'use client';

// Client leaf: clipboard access and the copied state.
import { Check, Copy } from 'lucide-react';
import { GateLines } from '@/components/atoms/gate';
import { cn } from '@/lib/cn';
import { useCopyText } from '@/lib/use-copy-text';
import type { CopyGateProps } from './copy-gate.types';

/**
 * A runner gate whose label copies a command (landing v3 Parts index):
 * the code, the part name and a copy icon that turns into a check.
 */
export function CopyGate({
  code,
  name,
  text,
  label,
  copiedText,
  className,
}: CopyGateProps) {
  const { copied, copy } = useCopyText(text);
  const Icon = copied ? Check : Copy;
  return (
    <div className={cn('flex items-start gap-2', className)}>
      <GateLines />
      {/* The visible code and name lead the accessible name (WCAG 2.5.3,
          label in name); the hidden hint says what the button does. */}
      <button
        type="button"
        onClick={() => void copy()}
        className="text-ip-text-primary hover:bg-ip-hover mt-[3px] flex h-[26px] cursor-pointer items-center gap-1.5 rounded-[6px] px-2 text-xs font-bold whitespace-nowrap transition-colors duration-150"
      >
        <span>{code}</span>{' '}
        <code className="font-sans font-medium">{name}</code>{' '}
        <span className="sr-only">- {label}</span>
        <Icon
          size={12}
          aria-hidden="true"
          className={copied ? undefined : 'opacity-70'}
        />
      </button>
      <span className="sr-only" aria-live="polite">
        {copied ? copiedText : ''}
      </span>
    </div>
  );
}
