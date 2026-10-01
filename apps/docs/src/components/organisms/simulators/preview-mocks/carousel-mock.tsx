'use client';

import { useState } from 'react';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { neutralControl, surface } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

const arrow = cn(
  neutralControl,
  'inline-flex h-8 w-8 shrink-0 items-center justify-center'
);

export function CarouselMock() {
  const { crm } = useCatalogI18n();
  const slides = crm.carousel.slides;
  const [index, setIndex] = useState(0);
  const slide = slides[index] ?? slides[0];

  const go = (delta: number) => {
    setIndex((i) => (i + delta + slides.length) % slides.length);
  };

  return (
    <section
      aria-roledescription="carousel"
      aria-label={crm.carousel.label}
      data-testid="mock-carousel"
      className="w-full max-w-64"
    >
      <div className="flex items-center gap-2">
        <button
          type="button"
          onClick={() => go(-1)}
          aria-label={crm.carousel.previous}
          className={arrow}
        >
          <ChevronLeft className="h-4 w-4" aria-hidden="true" />
        </button>
        <div
          aria-roledescription="slide"
          aria-label={crm.carousel.position(index + 1, slides.length)}
          aria-live="polite"
          className={cn(surface, 'min-w-0 flex-1 px-3 py-2.5 text-center')}
        >
          <p className="text-foreground truncate text-sm font-semibold">
            {slide?.company}
          </p>
          <p className="text-muted truncate text-xs">{slide?.detail}</p>
        </div>
        <button
          type="button"
          onClick={() => go(1)}
          aria-label={crm.carousel.next}
          className={arrow}
        >
          <ChevronRight className="h-4 w-4" aria-hidden="true" />
        </button>
      </div>
      {/* Line indicator (JustCarouselIndicator.line). */}
      <div className="mt-2.5 flex justify-center gap-1" aria-hidden="true">
        {slides.map((s, i) => (
          <span
            key={s.company}
            className={cn(
              'h-1 rounded-(--just-radius-xs) transition-all',
              i === index ? 'bg-foreground w-5' : 'bg-fill w-2.5'
            )}
          />
        ))}
      </div>
    </section>
  );
}
