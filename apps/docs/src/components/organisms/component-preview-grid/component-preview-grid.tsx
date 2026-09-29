import Link from 'next/link';
import type { Route } from 'next';
import type { ReactNode } from 'react';
import { Check } from 'lucide-react';
import { components } from '@/lib/components-data';

const box =
  'border-border border-(length:--just-border-width)';

/**
 * Miniature, static renderings of each component built only from --just-*
 * tokens, so every preview follows the active preset and theme.
 */
const PREVIEWS: Record<string, ReactNode> = {
  button: (
    <span
      className={`bg-accent text-accent-foreground ${box} inline-flex h-8 items-center rounded-(--just-radius-md) px-3.5 text-[13px] font-medium shadow-sm`}
    >
      Continue
    </span>
  ),
  input: (
    <span
      className={`bg-card text-muted ${box} inline-flex h-8 w-full items-center rounded-(--just-radius-md) px-2.5 font-mono text-xs`}
    >
      name@example.com
    </span>
  ),
  badge: (
    <span className="flex gap-2">
      <span
        className={`bg-accent-muted text-accent-text border-accent border-(length:--just-border-width) rounded-(--just-radius-md) px-2 py-0.5 font-mono text-xs font-medium`}
      >
        New
      </span>
      <span
        className={`bg-card text-secondary ${box} rounded-(--just-radius-md) px-2 py-0.5 font-mono text-xs font-medium`}
      >
        Draft
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
      <span className="text-[13px]">Accept terms</span>
    </span>
  ),
  progress: (
    <span
      className={`bg-card ${box} block h-2.5 w-full overflow-hidden rounded-full`}
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
        Code
      </span>
      <span className="text-muted px-3 py-1">Preview</span>
    </span>
  ),
  avatar: (
    <span
      className={`bg-accent-muted text-accent-text ${box} inline-flex h-11 w-11 items-center justify-center rounded-full font-mono text-sm font-medium`}
    >
      AR
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
    <span className="text-muted flex gap-2 font-mono text-xs">
      <span>Home</span>
      <span>/</span>
      <span>Docs</span>
      <span>/</span>
      <span className="text-foreground">Theming</span>
    </span>
  ),
  toast: (
    <span
      className={`bg-card ${box} block w-full rounded-(--just-radius-md) px-3 py-2.5 shadow-sm`}
    >
      <span className="block text-xs font-medium">Saved</span>
      <span className="text-muted mt-0.5 block text-xs">
        Changes synced just now
      </span>
    </span>
  ),
};

interface ComponentPreviewGridProps {
  lang: string;
}

export function ComponentPreviewGrid({ lang }: ComponentPreviewGridProps) {
  const items = components.filter((c) => PREVIEWS[c.slug]).slice(0, 12);

  return (
    <div className="grid grid-cols-[repeat(auto-fill,minmax(min(100%,240px),1fr))] gap-4">
      {items.map((component) => (
        <Link
          key={component.slug}
          href={`/${lang}/docs/components/${component.slug}` as Route}
          className="bg-card border-border hover:border-accent-dark flex flex-col overflow-hidden rounded-(--just-radius-lg) border-(length:--just-border-width) shadow-sm transition-colors"
        >
          <div className="bg-background border-border flex h-28 items-center justify-center border-b border-b-(length:--just-border-width) px-5">
            {PREVIEWS[component.slug]}
          </div>
          <div className="px-4 py-3.5">
            <h3 className="text-foreground text-sm font-medium">
              {component.name}
            </h3>
            <p className="text-muted mt-1 text-xs leading-5">
              {component.description}
            </p>
          </div>
        </Link>
      ))}
    </div>
  );
}
