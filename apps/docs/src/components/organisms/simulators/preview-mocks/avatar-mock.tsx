'use client';

import { useState } from 'react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { focusRing } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

export function AvatarMock() {
  const { crm } = useCatalogI18n();
  const [online, setOnline] = useState(true);

  return (
    <div className="flex flex-col items-center gap-2">
      <button
        type="button"
        onClick={() => setOnline((o) => !o)}
        aria-label={crm.avatar.toggle}
        aria-pressed={online}
        data-testid="mock-avatar"
        className={cn('relative rounded-full', focusRing)}
      >
        <span className="bg-accent-muted text-foreground border-border flex h-12 w-12 items-center justify-center rounded-full border-(length:--just-border-width) text-sm font-semibold">
          RW
        </span>
        <span
          aria-hidden="true"
          className={cn(
            'border-card absolute -right-0.5 -bottom-0.5 h-3.5 w-3.5 rounded-full border-2',
            online ? 'bg-success' : 'bg-fill'
          )}
        />
      </button>
      <p className="text-muted text-xs" aria-live="polite">
        {online ? crm.avatar.online : crm.avatar.offline}
      </p>
    </div>
  );
}
