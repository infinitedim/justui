'use client';

import { useCallback, useId, useMemo, useState } from 'react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { useRovingTabs } from '@/lib/use-roving-tabs';
import { focusRing } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

export function TabsMock() {
  const { crm } = useCatalogI18n();
  const tabs = crm.tabs.items;
  const ids = useMemo(() => tabs.map((tab) => tab.id), [tabs]);
  const [active, setActive] = useState<string>(ids[0] ?? 'overview');
  const select = useCallback((id: string) => setActive(id), []);
  const { registerTab, onKeyDown } = useRovingTabs(ids, active, select);
  const baseId = useId();
  const activeTab = tabs.find((tab) => tab.id === active) ?? tabs[0];

  return (
    <div data-testid="mock-tabs" className="w-full max-w-64">
      <div
        role="tablist"
        aria-label={crm.tabs.label}
        onKeyDown={onKeyDown}
        className="border-border flex gap-3 border-b border-b-(length:--just-border-width)"
      >
        {tabs.map((tab) => {
          const selected = tab.id === active;
          return (
            <button
              key={tab.id}
              ref={registerTab(tab.id)}
              id={`${baseId}-tab-${tab.id}`}
              type="button"
              role="tab"
              aria-selected={selected}
              aria-controls={`${baseId}-panel`}
              tabIndex={selected ? 0 : -1}
              onClick={() => setActive(tab.id)}
              data-testid={`mock-tab-${tab.id}`}
              className={cn(
                focusRing,
                '-mb-[var(--just-border-width)] border-b-2 pb-1.5 text-sm',
                selected
                  ? 'text-foreground border-accent font-medium'
                  : 'text-muted hover:text-foreground border-transparent'
              )}
            >
              {tab.label}
            </button>
          );
        })}
      </div>
      <p
        id={`${baseId}-panel`}
        role="tabpanel"
        aria-labelledby={`${baseId}-tab-${active}`}
        className="text-secondary pt-2.5 text-sm"
      >
        {activeTab?.body}
      </p>
    </div>
  );
}
