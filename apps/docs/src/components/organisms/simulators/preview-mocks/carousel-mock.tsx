'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';
import { ChevronLeft, ChevronRight } from 'lucide-react';

export function CarouselMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [index, setIndex] = useState(0);
  const isNeo = preset === 'neobrutalism';

  const slides = ['Slide A', 'Slide B', 'Slide C'];

  const prev = () => setIndex((i) => (i === 0 ? slides.length - 1 : i - 1));
  const next = () => setIndex((i) => (i === slides.length - 1 ? 0 : i + 1));

  return (
    <div
      data-testid="mock-carousel"
      className={cn(
        'w-full max-w-55 p-3 text-center font-mono text-xs transition-all select-none',
        isNeo
          ? 'bg-surface rounded-md border-2 border-black shadow-[3px_3px_0px_0px_#000] dark:border-white dark:shadow-[3px_3px_0px_0px_#fff]'
          : 'border-border bg-surface rounded-lg border shadow-sm'
      )}
    >
      <div className="flex items-center justify-between">
        <button
          type="button"
          onClick={prev}
          aria-label="Previous"
          className="hover:text-accent p-1"
        >
          <ChevronLeft className="h-4 w-4" />
        </button>
        <span className="text-foreground font-bold">{slides[index]}</span>
        <button
          type="button"
          onClick={next}
          aria-label="Next"
          className="hover:text-accent p-1"
        >
          <ChevronRight className="h-4 w-4" />
        </button>
      </div>
      <div className="mt-2.5 flex justify-center gap-1.5">
        {slides.map((s, idx) => (
          <div
            key={s}
            className={cn(
              'h-1.5 rounded-full transition-all',
              idx === index ? 'bg-accent w-4' : 'bg-border w-1.5'
            )}
          />
        ))}
      </div>
    </div>
  );
}
