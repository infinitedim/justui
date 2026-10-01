'use client';

import { useState } from 'react';
import { Mail, Phone, Star } from 'lucide-react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { neutralControl } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

const iconButton = cn(
  neutralControl,
  'inline-flex h-10 w-10 items-center justify-center'
);

export function IconButtonMock() {
  const { crm } = useCatalogI18n();
  const [starred, setStarred] = useState(false);

  return (
    <div className="flex flex-col items-center gap-2">
      <div className="flex items-center gap-2">
        <button
          type="button"
          aria-label={crm.iconButton.call}
          className={iconButton}
        >
          <Phone className="h-4 w-4" aria-hidden="true" />
        </button>
        <button
          type="button"
          aria-label={crm.iconButton.email}
          className={iconButton}
        >
          <Mail className="h-4 w-4" aria-hidden="true" />
        </button>
        <button
          type="button"
          aria-label={crm.iconButton.star}
          aria-pressed={starred}
          onClick={() => setStarred((s) => !s)}
          data-testid="mock-icon-button"
          className={cn(
            iconButton,
            starred && 'bg-accent text-accent-foreground'
          )}
        >
          <Star
            className={cn('h-4 w-4', starred && 'fill-current')}
            aria-hidden="true"
          />
        </button>
      </div>
      <p className="text-muted min-h-4 text-xs" aria-live="polite">
        {starred ? crm.iconButton.starred : null}
      </p>
    </div>
  );
}
