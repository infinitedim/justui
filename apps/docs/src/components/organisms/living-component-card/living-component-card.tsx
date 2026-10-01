'use client';

import { useState } from 'react';
import Link from 'next/link';
import type { Route } from 'next';
import { cn } from '@/lib/cn';
import type { ComponentMeta } from '@/lib/components-data';
import { CopyButton } from '@/components/molecules/copy-button';
import { MicroSimulator } from '@/components/organisms/simulators/micro-simulator';
import { DartCodeModal } from './dart-code-modal';

export interface LivingComponentCardProps {
  component: ComponentMeta;
  preset?: 'default' | 'neobrutalism';
  lang?: string;
  categoryLabel?: string;
  copyCliLabel?: string;
  copiedLabel?: string;
  viewCodeLabel?: string;
  docsLabel?: string;
  codeTitle?: string;
  closeLabel?: string;
  className?: string;
}

/**
 * Catalog card. The whole card links to the component's docs (a stretched
 * link on the title); the preview, the copy button and the Code link sit
 * above that link so they stay independently usable.
 */
export function LivingComponentCard({
  component,
  preset = 'default',
  lang = 'en',
  categoryLabel,
  copyCliLabel = 'Copy CLI command',
  copiedLabel = 'Copied',
  viewCodeLabel = 'Code',
  docsLabel = 'Docs',
  codeTitle = 'Example',
  closeLabel = 'Close',
  className,
}: LivingComponentCardProps) {
  const [isCodeModalOpen, setIsCodeModalOpen] = useState(false);
  const docsHref = `/${lang}/docs/components/${component.slug}` as Route;
  const cliCommand = `justui add ${component.slug}`;

  return (
    <article
      data-testid={`living-component-card-${component.slug}`}
      className={cn(
        'bg-card border-border relative flex flex-col overflow-hidden rounded-(--just-radius-lg) border-(length:--just-border-width) shadow-sm focus-within:z-30',
        'hover:border-foreground transition-colors',
        className
      )}
    >
      <div className="border-border relative z-10 border-b border-b-(length:--just-border-width)">
        <MicroSimulator slug={component.slug} preset={preset} />
      </div>

      <div className="flex flex-1 flex-col gap-1 px-4 pt-3.5 pb-4">
        <div className="flex items-baseline justify-between gap-3">
          <h3 className="text-foreground text-[15px] font-medium">
            <Link
              href={docsHref}
              className="focus-visible:after:outline-accent after:absolute after:inset-0 focus-visible:outline-none focus-visible:after:outline-2 focus-visible:after:outline-offset-2"
            >
              {component.name}
            </Link>
          </h3>
          {categoryLabel ? (
            <span className="text-muted shrink-0 text-xs">{categoryLabel}</span>
          ) : null}
        </div>

        <p className="text-secondary text-sm leading-relaxed">
          {component.description}
        </p>

        <div className="mt-auto flex items-center justify-between gap-3 pt-3">
          <div className="border-border bg-background relative z-10 flex min-w-0 items-center gap-2 rounded-(--just-radius-md) border-(length:--just-border-width) py-1 pr-1 pl-2.5">
            <code className="text-foreground truncate font-mono text-xs">
              {cliCommand}
            </code>
            <CopyButton
              text={cliCommand}
              label={copyCliLabel}
              copiedLabel={copiedLabel}
              className="shrink-0 border-transparent"
            />
          </div>
          <div className="flex shrink-0 items-center gap-3 text-sm">
            <button
              type="button"
              onClick={() => setIsCodeModalOpen(true)}
              data-testid="view-code-button"
              className="text-secondary hover:text-foreground focus-visible:outline-accent relative z-10 underline-offset-4 hover:underline focus-visible:outline-2 focus-visible:outline-offset-2"
            >
              {viewCodeLabel}
            </button>
            {/* Visual cue only: clicks fall through to the card's docs link. */}
            <span className="text-secondary" aria-hidden="true">
              {docsLabel} -&gt;
            </span>
          </div>
        </div>
      </div>

      <DartCodeModal
        name={component.name}
        code={component.dartSnippet}
        isOpen={isCodeModalOpen}
        onClose={() => setIsCodeModalOpen(false)}
        title={codeTitle}
        closeLabel={closeLabel}
      />
    </article>
  );
}
