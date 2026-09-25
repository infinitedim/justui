'use client';

import { useState, useEffect } from 'react';
import { cn } from '@/lib/cn';
import { ViewportSwitch } from '@/components/molecules/viewport-switch';
import type { Viewport } from '@/components/molecules/viewport-switch';
import { CodeBlockHeader } from '@/components/molecules/code-block-header';
import { CopyButton } from '@/components/molecules/copy-button';
import { Code } from '@/components/atoms/code';
import { getHomepageDictionary } from '@/lib/homepage-translations';
import { dispatchStageEvent } from '@/lib/stage-bridge';
import { getWidgetDef } from './stage-widget-registry';
import type { LivingStageProps, StageView } from './living-stage.types';

const viewportWidthClass: Record<Viewport, string> = {
  mobile: 'max-w-[375px]',
  tablet: 'max-w-[768px]',
  desktop: 'max-w-full',
};

function getComponentDartCode(component: string): string {
  const def = getWidgetDef(component);
  if (def) return def.dartCode;
  const pascal = component
    .split('-')
    .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
    .join('');
  return `Just${pascal}()`;
}

export function LivingStage({
  widgets,
  preset = 'default',
  lang = 'en',
  className,
}: LivingStageProps) {
  const [viewport, setViewport] = useState<Viewport>('desktop');
  const [view, setView] = useState<StageView>('preview');
  const t = getHomepageDictionary(lang);

  useEffect(() => {
    for (const widget of widgets) {
      dispatchStageEvent({
        type: 'justui-mounted',
        component: widget.component,
        success: true,
      });
    }
  }, [widgets]);

  const combinedDart =
    widgets.length === 0
      ? '// Run a command in the terminal to see components appear here.'
      : widgets.map((w) => getComponentDartCode(w.component)).join('\n\n');

  return (
    <div
      role="region"
      aria-label="Living Widget Stage"
      data-preset={preset}
      className={cn(
        'border-border bg-card shadow-solid flex min-h-[440px] flex-1 flex-col rounded-(--just-radius-lg) border-(length:--just-border-width) text-left',
        className
      )}
    >
      {/* Top Toolbar */}
      <div className="border-border flex h-12 flex-wrap items-center justify-between gap-3 border-(length:--just-border-width) border-b px-4">
        <ViewportSwitch value={viewport} onChange={setViewport} />

        <div
          role="tablist"
          aria-label="Stage view mode"
          className="border-border bg-card inline-flex items-center rounded-full border-(length:--just-border-width) p-0.5"
        >
          <button
            id="stage-tab-preview"
            type="button"
            role="tab"
            aria-selected={view === 'preview'}
            aria-controls="stage-panel-preview"
            onClick={() => setView('preview')}
            className={cn(
              'rounded-full px-3 py-1 font-mono text-xs transition-colors',
              view === 'preview'
                ? 'bg-accent text-accent-foreground shadow-solid font-medium'
                : 'text-muted hover:text-foreground'
            )}
          >
            {t.stagePreviewTab || 'Preview'}
          </button>
          <button
            id="stage-tab-code"
            type="button"
            role="tab"
            aria-selected={view === 'code'}
            aria-controls="stage-panel-code"
            onClick={() => setView('code')}
            className={cn(
              'rounded-full px-3 py-1 font-mono text-xs transition-colors',
              view === 'code'
                ? 'bg-accent text-accent-foreground shadow-solid font-medium'
                : 'text-muted hover:text-foreground'
            )}
          >
            {t.stageCodeTab || 'Flutter Code'}
          </button>
        </div>
      </div>

      {/* Main viewport-constrained content container */}
      <div
        className={cn(
          'mx-auto flex w-full flex-1 flex-col p-4 transition-all duration-300',
          viewportWidthClass[viewport]
        )}
      >
        {view === 'preview' ? (
          <div
            id="stage-panel-preview"
            role="tabpanel"
            aria-labelledby="stage-tab-preview"
            className="flex flex-1 flex-col justify-center w-full"
          >
            {widgets.length === 0 ? (
              <div className="border-border flex min-h-[280px] flex-1 flex-col items-center justify-center rounded-(--just-radius-md) border-dashed border-(length:--just-border-width) p-8 text-center">
                <p className="text-muted font-mono text-xs">
                  {t.stageEmptyState ||
                    'Run a command in the terminal to see components appear here.'}
                </p>
              </div>
            ) : (
              <div className="border-border bg-background/50 flex min-h-[280px] flex-1 flex-wrap items-center justify-center gap-4 rounded-(--just-radius-md) border-(length:--just-border-width) p-6">
                {widgets.map((widget, index) => {
                  const def = getWidgetDef(widget.component);
                  if (!def) {
                    return (
                      <div
                        key={widget.id}
                        className="animate-stage-enter border-border bg-card rounded-(--just-radius-md) border p-3 font-mono text-xs"
                        style={{ animationDelay: `${index * 80}ms` }}
                      >
                        {widget.component}
                      </div>
                    );
                  }
                  return (
                    <div
                      key={widget.id}
                      className="animate-stage-enter"
                      style={{ animationDelay: `${index * 80}ms` }}
                    >
                      {def.render()}
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        ) : (
          <div
            id="stage-panel-code"
            role="tabpanel"
            aria-labelledby="stage-tab-code"
            className="flex flex-1 flex-col"
          >
            <CodeBlockHeader
              title="widget.dart"
              actions={
                <CopyButton text={combinedDart} label="Copy Flutter code" />
              }
            />
            <Code block className="min-h-[260px] flex-1 text-xs">
              {combinedDart}
            </Code>
          </div>
        )}
      </div>
    </div>
  );
}
