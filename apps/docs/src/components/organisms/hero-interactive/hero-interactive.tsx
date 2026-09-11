'use client';

import { useState, useCallback, useEffect } from 'react';
import { useTheme } from 'next-themes';
import { cn } from '@/lib/cn';
import { usePreset } from '@/lib/preset-context';
import { InteractiveTerminal } from '@/components/organisms/interactive-terminal';
import { LivingStage } from '@/components/organisms/living-stage';
import type { MountedWidget } from '@/components/organisms/living-stage';
import { dispatchStageEvent } from '@/lib/stage-bridge';
import { getHomepageDictionary } from '@/lib/homepage-translations';
import type { HeroInteractiveProps } from './hero-interactive.types';

export function HeroInteractive({
  lang = 'en',
  className,
}: HeroInteractiveProps) {
  const [widgets, setWidgets] = useState<MountedWidget[]>([]);
  const { preset: contextPreset, setPreset: setContextPreset } = usePreset();
  const [preset, setPresetState] = useState<'default' | 'neobrutalism'>(
    contextPreset || 'default'
  );
  const { resolvedTheme } = useTheme();
  const t = getHomepageDictionary(lang);

  const currentMode: 'light' | 'dark' =
    resolvedTheme === 'dark' ? 'dark' : 'light';

  useEffect(() => {
    if (contextPreset) {
      setPresetState(contextPreset);
    }
  }, [contextPreset]);

  useEffect(() => {
    dispatchStageEvent({
      type: 'justui-theme',
      preset,
      mode: currentMode,
    });
  }, [preset, currentMode]);

  const handleMount = useCallback((components: string[]) => {
    const now = Date.now();
    setWidgets((prev) => [
      ...prev,
      ...components.map((c, i) => ({
        id: `${now}-${i}-${Math.random().toString(36).slice(2, 7)}`,
        component: c,
        mountedAt: now + i * 150,
      })),
    ]);
    for (const c of components) {
      dispatchStageEvent({ type: 'justui-mount', component: c });
    }
  }, []);

  const handlePresetChange = useCallback(
    (next: 'default' | 'neobrutalism') => {
      setPresetState(next);
      setContextPreset(next);
      dispatchStageEvent({
        type: 'justui-theme',
        preset: next,
        mode: currentMode,
      });
    },
    [setContextPreset, currentMode]
  );

  const handleClear = useCallback(() => {
    setWidgets([]);
    dispatchStageEvent({ type: 'justui-clear' });
  }, []);

  return (
    <div className={cn('flex flex-col gap-6', className)}>
      {/* Centerpiece Preset Spotlight Toggle */}
      <div className="flex items-center justify-center">
        <div
          role="radiogroup"
          aria-label="Preset spotlight"
          className="border-border bg-card shadow-solid inline-flex items-center rounded-full border-(length:--just-border-width) p-1"
        >
          <button
            type="button"
            role="radio"
            aria-checked={preset === 'default'}
            onClick={() => handlePresetChange('default')}
            className={cn(
              'rounded-full px-4 py-1.5 font-mono text-xs transition-colors',
              preset === 'default'
                ? 'bg-accent text-foreground shadow-solid font-medium'
                : 'text-muted hover:text-foreground'
            )}
          >
            {t.presetCleanPrecision || 'Clean Precision'}
          </button>
          <button
            type="button"
            role="radio"
            aria-checked={preset === 'neobrutalism'}
            onClick={() => handlePresetChange('neobrutalism')}
            className={cn(
              'rounded-full px-4 py-1.5 font-mono text-xs transition-colors',
              preset === 'neobrutalism'
                ? 'bg-accent text-foreground shadow-solid font-medium'
                : 'text-muted hover:text-foreground'
            )}
          >
            {t.presetNeobrutalism || 'Neobrutalism'}
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        <InteractiveTerminal
          lang={lang}
          onMount={handleMount}
          onPresetChange={handlePresetChange}
          onClear={handleClear}
        />
        <LivingStage widgets={widgets} preset={preset} lang={lang} />
      </div>
    </div>
  );
}
