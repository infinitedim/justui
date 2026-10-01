'use client';

import { useEffect, useId, useRef, type KeyboardEvent } from 'react';
import { createPortal } from 'react-dom';
import { X } from 'lucide-react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { CopyButton } from '@/components/molecules/copy-button';
import { focusRing, raised } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

export interface DartCodeModalProps {
  slug: string;
  code: string;
  isOpen: boolean;
  /** Called on Escape, backdrop click or the close button. The caller restores focus. */
  onClose: () => void;
}

const FOCUSABLE =
  'a[href], button:not([disabled]), textarea, input, select, [tabindex]:not([tabindex="-1"])';

/**
 * Modal with the example Dart snippet. Focus moves to the close button on
 * open and stays inside the dialog (Tab and Shift+Tab wrap) until it closes.
 * The code is rendered as text, never as HTML.
 */
export function DartCodeModal({
  slug,
  code,
  isOpen,
  onClose,
}: DartCodeModalProps) {
  const { ui } = useCatalogI18n();
  const titleId = useId();
  const dialogRef = useRef<HTMLDivElement>(null);
  const closeRef = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    if (!isOpen) return;
    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    closeRef.current?.focus();
    const onDocumentKeyDown = (event: globalThis.KeyboardEvent) => {
      if (event.key === 'Escape') onClose();
    };
    document.addEventListener('keydown', onDocumentKeyDown);
    return () => {
      document.body.style.overflow = previousOverflow;
      document.removeEventListener('keydown', onDocumentKeyDown);
    };
  }, [isOpen, onClose]);

  if (!isOpen || typeof document === 'undefined') return null;

  // Escape is handled on the document (above); this keeps Tab inside.
  const onKeyDown = (event: KeyboardEvent<HTMLDivElement>) => {
    if (event.key !== 'Tab') return;
    const nodes = dialogRef.current?.querySelectorAll<HTMLElement>(FOCUSABLE);
    if (!nodes || nodes.length === 0) return;
    const first = nodes[0];
    const last = nodes[nodes.length - 1];
    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault();
      last?.focus();
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault();
      first?.focus();
    }
  };

  return createPortal(
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div
        aria-hidden="true"
        onClick={onClose}
        data-testid="dart-code-modal-backdrop"
        className="bg-foreground/40 absolute inset-0"
      />
      {/* eslint-disable-next-line jsx-a11y/no-noninteractive-element-interactions -- onKeyDown only traps Tab/Shift+Tab focus inside the modal; not a user interaction handler. */}
      <div
        ref={dialogRef}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        onKeyDown={onKeyDown}
        data-testid="dart-code-modal"
        className={cn(
          raised,
          'bg-elevated relative w-full max-w-lg p-4 shadow-lg'
        )}
      >
        <div className="border-border mb-3 flex items-center justify-between gap-3 border-b pb-3">
          <h2
            id={titleId}
            className="text-foreground font-mono text-sm font-medium"
          >
            just_{slug.replace(/-/g, '_')}.dart
          </h2>
          <div className="flex items-center gap-2">
            <CopyButton
              text={code}
              label={ui.codeDialogCopy}
              copiedLabel={ui.copied}
            />
            <button
              ref={closeRef}
              type="button"
              onClick={onClose}
              aria-label={ui.codeDialogClose}
              className={cn(
                focusRing,
                'text-muted hover:text-foreground inline-flex h-7 w-7 items-center justify-center rounded-(--just-radius-md)'
              )}
            >
              <X className="h-4 w-4" aria-hidden="true" />
            </button>
          </div>
        </div>
        <pre className="bg-background text-foreground border-border max-h-[60vh] overflow-auto rounded-(--just-radius-md) border-(length:--just-border-width) p-3 font-mono text-[13px] leading-relaxed">
          <code>{code}</code>
        </pre>
      </div>
    </div>,
    document.body
  );
}
