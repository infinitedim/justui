'use client';

import { useEffect, useRef } from 'react';
import { X } from 'lucide-react';
import { CopyButton } from '@/components/molecules/copy-button';

export interface DartCodeModalProps {
  name: string;
  code: string;
  isOpen: boolean;
  onClose: () => void;
  title?: string;
  closeLabel?: string;
}

export function DartCodeModal({
  name,
  code,
  isOpen,
  onClose,
  title = 'Example',
  closeLabel = 'Close',
}: DartCodeModalProps) {
  const closeRef = useRef<HTMLButtonElement>(null);

  // Lock body scroll and move focus into the dialog while it is open.
  useEffect(() => {
    if (!isOpen) return;
    const previouslyFocused = document.activeElement as HTMLElement | null;
    const prevOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    closeRef.current?.focus();
    return () => {
      document.body.style.overflow = prevOverflow;
      previouslyFocused?.focus?.();
    };
  }, [isOpen]);

  useEffect(() => {
    if (!isOpen) return;
    function onKeyDown(e: KeyboardEvent) {
      if (e.key === 'Escape') {
        onClose();
      }
    }
    document.addEventListener('keydown', onKeyDown);
    return () => document.removeEventListener('keydown', onKeyDown);
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return (
    // eslint-disable-next-line jsx-a11y/click-events-have-key-events, jsx-a11y/no-noninteractive-element-interactions
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby={`dart-code-title-${name}`}
      data-testid="dart-code-modal"
      onClick={(e) => {
        if (e.target === e.currentTarget) {
          onClose();
        }
      }}
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4"
    >
      <div className="bg-card border-border w-full max-w-lg overflow-hidden rounded-(--just-radius-lg) border-(length:--just-border-width) shadow-lg">
        <div className="border-border flex items-center justify-between gap-3 border-b border-b-(length:--just-border-width) px-4 py-2.5">
          <h2
            id={`dart-code-title-${name}`}
            className="text-foreground text-sm font-medium"
          >
            {name} <span className="text-muted font-normal">{title}</span>
          </h2>
          <div className="flex items-center gap-1.5">
            <CopyButton text={code} label={`Copy ${name} example`} />
            <button
              ref={closeRef}
              type="button"
              onClick={onClose}
              aria-label={closeLabel}
              className="text-muted hover:text-foreground focus-visible:outline-accent inline-flex h-7 w-7 items-center justify-center rounded-(--just-radius-md) focus-visible:outline-2"
            >
              <X className="h-4 w-4" aria-hidden="true" />
            </button>
          </div>
        </div>
        <pre className="text-foreground overflow-x-auto p-4 font-mono text-xs leading-relaxed">
          <code>{code}</code>
        </pre>
      </div>
    </div>
  );
}
