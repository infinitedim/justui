'use client';

import { useState } from 'react';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { cn } from '@/lib/cn';
import { focusRing, raised } from './mock-styles';

const products = [
  { name: 'Ceramic mug', price: '$12.00' },
  { name: 'Pour-over kettle', price: '$14.00' },
  { name: 'Paper filters', price: '$6.00' },
];

export function CarouselMock() {
  const [index, setIndex] = useState(0);
  const product = products[index] ?? products[0];
  const step = (delta: number) =>
    setIndex((i) => (i + delta + products.length) % products.length);

  return (
    <div
      data-testid="mock-carousel"
      aria-roledescription="carousel"
      className={cn(raised, 'w-full max-w-56 p-3')}
    >
      <div className="flex items-center justify-between gap-2">
        <button
          type="button"
          onClick={() => step(-1)}
          aria-label="Previous product"
          className={cn('text-secondary hover:text-foreground p-1', focusRing)}
        >
          <ChevronLeft className="h-4 w-4" aria-hidden="true" />
        </button>
        <div className="text-center" aria-live="polite">
          <div className="text-sm font-medium">{product?.name}</div>
          <div className="text-secondary text-xs">{product?.price}</div>
        </div>
        <button
          type="button"
          onClick={() => step(1)}
          aria-label="Next product"
          className={cn('text-secondary hover:text-foreground p-1', focusRing)}
        >
          <ChevronRight className="h-4 w-4" aria-hidden="true" />
        </button>
      </div>
      <div className="mt-3 flex justify-center gap-1.5" aria-hidden="true">
        {products.map((p, i) => (
          <span
            key={p.name}
            className={cn(
              'h-1.5 rounded-full',
              i === index ? 'bg-foreground w-4' : 'bg-fill w-1.5'
            )}
          />
        ))}
      </div>
    </div>
  );
}
