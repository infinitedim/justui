'use client';

import { useState, useEffect } from 'react';
import { cn } from '@/lib/cn';
import { ViewportSwitch } from '@/components/molecules/viewport-switch';
import type { Viewport } from '@/components/molecules/viewport-switch';
import { CopyButton } from '@/components/molecules/copy-button';
import { Code } from '@/components/atoms/code';
import { getHomepageDictionary } from '@/lib/homepage-translations';
import { dispatchStageEvent } from '@/lib/stage-bridge';
import { useRovingTabs } from '@/lib/use-roving-tabs';
import { getWidgetDef } from './stage-widget-registry';
import type { LivingStageProps, StageView } from './living-stage.types';

const viewportWidthClass: Record<Viewport, string> = {
  mobile: 'max-w-[375px]',
  tablet: 'max-w-[768px]',
  desktop: 'max-w-full',
};

const VIEWS: readonly StageView[] = ['preview', 'code'];

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
  const { registerTab, onKeyDown } = useRovingTabs(VIEWS, view, setView);

  useEffect(() => {
    for (const widget of widgets) {
      dispatchStageEvent({
        type: 'justui-mounted',
        component: widget.component,
        success: true,
      });
    }
  }, [widgets]);

  const combinedDart = widgets
    .map((w) => getComponentDartCode(w.component))
    .join('\n\n');

  const tabClass = (active: boolean) =>
    cn(
      'px-3 py-1 text-xs transition-colors',
      'rounded-(--just-radius-sm)',
      active
        ? 'bg-accent text-accent-foreground font-medium'
        : 'text-secondary hover:text-foreground'
    );

  return (
    <div
      role="region"
      aria-label={t.stageRegionLabel}
      data-preset={preset}
      className={cn(
        'border-border bg-card shadow-solid flex min-h-110 flex-1 flex-col rounded-(--just-radius-lg) border-(length:--just-border-width) text-left',
        className
      )}
    >
      <div className="border-border flex min-h-11 flex-wrap items-center justify-between gap-3 border-b border-b-(length:--just-border-width) px-4 py-2">
        <div
          role="tablist"
          aria-label={t.stageViewLabel}
          className="flex items-center gap-1"
        >
          <button
            ref={registerTab('preview')}
            id="stage-tab-preview"
            type="button"
            role="tab"
            aria-selected={view === 'preview'}
            tabIndex={view === 'preview' ? 0 : -1}
            onClick={() => setView('preview')}
            onKeyDown={onKeyDown}
            aria-controls="stage-panel-preview"
            className={tabClass(view === 'preview')}
          >
            {t.stagePreviewTab}
          </button>
          <button
            ref={registerTab('code')}
            id="stage-tab-code"
            type="button"
            role="tab"
            aria-selected={view === 'code'}
            tabIndex={view === 'code' ? 0 : -1}
            onClick={() => setView('code')}
            onKeyDown={onKeyDown}
            aria-controls="stage-panel-code"
            className={cn(tabClass(view === 'code'), 'font-mono')}
          >
            widget.dart
          </button>
        </div>

        {view === 'preview' ? (
          <ViewportSwitch value={viewport} onChange={setViewport} />
        ) : (
          <CopyButton text={combinedDart} label={t.stageCopyCode} />
        )}
      </div>

      {view === 'preview' ? (
        <div
          id="stage-panel-preview"
          role="tabpanel"
          aria-labelledby="stage-tab-preview"
          className={cn(
            'mx-auto flex w-full flex-1 flex-col p-4',
            viewportWidthClass[viewport]
          )}
        >
          <div className="border-border bg-background flex min-h-70 flex-1 flex-wrap items-center justify-center gap-6 rounded-(--just-radius-md) border-(length:--just-border-width) p-6">
            {widgets.length === 0 ? (
              <p className="text-muted text-sm">{t.stageEmpty}</p>
            ) : (
              widgets.map((widget) => {
                const def = getWidgetDef(widget.component);
                return (
                  <div
                    key={widget.id}
                    data-testid={`stage-widget-${widget.component}`}
                    className="animate-stage-enter"
                  >
                    {def ? (
                      def.render()
                    ) : (
                      <span className="font-mono text-xs">
                        {widget.component}
                      </span>
                    )}
                  </div>
                );
              })
            )}
          </div>
        </div>
      ) : (
        <div
          id="stage-panel-code"
          role="tabpanel"
          aria-labelledby="stage-tab-code"
          className="flex flex-1 flex-col p-4"
        >
          <Code block className="min-h-70 flex-1 text-xs shadow-none">
            {combinedDart || `// ${t.stageEmpty}`}
          </Code>
        </div>
      )}
    </div>
  );
}
