'use client';

import { useId, useState } from 'react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { cn } from '@/lib/cn';
import { focusRing } from '@/lib/ui-classes';

export interface SliderMockProps {
  /** Called with each new value (the stage forwards it to the bridge). */
  onValueChange?: (value: number) => void;
}

export function SliderMock({ onValueChange }: SliderMockProps) {
  const { crm } = useCatalogI18n();
  const [value, setValue] = useState(60);
  const inputId = useId();

  return (
    <div className="w-full max-w-60 space-y-2">
      <div className="flex items-baseline justify-between">
        <label
          htmlFor={inputId}
          className="text-foreground text-xs font-medium"
        >
          {crm.slider.label}
        </label>
        <output
          htmlFor={inputId}
          className="text-foreground text-sm font-semibold tabular-nums"
        >
          {value}%
        </output>
      </div>
      <input
        id={inputId}
        type="range"
        min={0}
        max={100}
        step={5}
        value={value}
        onChange={(e) => {
          const next = Number(e.target.value);
          setValue(next);
          onValueChange?.(next);
        }}
        data-testid="mock-slider"
        className={cn(focusRing, 'accent-accent w-full cursor-pointer')}
      />
    </div>
  );
}
