'use client';

import { useId, useState } from 'react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { cn } from '@/lib/cn';

const CHANNELS = ['phone', 'email'] as const;
type Channel = (typeof CHANNELS)[number];

/** Native radio inputs keep arrow-key navigation and form semantics. */
export function RadioMock() {
  const { crm } = useCatalogI18n();
  const [selected, setSelected] = useState<Channel>('phone');
  const name = useId();

  return (
    <fieldset data-testid="mock-radio" className="space-y-2">
      <legend className="text-foreground mb-1 text-xs font-medium">
        {crm.radio.label}
      </legend>
      {CHANNELS.map((id) => (
        <RadioOption
          key={id}
          name={name}
          checked={selected === id}
          onSelect={() => setSelected(id)}
          label={crm.radio[id]}
          testId={`mock-radio-${id}`}
        />
      ))}
    </fieldset>
  );
}

export function RadioOption({
  name,
  checked,
  onSelect,
  label,
  testId,
}: {
  name: string;
  checked: boolean;
  onSelect: () => void;
  label: string;
  testId: string;
}) {
  return (
    <label
      data-testid={testId}
      className="flex cursor-pointer items-center gap-2.5"
    >
      <input
        type="radio"
        name={name}
        checked={checked}
        onChange={onSelect}
        className="peer sr-only"
      />
      <span
        aria-hidden="true"
        className={cn(
          'border-border bg-card flex h-4.5 w-4.5 shrink-0 items-center justify-center rounded-full border-(length:--just-border-width)',
          'peer-focus-visible:outline-accent peer-focus-visible:outline-2 peer-focus-visible:outline-offset-2'
        )}
      >
        {checked ? (
          <span className="bg-foreground h-2 w-2 rounded-full" />
        ) : null}
      </span>
      <span className="text-foreground text-sm">{label}</span>
    </label>
  );
}
