'use client';

import { useId } from 'react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';

/** Rp 412 jt of Rp 600 jt. */
const PERCENT = Math.round((412 / 600) * 1000) / 10;

export function ProgressMock() {
  const { crm } = useCatalogI18n();
  const labelId = useId();

  return (
    <div className="w-full max-w-60 space-y-2">
      <div className="flex items-baseline justify-between gap-2">
        <span id={labelId} className="text-foreground text-xs font-medium">
          {crm.progress.label}
        </span>
        <span className="text-muted text-xs tabular-nums">{PERCENT}%</span>
      </div>
      <div
        role="progressbar"
        aria-labelledby={labelId}
        aria-valuemin={0}
        aria-valuemax={100}
        aria-valuenow={PERCENT}
        aria-valuetext={crm.progress.detail}
        data-testid="mock-progress"
        className="bg-fill border-border h-2.5 w-full overflow-hidden rounded-(--just-radius-sm) border-(length:--just-border-width)"
      >
        <div className="bg-accent h-full" style={{ width: `${PERCENT}%` }} />
      </div>
      <p className="text-muted text-xs">{crm.progress.detail}</p>
    </div>
  );
}
