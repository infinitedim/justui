'use client';

import { useEffect, useId, useRef, useState } from 'react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import {
  focusRing,
  neutralControl,
  raised,
  tokenBorder,
} from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

export function DialogMock() {
  const { crm } = useCatalogI18n();
  const [open, setOpen] = useState(false);
  const titleId = useId();
  const bodyId = useId();
  const triggerRef = useRef<HTMLButtonElement>(null);
  const cancelRef = useRef<HTMLButtonElement>(null);
  const wasOpen = useRef(false);

  // Destructive confirmations start on the safe choice, and focus returns to
  // the trigger when the dialog closes.
  useEffect(() => {
    if (open) cancelRef.current?.focus();
    else if (wasOpen.current) triggerRef.current?.focus();
    wasOpen.current = open;
  }, [open]);

  useEffect(() => {
    if (!open) return;
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') setOpen(false);
    };
    document.addEventListener('keydown', onKeyDown);
    return () => document.removeEventListener('keydown', onKeyDown);
  }, [open]);

  const close = () => setOpen(false);

  return (
    <div className="relative flex h-36 w-full max-w-64 items-center justify-center">
      <button
        ref={triggerRef}
        type="button"
        onClick={() => setOpen(true)}
        data-testid="mock-dialog-trigger"
        className={cn(neutralControl, 'text-error h-9 px-4 text-sm')}
      >
        {crm.dialog.trigger}
      </button>

      {open ? (
        <div className="bg-background/70 absolute inset-0 z-10 flex items-center justify-center">
          <div
            role="alertdialog"
            aria-labelledby={titleId}
            aria-describedby={bodyId}
            data-testid="mock-dialog-content"
            className={cn(raised, 'w-full p-3.5')}
          >
            <h4 id={titleId} className="text-foreground text-sm font-semibold">
              {crm.dialog.title}
            </h4>
            <p id={bodyId} className="text-secondary mt-1 text-sm">
              {crm.dialog.body}
            </p>
            <div className="mt-3 flex justify-end gap-2">
              <button
                ref={cancelRef}
                type="button"
                onClick={close}
                className={cn(neutralControl, 'h-8 px-3 text-sm')}
              >
                {crm.dialog.cancel}
              </button>
              <button
                type="button"
                onClick={close}
                className={cn(
                  'just-press bg-destructive-solid text-on-destructive h-8 rounded-(--just-radius-md) px-3 text-sm font-medium',
                  tokenBorder,
                  focusRing
                )}
              >
                {crm.dialog.confirm}
              </button>
            </div>
          </div>
        </div>
      ) : null}
    </div>
  );
}
