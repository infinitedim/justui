'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';
import type { ComponentMeta } from '@/lib/components-data';
import { MicroSimulator } from '@/components/organisms/simulators/micro-simulator';
import { CardActionBar } from './card-action-bar';
import { DartCodeModal } from './dart-code-modal';

export interface LivingComponentCardProps {
  component: ComponentMeta;
  preset?: 'default' | 'neobrutalism';
  lang?: string;
  copyCliLabel?: string;
  viewCodeLabel?: string;
  docsLabel?: string;
  className?: string;
}

export function LivingComponentCard({
  component,
  preset = 'default',
  lang = 'en',
  copyCliLabel,
  viewCodeLabel,
  docsLabel,
  className,
}: LivingComponentCardProps) {
  const [isCodeModalOpen, setIsCodeModalOpen] = useState(false);
  const isNeo = preset === 'neobrutalism';

  return (
    <article
      data-testid={`living-component-card-${component.slug}`}
      className={cn(
        'bg-surface relative flex flex-col justify-between p-4 transition-all select-none focus-within:z-30',
        isNeo
          ? 'rounded-md border-2 border-black shadow-[4px_4px_0px_0px_#000] dark:border-white dark:shadow-[4px_4px_0px_0px_#fff]'
          : 'border-border/80 hover:border-accent rounded-xl border shadow-xs hover:shadow-md',
        className
      )}
    >
      <div>
        {/* Header */}
        <div className="mb-3 flex items-center justify-between gap-2">
          <h3 className="text-foreground truncate font-mono text-sm font-bold">
            {component.name}
          </h3>
          <span
            className={cn(
              'px-2 py-0.5 font-mono text-[10px] tracking-wider uppercase',
              isNeo
                ? 'bg-surface-muted text-foreground rounded border border-black font-bold dark:border-white'
                : 'border-border bg-surface-muted text-muted rounded-full border'
            )}
          >
            {component.category}
          </span>
        </div>

        {/* Micro-Simulator Canvas */}
        <div className="mb-3">
          <MicroSimulator slug={component.slug} preset={preset} />
        </div>

        {/* Description */}
        <p className="text-muted mb-4 line-clamp-2 font-mono text-xs leading-relaxed">
          {component.description}
        </p>
      </div>

      {/* Action Bar */}
      <CardActionBar
        slug={component.slug}
        lang={lang}
        onViewCode={() => setIsCodeModalOpen(true)}
        preset={preset}
        copyCliLabel={copyCliLabel}
        viewCodeLabel={viewCodeLabel}
        docsLabel={docsLabel}
      />

      {/* Dart Code Snippet Modal */}
      <DartCodeModal
        name={component.name}
        code={component.dartSnippet}
        isOpen={isCodeModalOpen}
        onClose={() => setIsCodeModalOpen(false)}
        preset={preset}
      />
    </article>
  );
}
