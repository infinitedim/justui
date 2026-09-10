import Link from 'next/link';
import type { Route } from 'next';
import { cn } from '@/lib/cn';
import type { BreadcrumbTrailProps } from './breadcrumb-trail.types';

/**
 * Breadcrumb navigation trail molecule. Server Component.
 * Uses semantic <nav> with aria-label and <ol> for proper a11y.
 */
export function BreadcrumbTrail({ segments, className }: BreadcrumbTrailProps) {
  return (
    <nav aria-label="Breadcrumb" className={className}>
      <ol className="flex items-center gap-1.5 font-mono text-xs">
        {segments.map((segment, i) => {
          const isLast = i === segments.length - 1;

          return (
            <li
              key={`${segment.label}-${i}`}
              className="flex items-center gap-1.5"
            >
              {i > 0 ? (
                <span className="text-muted select-none" aria-hidden="true">
                  /
                </span>
              ) : null}
              {segment.href && !isLast ? (
                <Link
                  href={segment.href as Route}
                  className="text-muted hover:text-foreground transition-colors"
                >
                  {segment.label}
                </Link>
              ) : (
                <span
                  className={cn(isLast ? 'text-foreground' : 'text-muted')}
                  aria-current={isLast ? 'page' : undefined}
                >
                  {segment.label}
                </span>
              )}
            </li>
          );
        })}
      </ol>
    </nav>
  );
}
