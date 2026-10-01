'use client';

import { useCallback, useRef, useState } from 'react';
import Link from 'next/link';
import type { Route } from 'next';
import type { ComponentMeta } from '@/lib/components-data';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { MicroSimulator } from '@/components/organisms/simulators/micro-simulator';
import { CopyButton } from '@/components/molecules/copy-button';
import { accentLink, focusRing, tokenBorder } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';
import { DartCodeModal } from './dart-code-modal';

export interface LivingComponentCardProps {
  component: ComponentMeta;
  lang?: string;
  className?: string;
}

/**
 * Catalog card: live preview, name, one-line description and the install
 * command. The name link is stretched over the card (after:inset-0) so the
 * whole card opens the docs; the preview and the action row sit above it
 * (relative z-10) and stay independently clickable. No nested interactive
 * elements, so the markup stays valid.
 */
export function LivingComponentCard({
  component,
  lang = 'en',
  className,
}: LivingComponentCardProps) {
  const { ui, descriptions } = useCatalogI18n();
  const [isCodeOpen, setIsCodeOpen] = useState(false);
  const codeTriggerRef = useRef<HTMLButtonElement>(null);
  const docsHref = `/${lang}/docs/components/${component.slug}` as Route;
  const command = `justui add ${component.slug}`;

  // Stable, so the modal's open effect (focus + listeners) runs once per open.
  const closeCode = useCallback(() => {
    setIsCodeOpen(false);
    codeTriggerRef.current?.focus();
  }, []);

  return (
    <article
      data-testid={`living-component-card-${component.slug}`}
      className={cn(
        'bg-card relative flex flex-col overflow-hidden rounded-(--just-radius-lg) shadow-sm transition-shadow hover:shadow-md',
        tokenBorder,
        className
      )}
    >
      <div className="border-border relative z-10 border-b-(length:--just-border-width)">
        <MicroSimulator slug={component.slug} />
      </div>

      <div className="flex flex-1 flex-col gap-1 px-4 pt-3.5 pb-3">
        <div className="flex items-baseline justify-between gap-3">
          <h3 className="text-foreground text-[15px] font-medium">
            <Link
              href={docsHref}
              className={cn(
                focusRing,
                'rounded-(--just-radius-xs) after:absolute after:inset-0'
              )}
            >
              {component.name}
            </Link>
          </h3>
          <span className="text-muted shrink-0 text-xs">
            {ui.categories[component.category]}
          </span>
        </div>
        <p className="text-secondary text-sm leading-relaxed">
          {descriptions[component.slug]}
        </p>
      </div>

      <div className="border-border relative z-10 flex items-center justify-between gap-3 border-t px-4 py-2.5">
        <div className="flex min-w-0 items-center gap-2">
          <code className="text-foreground truncate font-mono text-xs">
            {command}
          </code>
          <CopyButton
            text={command}
            label={ui.copyCommand(component.slug)}
            copiedLabel={ui.copied}
            className="shrink-0"
          />
        </div>
        <div className="flex shrink-0 items-center gap-3 text-xs">
          <button
            ref={codeTriggerRef}
            type="button"
            onClick={() => setIsCodeOpen(true)}
            aria-haspopup="dialog"
            data-testid="view-code-button"
            className={accentLink}
          >
            {ui.viewCode}
          </button>
          <Link href={docsHref} className={accentLink}>
            {ui.docs}
          </Link>
        </div>
      </div>

      <DartCodeModal
        slug={component.slug}
        code={component.dartSnippet}
        isOpen={isCodeOpen}
        onClose={closeCode}
      />
    </article>
  );
}
