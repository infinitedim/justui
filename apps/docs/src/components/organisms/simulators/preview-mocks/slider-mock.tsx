'use client';

import { useState } from 'react';
import { label } from './mock-styles';

export function SliderMock() {
  const [value, setValue] = useState(80);

  return (
    <div className="w-full max-w-56 space-y-2">
      <div className="flex items-center justify-between">
        <label htmlFor="mock-max-price" className={label}>
          Max price
        </label>
        <span className="text-foreground text-sm font-medium">${value}</span>
      </div>
      <input
        id="mock-max-price"
        type="range"
        min={0}
        max={200}
        step={5}
        value={value}
        onChange={(e) => setValue(Number(e.target.value))}
        data-testid="mock-slider"
        className="accent-accent w-full cursor-pointer"
      />
    </div>
  );
}
