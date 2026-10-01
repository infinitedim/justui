'use client';

import { useState, useCallback, useEffect, useRef } from 'react';
import { useTheme } from 'next-themes';
import { cn } from '@/lib/cn';
import { usePreset } from '@/components/providers';
import { InteractiveTerminal } from '@/components/organisms/interactive-terminal';
import type { InteractiveTerminalHandle } from '@/components/organisms/interactive-terminal';
import { LivingStage } from '@/components/organisms/living-stage';
import type { MountedWidget } from '@/components/organisms/living-stage';
import { dispatchStageEvent } from '@/lib/stage-bridge';
import type { HeroInteractiveProps } from './hero-interactive.types';
import type { JustUIPreset } from '@/lib/presets';

export function HeroInteractive({
  lang = 'en',
  className,
}: HeroInteractiveProps) {
  const [widgets, setWidgets] = useState<MountedWidget[]>([]);
  const { preset, setPreset } = usePreset();
  const { resolvedTheme } = useTheme();
  const terminalRef = useRef<InteractiveTerminalHandle>(null);

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
    (next: JustUIPreset) => {
      setPreset(next);
    },
    [setPreset]
  );

  const handleClear = useCallback(() => {
    setWidgets([]);
    dispatchStageEvent({ type: 'justui-clear' });
  }, []);

  const handleRunCommand = useCallback((command: string) => {
    terminalRef.current?.runCommand(command);
  }, []);

  return (
    <div
      className={cn(
        'mx-auto flex w-full max-w-6xl flex-col gap-6 lg:gap-8',
        className
      )}
    >
      <div className="grid w-full grid-cols-1 items-stretch gap-8 lg:grid-cols-2">
        <InteractiveTerminal
          ref={terminalRef}
          lang={lang}
          onMount={handleMount}
          onPresetChange={handlePresetChange}
          onClear={handleClear}
          className="h-full"
        />
        <LivingStage
          widgets={widgets}
          preset={preset}
          lang={lang}
          onClear={handleClear}
          onRunCommand={handleRunCommand}
          className="h-full"
        />
      </div>
    </div>
  );
}
