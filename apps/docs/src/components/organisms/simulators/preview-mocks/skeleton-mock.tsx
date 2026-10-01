'use client';

import { useState } from 'react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { neutralControl } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

const CONTACTS = ['Rina Wulandari', 'Bagas Pratama', 'Dewi Lestari'] as const;

/**
 * The pulse runs twice and stops, so the preview never animates for more
 * than about four seconds (WCAG 2.2.2). The button flips `loading` the way
 * JustSkeleton's `loading` prop does.
 */
export function SkeletonMock() {
  const { crm } = useCatalogI18n();
  const [loading, setLoading] = useState(true);

  return (
    <div className="flex w-full max-w-60 flex-col gap-2.5">
      <ul
        aria-busy={loading}
        aria-label={crm.skeleton.label}
        data-testid="mock-skeleton"
        className="space-y-2"
      >
        {CONTACTS.map((name) => (
          <li key={name} className="flex items-center gap-2.5">
            {loading ? (
              <>
                <span className="bg-fill h-7 w-7 shrink-0 animate-pulse rounded-full [animation-iteration-count:2]" />
                <span className="bg-fill h-3 flex-1 animate-pulse rounded-(--just-radius-xs) [animation-iteration-count:2]" />
              </>
            ) : (
              <>
                <span className="bg-accent-muted text-foreground flex h-7 w-7 shrink-0 items-center justify-center rounded-full text-xs font-semibold">
                  {name
                    .split(' ')
                    .map((part) => part[0])
                    .join('')}
                </span>
                <span className="text-foreground text-sm">{name}</span>
              </>
            )}
          </li>
        ))}
      </ul>
      <button
        type="button"
        onClick={() => setLoading((l) => !l)}
        aria-pressed={loading}
        className={cn(neutralControl, 'h-8 self-start px-3 font-mono text-xs')}
      >
        loading: {String(loading)}
      </button>
    </div>
  );
}
