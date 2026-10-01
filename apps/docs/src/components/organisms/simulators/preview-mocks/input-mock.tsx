'use client';

import { useId, useState } from 'react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { focusRing, surface } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export function InputMock() {
  const { crm } = useCatalogI18n();
  const [value, setValue] = useState(crm.input.value);
  const inputId = useId();
  const errorId = useId();
  const invalid = value.length > 0 && !EMAIL_PATTERN.test(value);

  return (
    <div className="w-full max-w-60 space-y-1.5">
      <label
        htmlFor={inputId}
        className="text-foreground block text-xs font-medium"
      >
        {crm.input.label}
      </label>
      <input
        id={inputId}
        type="email"
        value={value}
        onChange={(e) => setValue(e.target.value)}
        aria-invalid={invalid}
        aria-describedby={invalid ? errorId : undefined}
        data-testid="mock-input"
        className={cn(
          surface,
          focusRing,
          'text-foreground h-9 w-full px-3 text-sm',
          invalid && 'border-error'
        )}
      />
      {invalid ? (
        <p id={errorId} className="text-error text-xs">
          {crm.input.invalid}
        </p>
      ) : null}
    </div>
  );
}
