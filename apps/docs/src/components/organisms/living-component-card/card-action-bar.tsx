'use client';

import React from 'react';
import Link from 'next/link';
import { cn } from '@/lib/cn';
import { CopyButton } from '@/components/molecules/copy-button';
import { Code, ExternalLink } from 'lucide-react';

export interface CardActionBarProps {
  slug: string;
  lang: string;
  onViewCode: () => void;
  preset?: 'default' | 'neobrutalism';
  copyCliLabel?: string;
  viewCodeLabel?: string;
  docsLabel?: string;
}

export function CardActionBar({
  slug,
  lang,
  onViewCode,
  preset = 'default',
  copyCliLabel = 'Copy CLI',
  viewCodeLabel = 'Code',
  docsLabel = 'Docs',
}: CardActionBarProps) {
  const isNeo = preset === 'neobrutalism';
  const cliCommand = `justui add ${slug}`;

  return (
    <div
      data-testid="card-action-bar"
      className={cn(
        'border-border/60 flex items-center justify-between border-t pt-3 font-mono text-xs'
      )}
    >
      <div className="flex items-center gap-1.5">
        <CopyButton text={cliCommand} label={copyCliLabel} />
        <span className="text-muted hidden text-[11px] sm:inline">
          {cliCommand}
        </span>
      </div>

      <div className="flex items-center gap-1.5">
        <button
          type="button"
          onClick={onViewCode}
          aria-label={viewCodeLabel}
          data-testid="view-code-button"
          className={cn(
            'inline-flex items-center gap-1 px-2 py-1 text-[11px] transition-all select-none',
            isNeo
              ? 'bg-surface hover:bg-accent rounded border border-black hover:text-black dark:border-white'
              : 'border-border bg-surface hover:border-accent text-muted hover:text-foreground rounded border'
          )}
        >
          <Code className="h-3 w-3" />
          <span>{viewCodeLabel}</span>
        </button>

        <Link
          href={`/${lang}/docs/components/${slug}`}
          aria-label={docsLabel}
          className={cn(
            'inline-flex items-center gap-1 px-2 py-1 text-[11px] transition-all select-none',
            isNeo
              ? 'bg-surface hover:bg-accent rounded border border-black hover:text-black dark:border-white'
              : 'border-border bg-surface hover:border-accent text-muted hover:text-foreground rounded border'
          )}
        >
          <span>{docsLabel}</span>
          <ExternalLink className="h-3 w-3" />
        </Link>
      </div>
    </div>
  );
}
