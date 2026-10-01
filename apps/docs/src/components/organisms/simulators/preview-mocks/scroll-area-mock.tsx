'use client';

import { cn } from '@/lib/cn';
import { surface } from './mock-styles';

const lines = [
  ['Ceramic mug', '2 x $12.00'],
  ['Pour-over kettle', '$14.00'],
  ['Paper filters (100)', '$6.00'],
  ['Coffee beans 250g', '$9.00'],
  ['Cleaning brush', '$3.00'],
  ['Gift wrap', '$2.00'],
];

export function ScrollAreaMock() {
  return (
    // A scrollable region must be focusable so keyboard users can scroll it
    // (axe: scrollable-region-focusable).
    <div
      data-testid="mock-scroll-area"
      role="region"
      // eslint-disable-next-line jsx-a11y/no-noninteractive-tabindex
      tabIndex={0}
      aria-label="Order items"
      className={cn(
        surface,
        'h-32 w-full max-w-56 overflow-y-auto p-1',
        'focus-visible:outline-accent focus-visible:outline-2 focus-visible:outline-offset-1'
      )}
    >
      {lines.map(([item, price]) => (
        <div
          key={item}
          className="flex justify-between gap-2 px-2.5 py-1.5 text-sm"
        >
          <span className="text-foreground">{item}</span>
          <span className="text-secondary shrink-0">{price}</span>
        </div>
      ))}
    </div>
  );
}
