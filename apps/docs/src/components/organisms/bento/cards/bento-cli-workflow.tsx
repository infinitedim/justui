'use client';

import { useState } from 'react';
import { cn } from '@/lib/cn';
import { Badge } from '@/components/atoms/badge';
import { CopyButton } from '@/components/molecules/copy-button';

interface BentoCliWorkflowProps {
  title: string;
  description: string;
  className?: string;
}

const VERBOSE_CODE = `// Standard Verbose Flutter (314 characters)
Widget build(BuildContext context) {
  return Container(
    padding: .symmetric(horizontal: 16.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      border: Border.all(color: Theme.of(context).primaryColor),
    ),
  );
}`;

const JUSTUI_CODE = `// JustUI Dart Dot-Shorthand (176 characters -- 44% leaner)
Widget build(BuildContext context) {
  return Container(
    padding: .symmetric(horizontal: 16.0, vertical: 12.0),
    decoration: .all(
      borderRadius: .circular(8.0),
      border: .all(color: context.justColors.primary),
    ),
  );
}`;

export function BentoCliWorkflow({
  title,
  description,
  className,
}: BentoCliWorkflowProps) {
  const [tab, setTab] = useState<'justui' | 'verbose'>('justui');

  const isJustUI = tab === 'justui';

  return (
    <div
      className={cn(
        'group relative flex flex-col justify-between overflow-hidden rounded-(--just-radius-lg)',
        'border-border bg-card/80 p-6 backdrop-blur-xs transition-all duration-200',
        'hover:border-accent/40 border-(length:--just-border-width)',
        className
      )}
    >
      <div>
        <div className="flex items-center justify-between gap-4">
          <Badge variant="outline">DEVELOPER EXPERIENCE (DX)</Badge>
          <div className="flex items-center gap-2">
            <span className="text-muted font-mono text-xs">CLI Snippet:</span>
            <div className="border-border bg-background flex items-center gap-2 rounded-(--just-radius-sm) border px-2.5 py-1 font-mono text-xs">
              <span className="text-foreground font-semibold">
                justui add button
              </span>
              <CopyButton text="justui add button" />
            </div>
          </div>
        </div>

        <h3 className="text-foreground mt-4 font-mono text-lg font-bold">
          {title}
        </h3>
        <p className="text-muted mt-1 text-sm leading-relaxed">{description}</p>

        {/* Code comparison panel */}
        <div className="border-border bg-background mt-4 overflow-hidden rounded-(--just-radius-md) border font-mono">
          <div className="border-border bg-muted/20 flex items-center justify-between border-b px-3 py-1.5 text-xs">
            <div className="flex gap-2">
              <button
                type="button"
                onClick={() => setTab('justui')}
                className={cn(
                  'rounded px-2 py-0.5 transition-colors',
                  isJustUI
                    ? 'bg-accent/20 text-accent-deep dark:text-accent font-bold'
                    : 'text-muted hover:text-foreground'
                )}
              >
                JustUI Dot-Shorthand
              </button>
              <button
                type="button"
                onClick={() => setTab('verbose')}
                className={cn(
                  'rounded px-2 py-0.5 transition-colors',
                  !isJustUI
                    ? 'bg-muted/40 text-foreground font-bold'
                    : 'text-muted hover:text-foreground'
                )}
              >
                Standard Verbose
              </button>
            </div>
            <span className="text-muted text-[11px]">
              {isJustUI ? '176 chars (-44%)' : '314 chars (standard)'}
            </span>
          </div>

          <pre className="text-foreground overflow-x-auto p-4 text-xs leading-relaxed">
            <code>{isJustUI ? JUSTUI_CODE : VERBOSE_CODE}</code>
          </pre>
        </div>
      </div>

      <div className="border-border/60 mt-4 flex items-center justify-between border-t pt-3 font-mono text-xs">
        <span className="text-muted">Zero Syntax Overhead</span>
        <span className="text-accent font-bold">44% CODE REDUCTION</span>
      </div>
    </div>
  );
}
