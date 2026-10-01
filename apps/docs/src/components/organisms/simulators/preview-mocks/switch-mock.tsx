'use client';

import { useId, useState } from 'react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { focusRing } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

export interface SwitchMockProps {
  /** Called with the new value after each toggle (the stage forwards it to the bridge). */
  onToggle?: (checked: boolean) => void;
}

/**
 * Track and thumb follow the preset tokens. Borders paint inward, so the
 * thumb shrinks by twice the border width and never overlaps a 2.5px border
 * (AGENTS.md section 10). Pills stay round in every preset.
 */
export function SwitchMock({ onToggle }: SwitchMockProps) {
  const { crm } = useCatalogI18n();
  const [checked, setChecked] = useState(true);
  const labelId = useId();

  const toggle = () => {
    const next = !checked;
    setChecked(next);
    onToggle?.(next);
  };

  return (
    <div className="flex items-center gap-3">
      <button
        type="button"
        role="switch"
        aria-checked={checked}
        aria-labelledby={labelId}
        onClick={toggle}
        data-testid="mock-switch"
        className={cn(
          focusRing,
          'border-border relative h-7 w-12 shrink-0 rounded-full border-(length:--just-border-width) p-0.5',
          checked ? 'bg-accent' : 'bg-fill'
        )}
      >
        <span
          aria-hidden="true"
          className={cn(
            'border-border bg-card block size-[calc(24px_-_2*var(--just-border-width))] rounded-full border-(length:--just-border-width) transition-transform',
            checked ? 'translate-x-5' : 'translate-x-0'
          )}
        />
      </button>
      <div className="flex flex-col">
        <span id={labelId} className="text-foreground text-sm font-medium">
          {crm.switchMock.label}
        </span>
        <span className="text-muted text-xs">
          {checked ? crm.switchMock.on : crm.switchMock.off}
        </span>
      </div>
    </div>
  );
}
