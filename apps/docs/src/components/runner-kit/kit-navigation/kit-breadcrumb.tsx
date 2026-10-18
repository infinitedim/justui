import { Fragment } from 'react';
import { ChevronRight } from 'lucide-react';
import { cn } from '@/lib/cn';
import type { KitBreadcrumbProps } from './kit-navigation.types';

/** Path trail; the current item is weighted and marked `aria-current`. */
export function KitBreadcrumb({
  label,
  trail,
  current,
  className,
}: KitBreadcrumbProps) {
  return (
    <nav
      aria-label={label}
      className={cn('flex flex-wrap items-center gap-1.5', className)}
    >
      {trail.map((item) => (
        <Fragment key={item}>
          <span className="text-ip-text-secondary text-sm">{item}</span>
          <ChevronRight
            size={14}
            aria-hidden="true"
            className="text-ip-text-tertiary"
          />
        </Fragment>
      ))}
      <span
        aria-current="page"
        className="text-ip-text-primary text-sm [font-weight:var(--ip-strong-weight)]"
      >
        {current}
      </span>
    </nav>
  );
}
