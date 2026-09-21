'use client';

import { useMemo, useState, useCallback, useRef } from 'react';
import { cn } from '@/lib/cn';
import { useThemeStudio } from '@/lib/theme-studio-context';
import { getStudioDictionary } from '@/lib/theme-studio-translations';
import {
  contrastRatio,
  hexToHsl,
  hslToHex,
  normalizeHex,
  type JustUIPreset,
  type ColorSpace,
} from '@/lib/theme/color-resolver';
import { ColorSwatchItem } from '@/components/molecules/color-swatch-item';
import { LightnessSlider } from '@/components/molecules/lightness-slider';
import { StateToggle } from '@/components/molecules/state-toggle';
import { VariantPicker } from '@/components/molecules/variant-picker';
import { Input } from '@/components/atoms/input';
import { Badge } from '@/components/atoms/badge';
import type { ThemeConfiguratorProps } from './theme-configurator.types';

const PRESET_SWATCHES = [
  { name: 'Lime', hex: '#a3e635' },
  { name: 'Blue', hex: '#3b82f6' },
  { name: 'Rose', hex: '#f43f5e' },
  { name: 'Amber', hex: '#f59e0b' },
  { name: 'Violet', hex: '#8b5cf6' },
  { name: 'Cyan', hex: '#06b6d4' },
];

export function ThemeConfigurator({
  lang = 'en',
  className,
}: ThemeConfiguratorProps) {
  const t = getStudioDictionary(lang);
  const {
    seedColor,
    isDark,
    preset,
    colorSpace,
    resolvedTokens,
    setSeedColor,
    setIsDark,
    setPreset,
    setColorSpace,
  } = useThemeStudio();

  const [copiedToken, setCopiedToken] = useState<string | null>(null);

  const lastHueSatRef = useRef<[number, number]>([83, 77]);

  // Compute lightness from current seed and track non-zero hue/saturation
  const currentLightness = useMemo(() => {
    const [h, s, l] = hexToHsl(seedColor);
    if (s > 0 && l > 0 && l < 100) {
      lastHueSatRef.current = [h, s];
    }
    return l;
  }, [seedColor]);

  // Handle lightness change from slider, retaining hue even if dragging to 0% and back
  const handleLightnessChange = useCallback(
    (newL: number) => {
      const [h, s, l] = hexToHsl(seedColor);
      const [savedH, savedS] =
        s === 0 && (l === 0 || l === 100) ? lastHueSatRef.current : [h, s];
      const nextHex = hslToHex(savedH, savedS, newL);
      setSeedColor(nextHex);
    },
    [seedColor, setSeedColor]
  );

  // Handle manual hex text change
  const handleHexInputChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      let val = e.target.value.trim();
      if (!val.startsWith('#')) {
        val = `#${val}`;
      }
      setSeedColor(val);
    },
    [setSeedColor]
  );

  // Normalize seed color on blur
  const handleHexInputBlur = useCallback(() => {
    const normalized = normalizeHex(seedColor);
    setSeedColor(normalized);
  }, [seedColor, setSeedColor]);

  // Copy hex to clipboard on swatch click
  const handleCopyColor = useCallback((tokenName: string, hex: string) => {
    if (typeof navigator !== 'undefined' && navigator.clipboard) {
      navigator.clipboard.writeText(hex).catch(() => {});
      setCopiedToken(tokenName);
      setTimeout(() => setCopiedToken(null), 1500);
    }
  }, []);

  // Preset options
  const presetOptions = useMemo(
    () => [
      { value: 'default', label: t.presetDefault },
      { value: 'neobrutalism', label: t.presetNeobrutalism },
    ],
    [t.presetDefault, t.presetNeobrutalism]
  );

  // Color space options
  const colorSpaceOptions = useMemo(
    () => [
      { value: 'hsl', label: t.colorSpaceHsl },
      { value: 'oklch', label: t.colorSpaceOklch },
      { value: 'hsluv', label: t.colorSpaceHsluv },
    ],
    [t.colorSpaceHsl, t.colorSpaceOklch, t.colorSpaceHsluv]
  );

  // Resolved tokens list for display with meaningful contrast pairings
  const resolvedList = useMemo(() => {
    const bg = resolvedTokens.background;
    return [
      { key: 'background', label: t.tokenBackground, value: resolvedTokens.background, target: bg },
      { key: 'card', label: t.tokenCard, value: resolvedTokens.card, target: resolvedTokens.textPrimary },
      { key: 'textPrimary', label: t.tokenTextPrimary, value: resolvedTokens.textPrimary, target: bg },
      { key: 'textSecondary', label: t.tokenTextSecondary, value: resolvedTokens.textSecondary, target: bg },
      { key: 'accent', label: t.tokenAccent, value: resolvedTokens.accent, target: resolvedTokens.accentForeground },
      { key: 'border', label: t.tokenBorder, value: resolvedTokens.border, target: bg },
      { key: 'success', label: t.tokenSuccess, value: resolvedTokens.success, target: bg },
      { key: 'warning', label: t.tokenWarning, value: resolvedTokens.warning, target: bg },
      { key: 'error', label: t.tokenError, value: resolvedTokens.error, target: bg },
    ].map((item) => {
      const ratio =
        item.key === 'background'
          ? 1.0
          : contrastRatio(item.value, item.target);
      let badgeVariant: 'success' | 'warning' | 'error' | 'default' = 'default';
      if (item.key !== 'background') {
        if (ratio >= 4.5) {
          badgeVariant = 'success';
        } else if (ratio >= 3.0) {
          badgeVariant = 'warning';
        } else {
          badgeVariant = 'error';
        }
      }
      return {
        ...item,
        ratio,
        badgeVariant,
      };
    });
  }, [resolvedTokens, t]);

  return (
    <div
      className={cn(
        'border-border bg-card flex flex-col gap-6 rounded-(--just-radius-lg) border p-6 shadow-sm',
        className
      )}
      data-testid="theme-configurator"
    >
      {/* 1. Seed Color Section */}
      <section className="flex flex-col gap-4">
        <div className="flex items-center justify-between">
          <label
            htmlFor="seed-color-input"
            className="text-foreground text-sm font-semibold tracking-tight"
          >
            {t.seedColor}
          </label>
          <span className="text-muted font-mono text-xs uppercase">
            {seedColor}
          </span>
        </div>

        {/* Color picker and hex text input */}
        <div className="flex items-center gap-3">
          <div className="border-border relative h-10 w-12 shrink-0 overflow-hidden rounded-(--just-radius-md) border shadow-inner">
            <input
              id="seed-color-picker"
              type="color"
              value={seedColor.length === 7 ? seedColor : '#a3e635'}
              onChange={(e) => setSeedColor(e.target.value)}
              className="absolute -top-2 -left-2 h-16 w-16 cursor-pointer border-0 p-0"
              aria-label={t.seedColor}
            />
          </div>
          <Input
            id="seed-color-input"
            type="text"
            value={seedColor}
            onChange={handleHexInputChange}
            onBlur={handleHexInputBlur}
            placeholder="#a3e635"
            maxLength={9}
            className="font-mono text-sm"
            aria-label="Hex color string"
          />
        </div>

        {/* Preset Seed Color Swatches */}
        <div className="grid grid-cols-2 gap-2 sm:grid-cols-3">
          {PRESET_SWATCHES.map((swatch) => (
            <ColorSwatchItem
              key={swatch.name}
              color={swatch.hex}
              label={swatch.name}
              value={swatch.hex}
              active={seedColor.toLowerCase() === swatch.hex.toLowerCase()}
              onClick={() => setSeedColor(swatch.hex)}
            />
          ))}
        </div>

        {/* Lightness Slider */}
        <LightnessSlider
          value={currentLightness}
          onChange={handleLightnessChange}
          label={t.lightness}
        />
      </section>

      <div className="border-border border-t" />

      {/* 2. Mode and Preset Section */}
      <section className="flex flex-col gap-4">
        <div className="flex items-center justify-between">
          <span className="text-foreground text-sm font-semibold tracking-tight">
            {t.mode}
          </span>
          <StateToggle
            value={isDark}
            onChange={setIsDark}
            label={isDark ? t.dark : t.light}
          />
        </div>

        <div className="flex flex-col gap-2">
          <span className="text-foreground text-sm font-semibold tracking-tight">
            {t.preset}
          </span>
          <VariantPicker
            options={presetOptions}
            value={preset}
            onChange={(val) => setPreset(val as JustUIPreset)}
            label={t.preset}
          />
        </div>
      </section>

      <div className="border-border border-t" />

      {/* 3. Color Space Section */}
      <section className="flex flex-col gap-2">
        <div className="flex items-center justify-between">
          <span className="text-foreground text-sm font-semibold tracking-tight">
            {t.colorSpace}
          </span>
        </div>
        <VariantPicker
          options={colorSpaceOptions}
          value={colorSpace}
          onChange={(val) => setColorSpace(val as ColorSpace)}
          label={t.colorSpace}
        />
      </section>

      <div className="border-border border-t" />

      {/* 4. Resolved Palette Section */}
      <section className="flex flex-col gap-3">
        <div className="flex items-center justify-between">
          <span className="text-foreground text-sm font-semibold tracking-tight">
            {t.resolvedPalette}
          </span>
          {copiedToken ? (
            <span className="text-accent font-mono text-xs animate-pulse">
              {t.copied}
            </span>
          ) : null}
        </div>

        <div className="grid grid-cols-1 gap-2 sm:grid-cols-2">
          {resolvedList.map((token) => (
            <button
              key={token.key}
              type="button"
              onClick={() => handleCopyColor(token.key, token.value)}
              className={cn(
                'border-border hover:bg-muted/40 flex items-center justify-between rounded-(--just-radius-md) border p-2 text-left transition-colors',
                copiedToken === token.key && 'border-accent bg-accent-muted'
              )}
              title={`${token.label} (${token.value}) - Click to copy`}
              aria-label={`Copy ${token.label} color`}
            >
              <div className="flex items-center gap-2.5 min-w-0">
                <span
                  className="border-border/60 h-5 w-5 shrink-0 rounded border shadow-xs"
                  style={{ backgroundColor: token.value }}
                  aria-hidden="true"
                />
                <div className="flex flex-col truncate">
                  <span className="text-foreground font-mono text-xs font-medium truncate">
                    {token.label}
                  </span>
                  <span className="text-muted font-mono text-[10px]">
                    {token.value}
                  </span>
                </div>
              </div>

              {token.key !== 'background' ? (
                <Badge
                  variant={token.badgeVariant}
                  className="shrink-0 text-[10px] font-mono px-1.5 py-0"
                >
                  {token.ratio.toFixed(1)}:1
                </Badge>
              ) : null}
            </button>
          ))}
        </div>
      </section>
    </div>
  );
}
