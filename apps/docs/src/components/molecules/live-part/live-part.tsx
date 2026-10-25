'use client';

// Client leaf: the Flutter view needs refs, effects, the visitor's preset
// and the resolved theme.
import { useTheme } from 'next-themes';
import { useRef } from 'react';
import { usePreset } from '@/components/providers';
import { cn } from '@/lib/cn';
import { getKitDictionary, type KitDictionary } from '@/lib/kit-translations';
import { useLivePart } from '@/lib/use-live-part';
import { useThemeSwitching } from '@/lib/use-theme-switching';
import type { LivePartProps } from './live-part.types';

/** The kit copy as plain JSON for the view (tuples become arrays). */
function kitStrings(dict: KitDictionary): Record<string, string | string[]> {
  return Object.fromEntries(
    Object.entries(dict).map(
      ([key, value]: [string, string | readonly string[]]) => [
        key,
        typeof value === 'string' ? value : [...value],
      ]
    )
  );
}

/**
 * A part rendered by the real Flutter component (`apps/showcase`) over its
 * React fallback. The fallback renders on the server, holds the layout and
 * stays for no-JS, a missing bundle and browsers without Blink + WasmGC.
 * The live view sits in an absolutely placed box over the fallback's box,
 * so the swap cannot shift the layout; it crossfades in 150ms (instant
 * under reduced motion) and drops back to the fallback while the theme
 * switch runs.
 *
 * Every Flutter view has the same fixed size, centered vertically on the
 * box, pinned to its left edge and clipped to it. The engine (3.47)
 * rasterizes all views through one shared surface and can resize it for
 * another view before this one renders
 * (fixed upstream in flutter/flutter#194401, not yet in stable), which cuts
 * off any view larger than another. Equal sizes make that harmless. Scenes
 * stay within 280 x 328 (`apps/showcase/test/scenes/stage_heights_test.dart`).
 *
 * Flutter sets `touch-action: none` on its view, which traps page
 * scrolling on touch screens; `pan-y` gives vertical pans back to the
 * page while taps and horizontal drags still reach Flutter.
 */
export function LivePart({
  scene,
  lang,
  preset,
  props,
  children,
  className,
}: LivePartProps) {
  const visitor = usePreset();
  const { resolvedTheme } = useTheme();
  const switching = useThemeSwitching();
  const wrapper = useRef<HTMLDivElement | null>(null);
  const host = useRef<HTMLDivElement | null>(null);
  const shown = useLivePart(wrapper, host, {
    scene,
    preset: preset ?? visitor.preset,
    theme: resolvedTheme === 'dark' ? 'dark' : 'light',
    locale: lang,
    strings: kitStrings(getKitDictionary(lang)),
    props,
  });
  const live = shown && !switching;
  return (
    <div
      ref={wrapper}
      data-live-part={scene}
      data-state={live ? 'live' : 'fallback'}
      className={cn('group/live relative flex items-center', className)}
    >
      <div
        inert={live}
        aria-hidden={live ? true : undefined}
        className="transition-opacity duration-150 group-data-[state=live]/live:opacity-0 motion-reduce:transition-none"
      >
        {children}
      </div>
      <div
        data-live-host=""
        inert={!live}
        aria-hidden={live ? undefined : true}
        className="pointer-events-none absolute inset-0 overflow-hidden opacity-0 transition-opacity duration-150 group-data-[state=live]/live:pointer-events-auto group-data-[state=live]/live:opacity-100 motion-reduce:transition-none"
      >
        <div
          ref={host}
          className="absolute top-[calc(50%-172px)] left-0 h-[344px] w-[320px] [&_flutter-view]:touch-pan-y!"
        />
      </div>
    </div>
  );
}
