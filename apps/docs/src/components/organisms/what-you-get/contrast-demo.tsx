'use client';

import { useMemo, useState } from 'react';
import { cn } from '@/lib/cn';

/** WCAG relative luminance from 0-255 sRGB channels. */
function luminance(r: number, g: number, b: number): number {
  const [lr, lg, lb] = [r, g, b].map((v) => {
    const s = v / 255;
    return s <= 0.03928 ? s / 12.92 : Math.pow((s + 0.055) / 1.055, 2.4);
  });
  return 0.2126 * lr + 0.7152 * lg + 0.0722 * lb;
}

function contrast(a: number, b: number): number {
  return (Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05);
}

/** hsl (h in degrees, s/l in %) to 0-255 channels. */
function hslToRgb(h: number, s: number, l: number): [number, number, number] {
  const sat = s / 100;
  const lig = l / 100;
  const a = sat * Math.min(lig, 1 - lig);
  const f = (n: number) => {
    const k = (n + h / 30) % 12;
    return lig - a * Math.max(-1, Math.min(k - 3, Math.min(9 - k, 1)));
  };
  return [f(0) * 255, f(8) * 255, f(4) * 255];
}

const DARK_TEXT = luminance(24, 24, 27);
const LIGHT_TEXT = 1;

/**
 * Interactive contrast readout. Drag the surface lightness; the demo picks
 * whichever text color clears WCAG AA and shows the measured ratio. Nothing
 * here is precomputed or hardcoded: it is the same math as the theme engine.
 */
export function ContrastDemo({ className }: { className?: string }) {
  const [lightness, setLightness] = useState(42);

  const result = useMemo(() => {
    const [r, g, b] = hslToRgb(84, 55, lightness);
    const bg = luminance(r, g, b);
    const onLight = contrast(LIGHT_TEXT, bg);
    const onDark = contrast(DARK_TEXT, bg);
    const useDark = onDark >= onLight;
    const ratio = Math.max(onLight, onDark);
    return {
      background: `rgb(${Math.round(r)}, ${Math.round(g)}, ${Math.round(b)})`,
      textColor: useDark ? '#18181b' : '#ffffff',
      ratio,
      pass: ratio >= 4.5,
      textName: useDark ? 'dark text' : 'light text',
    };
  }, [lightness]);

  return (
    <div className={cn('flex flex-col gap-4', className)}>
      <div
        className="border-border flex items-center justify-between rounded-(--just-radius-md) border-(length:--just-border-width) p-5"
        style={{ background: result.background, color: result.textColor }}
      >
        <span className="text-[15px] font-medium">Sample text</span>
        <span className="font-mono text-xs">
          {result.ratio.toFixed(2)}:1 {result.pass ? 'AA pass' : 'AA fail'} -{' '}
          {result.textName}
        </span>
      </div>
      <label className="text-muted flex flex-col gap-1.5 font-mono text-xs">
        <span className="flex justify-between">
          <span>Surface lightness</span>
          <span className="text-foreground">{lightness}%</span>
        </span>
        <input
          type="range"
          min={5}
          max={95}
          value={lightness}
          onChange={(e) => setLightness(Number(e.currentTarget.value))}
          className="accent-accent w-full"
        />
      </label>
    </div>
  );
}
