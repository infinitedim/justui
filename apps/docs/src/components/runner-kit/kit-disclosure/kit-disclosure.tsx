'use client';

// Client leaf: the accordion and the carousel keep open/current state.
import { useId, useState } from 'react';
import { ChevronDown } from 'lucide-react';
import { cn } from '@/lib/cn';
import { formatMessage } from '@/lib/format-message';
import { kitSurface } from '@/lib/kit-classes';
import type {
  KitAccordionProps,
  KitCarouselProps,
} from './kit-disclosure.types';

const separator = 'border-(--ip-part-separator)';

/** One disclosure row; closed by default. */
export function KitAccordion({
  question,
  answer,
  className,
}: KitAccordionProps) {
  const id = useId();
  const [open, setOpen] = useState(false);
  return (
    <div className={cn('w-full max-w-60', className)}>
      <button
        type="button"
        aria-expanded={open}
        aria-controls={id}
        onClick={() => setOpen(!open)}
        className={cn(
          'text-ip-text-primary flex w-full cursor-pointer items-center justify-between gap-3 border-t-(length:--ip-separator-width) py-3 text-left text-sm font-semibold',
          !open && 'border-b-(length:--ip-separator-width)',
          separator
        )}
      >
        <span>{question}</span>
        <ChevronDown
          size={16}
          aria-hidden="true"
          className={cn(
            'transition-transform duration-200',
            open && 'rotate-180'
          )}
        />
      </button>
      <p
        id={id}
        hidden={!open}
        className={cn(
          'text-ip-text-secondary border-b-(length:--ip-separator-width) pb-3 text-[13px]/5',
          separator
        )}
      >
        {answer}
      </p>
    </div>
  );
}

/** One visible slide and a row of dots that pick the slide. */
export function KitCarousel({
  label,
  slideTemplate,
  dotTemplate,
  total = 3,
  className,
}: KitCarouselProps) {
  const [current, setCurrent] = useState(0);
  const dots = Array.from({ length: total }, (_, index) => index);
  return (
    <div className={cn('flex flex-col items-center gap-2.5', className)}>
      <div
        aria-live="polite"
        className={cn(
          kitSurface,
          'text-ip-text-primary flex h-[72px] w-[200px] items-center justify-center text-sm font-semibold shadow-(--ip-shadow-md)'
        )}
      >
        {formatMessage(slideTemplate, { index: current + 1, total })}
      </div>
      <div role="group" aria-label={label} className="flex gap-1.5">
        {dots.map((index) => (
          <button
            key={index}
            type="button"
            aria-label={formatMessage(dotTemplate, { index: index + 1 })}
            aria-current={index === current ? 'true' : undefined}
            onClick={() => setCurrent(index)}
            className={cn(
              'neo:rounded-none neo:border-2 neo:border-ip-text-primary size-2.5 cursor-pointer rounded-full',
              index === current
                ? 'bg-ip-inverse'
                : 'bg-ip-border-control neo:bg-ip-surface'
            )}
          />
        ))}
      </div>
    </div>
  );
}
