import Link from 'next/link';
import type { Route } from 'next';
import type { ReactNode } from 'react';
import { Check } from 'lucide-react';
import { components } from '@/lib/components-data';
import { getCatalogDictionary, type CrmStrings } from '@/lib/catalog-i18n';

const box = 'border-border border-(length:--just-border-width)';

/**
 * Miniature, static renderings of each component built only from --just-*
 * tokens, so every preview follows the active preset and theme. Content
 * comes from the same CRM scenario as the catalog mocks.
 */
function buildPreviews(crm: CrmStrings): Record<string, ReactNode> {
  return {
    button: (
      <span
        className={`bg-accent text-accent-foreground ${box} inline-flex h-8 items-center rounded-(--just-radius-md) px-3.5 text-sm font-medium shadow-sm`}
      >
        {crm.button.label}
      </span>
    ),
    input: (
      <span
        className={`bg-card text-foreground ${box} inline-flex h-8 w-full items-center rounded-(--just-radius-md) px-2.5 text-sm`}
      >
        {crm.input.value}
      </span>
    ),
    badge: (
      <span className="flex gap-2">
        <span
          className={`bg-info/15 text-foreground border-info/40 border-(length:--just-border-width) rounded-(--just-radius-sm) px-2 py-0.5 text-xs font-medium`}
        >
          {crm.stages.lead}
        </span>
        <span
          className={`bg-success/15 text-foreground border-success/40 border-(length:--just-border-width) rounded-(--just-radius-sm) px-2 py-0.5 text-xs font-medium`}
        >
          {crm.stages.won}
        </span>
      </span>
    ),
    switch: (
      <span
        className={`bg-accent ${box} relative inline-block h-7 w-[52px] rounded-full`}
      >
        <span className="bg-foreground absolute top-1/2 right-[3px] h-[18px] w-[18px] -translate-y-1/2 rounded-full" />
      </span>
    ),
    checkbox: (
      <span className="flex items-center gap-2.5">
        <span
          className={`bg-accent text-accent-foreground ${box} inline-flex h-5 w-5 items-center justify-center rounded-(--just-radius-sm) text-xs font-semibold`}
        >
          <Check className="h-3.5 w-3.5 stroke-[3]" />
        </span>
        <span className="truncate text-sm">{crm.checkbox.label}</span>
      </span>
    ),
    progress: (
      <span
        className={`bg-card ${box} block h-2.5 w-full overflow-hidden rounded-(--just-radius-sm)`}
      >
        <span className="bg-accent block h-full w-[65%]" />
      </span>
    ),
    slider: (
      <span className="bg-fill relative block h-1 w-full rounded-full">
        <span className="bg-accent block h-full w-[60%] rounded-full" />
        <span
          className={`bg-card ${box} absolute top-1/2 left-[60%] h-[18px] w-[18px] -translate-x-1/2 -translate-y-1/2 rounded-full`}
        />
      </span>
    ),
    tabs: (
      <span
        className={`bg-card ${box} inline-flex gap-0.5 rounded-(--just-radius-md) p-[3px] text-xs`}
      >
        <span className="bg-accent text-accent-foreground rounded-(--just-radius-sm) px-3 py-1 font-medium">
          {crm.tabs.items[0]?.label}
        </span>
        <span className="text-muted px-3 py-1">{crm.tabs.items[1]?.label}</span>
      </span>
    ),
    avatar: (
      <span
        className={`bg-accent-muted text-foreground ${box} inline-flex h-11 w-11 items-center justify-center rounded-full text-sm font-semibold`}
      >
        RW
      </span>
    ),
    skeleton: (
      <span className="flex w-full flex-col gap-2">
        <span className="bg-fill h-2.5 w-full rounded-(--just-radius-sm)" />
        <span className="bg-fill h-2.5 w-[70%] rounded-(--just-radius-sm)" />
        <span className="bg-fill h-2.5 w-[45%] rounded-(--just-radius-sm)" />
      </span>
    ),
    breadcrumb: (
      <span className="text-muted flex gap-2 text-sm">
        <span>{crm.breadcrumb.items[0]}</span>
        <span aria-hidden="true">/</span>
        <span>{crm.breadcrumb.items[1]}</span>
        <span aria-hidden="true">/</span>
        <span className="text-foreground">{crm.breadcrumb.items[2]}</span>
      </span>
    ),
    toast: (
      <span
        className={`bg-card ${box} block w-full rounded-(--just-radius-md) px-3 py-2.5 shadow-sm`}
      >
        <span className="block text-sm font-medium">{crm.toast.title}</span>
        <span className="text-muted mt-0.5 block text-xs">
          {crm.toast.body}
        </span>
      </span>
    ),
  };
}

interface ComponentPreviewGridProps {
  lang: string;
}

export function ComponentPreviewGrid({ lang }: ComponentPreviewGridProps) {
  const { crm, descriptions } = getCatalogDictionary(lang);
  const previews = buildPreviews(crm);
  const items = components.filter((c) => previews[c.slug]).slice(0, 12);

  return (
    <div className="grid grid-cols-[repeat(auto-fill,minmax(min(100%,240px),1fr))] gap-4">
      {items.map((component) => (
        <Link
          key={component.slug}
          href={`/${lang}/docs/components/${component.slug}` as Route}
          className="bg-card border-border hover:border-accent-dark flex flex-col overflow-hidden rounded-(--just-radius-lg) border-(length:--just-border-width) shadow-sm transition-colors"
        >
          <div className="bg-background border-border flex h-28 items-center justify-center border-b border-b-(length:--just-border-width) px-5">
            {previews[component.slug]}
          </div>
          <div className="px-4 py-3.5">
            <h3 className="text-foreground text-sm font-medium">
              {component.name}
            </h3>
            <p className="text-muted mt-1 text-sm leading-5">
              {descriptions[component.slug]}
            </p>
          </div>
        </Link>
      ))}
    </div>
  );
}
