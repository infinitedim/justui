'use client';

import { useState, useEffect } from 'react';
import { Layers, RotateCcw } from 'lucide-react';
import { cn } from '@/lib/cn';
import { ViewportSwitch } from '@/components/molecules/viewport-switch';
import type { Viewport } from '@/components/molecules/viewport-switch';
import { CodeBlockHeader } from '@/components/molecules/code-block-header';
import { CopyButton } from '@/components/molecules/copy-button';
import { Code } from '@/components/atoms/code';
import { getHomepageDictionary } from '@/lib/homepage-translations';
import { dispatchStageEvent } from '@/lib/stage-bridge';
import { getWidgetDef } from './stage-widget-registry';
import { CatalogI18nProvider } from '@/lib/catalog-i18n/context';
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
  onClear,
  onRunCommand,
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
    <CatalogI18nProvider lang={lang}>
      <div
        role="region"
        aria-label={t.stageRegionLabel}
        data-preset={preset}
        className={cn(
          'border-border bg-card shadow-solid flex min-h-[440px] flex-1 flex-col rounded-(--just-radius-lg) border-(length:--just-border-width) text-left',
          className
        )}
      >
        {/* Top Toolbar */}
        <div className="border-border flex min-h-12 flex-wrap items-center justify-between gap-3 border-(length:--just-border-width) border-b px-4 py-2">
          <div className="flex flex-wrap items-center gap-2.5">
            {widgets.length > 0 && onClear && (
              <button
                type="button"
                onClick={onClear}
                className="border-border hover:bg-accent hover:text-accent-foreground text-muted hover:shadow-solid focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-accent inline-flex cursor-pointer items-center gap-1.5 rounded-(--just-radius-md) border-(length:--just-border-width) px-2.5 py-1 text-xs transition-colors"
                aria-label={t.stageClear || 'Clear'}
              >
                <RotateCcw className="h-3 w-3" aria-hidden="true" />
                <span>{t.stageClear || 'Clear'}</span>
              </button>
            )}
          </div>

          <div className="flex items-center gap-2">
            <ViewportSwitch
              value={viewport}
              onChange={setViewport}
              labels={{
                group: t.viewportGroupLabel,
                mobile: t.viewportMobile,
                tablet: t.viewportTablet,
                desktop: t.viewportDesktop,
              }}
            />

            <div
              role="tablist"
              aria-label={t.stageViewModeLabel}
              className="border-border bg-card inline-flex items-center rounded-(--just-radius-md) border-(length:--just-border-width) p-0.5"
            >
              <button
                id="stage-tab-preview"
                type="button"
                role="tab"
                aria-selected={view === 'preview'}
                aria-controls="stage-panel-preview"
                onClick={() => setView('preview')}
                className={cn(
                  'rounded-(--just-radius-sm) px-3 py-1 text-xs transition-colors',
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
                  'rounded-(--just-radius-sm) px-3 py-1 text-xs transition-colors',
                  view === 'code'
                    ? 'bg-accent text-accent-foreground shadow-solid font-medium'
                    : 'text-muted hover:text-foreground'
                )}
              >
                {t.stageCodeTab || 'Flutter Code'}
              </button>
            </div>
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
              className="flex w-full flex-1 flex-col justify-center"
            >
              {widgets.length === 0 ? (
                <div className="border-border flex min-h-[280px] flex-1 flex-col items-center justify-center rounded-(--just-radius-md) border-(length:--just-border-width) border-dashed p-8 text-center">
                  <div className="border-border bg-accent/20 mb-3 flex h-10 w-10 items-center justify-center rounded-(--just-radius-md) border">
                    <Layers className="text-muted h-5 w-5" aria-hidden="true" />
                  </div>
                  <h3 className="text-foreground mb-1 text-sm font-semibold">
                    {t.stageEmptyTitle || 'Flutter Canvas Ready'}
                  </h3>
                  <p className="text-muted mb-4 max-w-sm text-sm leading-relaxed">
                    {t.stageEmptyDescription ||
                      'Run commands in the terminal to copy components into your project and preview them live here.'}
                  </p>
                  <button
                    type="button"
                    onClick={() => onRunCommand?.('justui add button')}
                    className="border-border bg-card hover:bg-accent hover:text-accent-foreground hover:shadow-solid focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-accent cursor-pointer rounded-(--just-radius-md) border-(length:--just-border-width) px-3 py-1.5 font-mono text-xs font-medium transition-colors"
                  >
                    [ {t.stageEmptyCta || 'Run: justui add button'} ]
                  </button>
                </div>
              ) : (
                <div className="flex w-full flex-1 flex-col justify-center gap-3">
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
    </CatalogI18nProvider>
  );
}
