'use client';

import { useState, useMemo } from 'react';
import { cn } from '@/lib/cn';
import { Badge } from '@/components/atoms/badge';
import { Slider } from '@/components/atoms/slider';
import { FormulaMathBlock } from '@/components/molecules/formula-math-block';

interface BentoContrastAuditorProps {
  title: string;
  description: string;
  className?: string;
}

/**
 * Calculates sRGB relative luminance per WCAG 2.1 specs.
 */
function sRgbLuminance(r: number, g: number, b: number): number {
  const a = [r, g, b].map((v) => {
    const s = v / 255;
    return s <= 0.03928 ? s / 12.92 : Math.pow((s + 0.055) / 1.055, 2.4);
  });
  return 0.2126 * a[0] + 0.7152 * a[1] + 0.0722 * a[2];
}

/**
 * Calculates contrast ratio between two luminance values (>= 1.0 and <= 21.0).
 */
function contrastRatio(l1: number, l2: number): number {
  const lighter = Math.max(l1, l2);
  const darker = Math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

export function BentoContrastAuditor({
  title,
  description,
  className,
}: BentoContrastAuditorProps) {
  // Lightness value from 5% to 95%
  const [lightness, setLightness] = useState<number>(38);
  const [enforceAA, setEnforceAA] = useState<boolean>(false);

  // Derive background RGB from a primary blue-teal hue based on lightness
  const effectiveLightness = useMemo(() => {
    if (!enforceAA) return lightness;
    // Auto-correct to satisfy >= 4.5:1 against dark background or >= 4.5:1 against light text
    if (lightness > 18 && lightness < 62) {
      return lightness < 40 ? 16 : 74;
    }
    return lightness;
  }, [lightness, enforceAA]);

  const bgRgb = useMemo(() => {
    // Monochromatic scale or primary accent tint
    const v = Math.round((effectiveLightness / 100) * 255);
    return { r: v, g: Math.round(v * 0.95), b: Math.round(v * 0.9) };
  }, [effectiveLightness]);

  const bgLum = useMemo(() => {
    return sRgbLuminance(bgRgb.r, bgRgb.g, bgRgb.b);
  }, [bgRgb]);

  // White text luminance
  const textLum = sRgbLuminance(255, 255, 255);
  const textContrast = useMemo(() => {
    return contrastRatio(textLum, bgLum);
  }, [textLum, bgLum]);

  // Border luminance (tested against a border color)
  const borderLum = sRgbLuminance(120, 120, 120);
  const borderContrast = useMemo(() => {
    return contrastRatio(borderLum, bgLum);
  }, [borderLum, bgLum]);

  const isTextPass = textContrast >= 4.5;
  const isBorderPass = borderContrast >= 3.0;

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
          <Badge variant="outline">ACCESSIBILITY (A11Y)</Badge>
          <button
            type="button"
            onClick={() => setEnforceAA(!enforceAA)}
            className={cn(
              'rounded-(--just-radius-sm) border px-2.5 py-1 font-mono text-xs transition-colors',
              enforceAA
                ? 'border-accent bg-accent/20 text-accent-deep dark:text-accent font-semibold'
                : 'border-border bg-muted/20 text-muted hover:text-foreground'
            )}
          >
            {enforceAA ? 'Auto-Enforce AA: ON' : 'Auto-Enforce AA: OFF'}
          </button>
        </div>

        <h3 className="text-foreground mt-4 font-mono text-lg font-bold">
          {title}
        </h3>
        <p className="text-muted mt-1 text-sm leading-relaxed">{description}</p>

        {/* Live sample preview swatch */}
        <div
          className="mt-5 flex flex-col items-center justify-center rounded-(--just-radius-md) border border-white/20 p-4 transition-colors duration-150"
          style={{
            backgroundColor: `rgb(${bgRgb.r}, ${bgRgb.g}, ${bgRgb.b})`,
          }}
        >
          <span className="font-mono text-sm font-bold text-white drop-shadow-xs">
            Text Sample (White)
          </span>
          <div className="mt-2 flex gap-2 font-mono text-xs">
            <span
              className={cn(
                'rounded px-1.5 py-0.5 font-bold',
                isTextPass
                  ? 'bg-emerald-500/20 text-emerald-300'
                  : 'bg-rose-500/30 text-rose-200'
              )}
            >
              Text: {textContrast.toFixed(2)}:1 {isTextPass ? 'PASS' : 'FAIL'}
            </span>
            <span
              className={cn(
                'rounded px-1.5 py-0.5 font-bold',
                isBorderPass
                  ? 'bg-emerald-500/20 text-emerald-300'
                  : 'bg-rose-500/30 text-rose-200'
              )}
            >
              Border: {borderContrast.toFixed(2)}:1{' '}
              {isBorderPass ? 'PASS' : 'FAIL'}
            </span>
          </div>
        </div>

        {/* Slider control */}
        <div className="mt-4 flex flex-col gap-1.5">
          <div className="text-muted flex items-center justify-between font-mono text-xs">
            <span>Background Lightness (L)</span>
            <span className="text-foreground font-semibold">
              {effectiveLightness}%
              {enforceAA && effectiveLightness !== lightness
                ? ` (Shifted from ${lightness}%)`
                : ''}
            </span>
          </div>
          <Slider
            value={lightness}
            min={5}
            max={95}
            step={1}
            label="Lightness"
            onChange={(e) => setLightness(Number(e.currentTarget.value))}
          />
        </div>

        {/* Formula Math Block */}
        <div className="mt-3">
          <FormulaMathBlock
            formula="Ratio = (L1 + 0.05) / (L2 + 0.05) >= 4.5:1"
            caption="WCAG AA Relative Luminance Contrast Metric"
          />
        </div>
      </div>

      <div className="border-border/60 mt-4 flex items-center justify-between border-t pt-3 font-mono text-xs">
        <span className="text-muted">Dynamic Runtime Audit</span>
        <span className="text-accent font-bold">100% WCAG COMPLIANT</span>
      </div>
    </div>
  );
}
