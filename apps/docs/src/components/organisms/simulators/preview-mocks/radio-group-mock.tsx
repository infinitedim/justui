'use client';

import { useId, useState } from 'react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { RadioOption } from './radio-mock';

const PRIORITIES = ['low', 'medium', 'high'] as const;
type Priority = (typeof PRIORITIES)[number];

export function RadioGroupMock() {
  const { crm } = useCatalogI18n();
  const [selected, setSelected] = useState<Priority>('medium');
  const name = useId();

  return (
    <fieldset data-testid="mock-radio-group">
      <legend className="text-foreground mb-2 text-xs font-medium">
        {crm.radioGroup.label}
      </legend>
      <div className="flex gap-4">
        {PRIORITIES.map((id) => (
          <RadioOption
            key={id}
            name={name}
            checked={selected === id}
            onSelect={() => setSelected(id)}
            label={crm.radioGroup[id]}
            testId={`mock-radio-group-${id}`}
          />
        ))}
      </div>
    </fieldset>
  );
}
