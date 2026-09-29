'use client';

import React, { useEffect } from 'react';
import { cn } from '@/lib/cn';
import { CopyButton } from '@/components/molecules/copy-button';
import { X } from 'lucide-react';

export interface DartCodeModalProps {
  name: string;
  code: string;
  isOpen: boolean;
  onClose: () => void;
  preset?: 'default' | 'neobrutalism';
}

export function DartCodeModal({
  name,
  code,
  isOpen,
  onClose,
  preset = 'default',
}: DartCodeModalProps) {
  // Lock body scroll when modal is open
  useEffect(() => {
    if (!isOpen) return;
    const prevOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => {
      document.body.style.overflow = prevOverflow;
    };
  }, [isOpen]);

  // Handle Escape key
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

  const isNeo = preset === 'neobrutalism';

  return (
    // eslint-disable-next-line jsx-a11y/click-events-have-key-events, jsx-a11y/no-noninteractive-element-interactions
    <div
      role="dialog"
      aria-modal="true"
      aria-label={`${name} Dart Code`}
      data-testid="dart-code-modal"
      onClick={(e) => {
        if (e.target === e.currentTarget) {
          onClose();
        }
      }}
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4 backdrop-blur-xs"
    >
      <div
        className={cn(
          'bg-surface w-full max-w-lg overflow-hidden p-5 font-mono text-xs transition-all',
          isNeo
            ? 'rounded-none border-[2.5px] border-black shadow-[6px_6px_0px_0px_#000] dark:border-white dark:shadow-[6px_6px_0px_0px_#fff]'
            : 'border-border rounded-xl border shadow-2xl'
        )}
      >
        <div className="border-border mb-3 flex items-center justify-between border-b pb-3">
          <div className="flex items-center gap-2">
            <span className="text-foreground text-sm font-bold">{name}</span>
            <span
              className={cn(
                'text-muted bg-surface-muted px-1.5 py-0.5 text-[10px]',
                isNeo ? 'rounded-full border border-black dark:border-white' : 'rounded'
              )}
            >
              Flutter Dart
            </span>
          </div>
          <div className="flex items-center gap-2">
            <CopyButton text={code} label="Copy Dart code" />
            <button
              type="button"
              onClick={onClose}
              aria-label="Close modal"
              className="text-muted hover:text-foreground p-1 transition-colors"
            >
              <X className="h-4 w-4" />
            </button>
          </div>
        </div>

        <pre
          className={cn(
            'bg-surface-muted/60 text-foreground overflow-x-auto p-3 leading-relaxed',
            isNeo ? 'rounded-none border border-black dark:border-white' : 'rounded'
          )}
        >
          <code>{code}</code>
        </pre>
      </div>
    </div>
  );
}
