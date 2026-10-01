'use client';

import { useEffect, useState } from 'react';
import { CheckCircle2, X } from 'lucide-react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { accentControl, focusRing, raised } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

const AUTO_DISMISS_MS = 5000;

export function ToastMock() {
  const { crm } = useCatalogI18n();
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    if (!visible) return;
    const timer = window.setTimeout(() => setVisible(false), AUTO_DISMISS_MS);
    return () => window.clearTimeout(timer);
  }, [visible]);

  return (
    <div className="flex w-full max-w-64 flex-col items-center gap-3">
      <button
        type="button"
        onClick={() => setVisible(true)}
        data-testid="mock-toast-trigger"
        className={cn(accentControl, 'h-9 px-4 text-sm')}
      >
        {crm.toast.trigger}
      </button>
      {/* The live region stays mounted so screen readers announce new content. */}
      <div role="status" className="w-full">
        {visible ? (
          <div
            data-testid="mock-toast-popup"
            className={cn(
              raised,
              'animate-toast-enter flex w-full items-start gap-2.5 p-3'
            )}
          >
            <CheckCircle2
              className="text-success mt-0.5 h-4 w-4 shrink-0"
              aria-hidden="true"
            />
            <div className="min-w-0 flex-1">
              <p className="text-foreground text-sm font-medium">
                {crm.toast.title}
              </p>
              <p className="text-muted text-xs">{crm.toast.body}</p>
            </div>
            <button
              type="button"
              onClick={() => setVisible(false)}
              aria-label={crm.toast.dismiss}
              className={cn(
                focusRing,
                'text-muted hover:text-foreground rounded-(--just-radius-sm) p-0.5'
              )}
            >
              <X className="h-3.5 w-3.5" aria-hidden="true" />
            </button>
          </div>
        ) : null}
      </div>
    </div>
  );
}
