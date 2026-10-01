'use client';

import { useState } from 'react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { accentControl } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

export interface ButtonMockProps {
  /** Called on each press (the stage forwards it to the bridge). */
  onPress?: () => void;
}

export function ButtonMock({ onPress }: ButtonMockProps) {
  const { crm } = useCatalogI18n();
  const [count, setCount] = useState(0);

  return (
    <div className="flex flex-col items-center gap-2">
      <button
        type="button"
        onClick={() => {
          setCount((c) => c + 1);
          onPress?.();
        }}
        data-testid="mock-button"
        className={cn(accentControl, 'h-9 px-4 text-sm')}
      >
        {crm.button.label}
      </button>
      <p className="text-muted min-h-4 text-xs" aria-live="polite">
        {count > 0 ? crm.button.logged(count) : null}
      </p>
    </div>
  );
}
