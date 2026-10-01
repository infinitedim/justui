'use client';

import { useId, useState } from 'react';
import { Check } from 'lucide-react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { focusRing } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

export function CheckboxMock() {
  const { crm } = useCatalogI18n();
  const [checked, setChecked] = useState(true);
  const labelId = useId();

  return (
    <div className="flex items-center gap-2.5">
      <button
        type="button"
        role="checkbox"
        aria-checked={checked}
        aria-labelledby={labelId}
        onClick={() => setChecked((c) => !c)}
        data-testid="mock-checkbox"
        className={cn(
          focusRing,
          'border-border flex h-5 w-5 shrink-0 items-center justify-center rounded-(--just-radius-sm) border-(length:--just-border-width)',
          checked ? 'bg-accent text-accent-foreground' : 'bg-card'
        )}
      >
        {checked ? (
          <Check className="h-3.5 w-3.5 stroke-[3]" aria-hidden="true" />
        ) : null}
      </button>
      <span
        id={labelId}
        className={cn(
          'text-sm',
          checked ? 'text-muted line-through' : 'text-foreground'
        )}
      >
        {crm.checkbox.label}
      </span>
    </div>
  );
}
