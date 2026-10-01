'use client';

import { useState, useCallback, useEffect } from 'react';
import { useTheme } from 'next-themes';
import { cn } from '@/lib/cn';
import { usePreset } from '@/components/providers';
import {
  InteractiveTerminal,
  INITIAL_COMMAND,
  parseCommand,
} from '@/components/organisms/interactive-terminal';
import { LivingStage } from '@/components/organisms/living-stage';
import type { MountedWidget } from '@/components/organisms/living-stage';
import { dispatchStageEvent } from '@/lib/stage-bridge';
import type { HeroInteractiveProps } from './hero-interactive.types';

/** What the terminal's pre-run command copied, shown before any input. */
const INITIAL_WIDGETS: MountedWidget[] = (
  parseCommand(INITIAL_COMMAND).mountComponents ?? []
).map((component) => ({ id: `initial-${component}`, component, mountedAt: 0 }));

export function HeroInteractive({
  lang = 'en',
  className,
}: HeroInteractiveProps) {
  const [widgets, setWidgets] = useState<MountedWidget[]>(INITIAL_WIDGETS);
  const { preset, setPreset } = usePreset();
  const { resolvedTheme } = useTheme();

  const currentMode: 'light' | 'dark' =
    resolvedTheme === 'dark' ? 'dark' : 'light';

  useEffect(() => {
    dispatchStageEvent({
      type: 'justui-theme',
      preset,
      mode: currentMode,
    });
  }, [preset, currentMode]);

  const handleMount = useCallback((components: string[]) => {
    const now = Date.now();
    // A component the project already has is not added twice.
    setWidgets((prev) => [
      ...prev,
      ...components
        .filter((c) => !prev.some((w) => w.component === c))
        .map((c) => ({ id: `${now}-${c}`, component: c, mountedAt: now })),
    ]);
    for (const c of components) {
      dispatchStageEvent({ type: 'justui-mount', component: c });
    }
  }, []);

  return (
    <div
      className={cn(
        'mx-auto grid w-full max-w-6xl items-stretch gap-6 lg:grid-cols-2 lg:gap-8',
        className
      )}
    >
      <InteractiveTerminal
        lang={lang}
        onMount={handleMount}
        onPresetChange={setPreset}
        className="h-full"
      />
      <LivingStage
        widgets={widgets}
        preset={preset}
        lang={lang}
        className="h-full"
      />
    </div>
  );
}
