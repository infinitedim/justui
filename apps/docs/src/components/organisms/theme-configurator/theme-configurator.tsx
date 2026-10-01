'use client';

import { useMemo, useState, useCallback, useEffect, useRef } from 'react';
import { cn } from '@/lib/cn';
import { useThemeStudio } from '@/lib/theme-studio-context';
import { getStudioDictionary } from '@/lib/theme-studio-translations';
import { formatMessage } from '@/lib/homepage-translations';
import {
  contrastRatio,
  hexToHsl,
  hslToHex,
  normalizeHex,
  type ColorSpace,
} from '@/lib/theme/color-resolver';
import { LightnessSlider } from '@/components/molecules/lightness-slider';
import { StateToggle } from '@/components/molecules/state-toggle';
import { VariantPicker } from '@/components/molecules/variant-picker';
import { Input } from '@/components/atoms/input';
import { Badge } from '@/components/atoms/badge';
import type { ThemeConfiguratorProps } from './theme-configurator.types';

const HEX_PATTERN = /^#[0-9a-f]{6}$/i;
const MAX_RECENT = 6;

const sectionTitle = 'text-foreground text-sm font-semibold';

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
    setColorSpace,
  } = useThemeStudio();

  const [copiedToken, setCopiedToken] = useState<string | null>(null);
  const [copyFailed, setCopyFailed] = useState<boolean>(false);
  const [recent, setRecent] = useState<string[]>([]);

  const lastHueSatRef = useRef<[number, number]>([83, 77]);

  // Remember a seed once it has stayed put for a moment, so dragging the
  // picker or the slider does not flood the history.
  useEffect(() => {
    const normalized = seedColor.toLowerCase();
    if (!HEX_PATTERN.test(normalized)) return;
    const id = window.setTimeout(() => {
      setRecent((prev) =>
        [normalized, ...prev.filter((c) => c !== normalized)].slice(
          0,
          MAX_RECENT
        )
      );
    }, 600);
    return () => window.clearTimeout(id);
  }, [seedColor]);

  const currentLightness = useMemo(() => {
    const [h, s, l] = hexToHsl(seedColor);
    if (s > 0 && l > 0 && l < 100) {
      lastHueSatRef.current = [h, s];
    }
    return l;
  }, [seedColor]);

  // Keeps the hue even after dragging lightness to 0% or 100% and back.
  const handleLightnessChange = useCallback(
    (newL: number) => {
      const [h, s, l] = hexToHsl(seedColor);
      const [savedH, savedS] =
        s === 0 && (l === 0 || l === 100) ? lastHueSatRef.current : [h, s];
      setSeedColor(hslToHex(savedH, savedS, newL));
    },
    [seedColor, setSeedColor]
  );

  const handleHexInputChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      const val = e.target.value.trim();
      setSeedColor(val.startsWith('#') ? val : `#${val}`);
    },
    [setSeedColor]
  );

  const handleHexInputBlur = useCallback(() => {
    setSeedColor(normalizeHex(seedColor));
  }, [seedColor, setSeedColor]);

  const handleCopyColor = useCallback(async (token: string, hex: string) => {
    if (typeof navigator === 'undefined' || !navigator.clipboard) return;
    try {
      await navigator.clipboard.writeText(hex);
      setCopiedToken(token);
      setTimeout(() => setCopiedToken(null), 1500);
    } catch {
      setCopyFailed(true);
      setTimeout(() => setCopyFailed(false), 1500);
    }
  }, []);

  const colorSpaceOptions = useMemo(
    () => [
      { value: 'hsl', label: t.colorSpaceHsl },
      { value: 'oklch', label: t.colorSpaceOklch },
      { value: 'hsluv', label: t.colorSpaceHsluv },
    ],
    [t.colorSpaceHsl, t.colorSpaceOklch, t.colorSpaceHsluv]
  );

  // Token names as they appear in packages/tokens (JustColorScheme) and in
  // JustThemeData.fromSeed, each paired with the surface it is read on.
  const resolvedList = useMemo(() => {
    const bg = resolvedTokens.background;
    const pairs: {
      token: string;
      value: string;
      target?: { token: string; value: string };
    }[] = [
      { token: 'colors.background', value: bg },
      {
        token: 'colors.card',
        value: resolvedTokens.card,
        target: { token: 'textPrimary', value: resolvedTokens.textPrimary },
      },
      {
        token: 'colors.textPrimary',
        value: resolvedTokens.textPrimary,
        target: { token: 'background', value: bg },
      },
      {
        token: 'colors.textSecondary',
        value: resolvedTokens.textSecondary,
        target: { token: 'background', value: bg },
      },
      {
        token: 'seedColor',
        value: resolvedTokens.accent,
        target: {
          token: t.seedTextTarget,
          value: resolvedTokens.accentForeground,
        },
      },
      {
        token: 'colors.borderDefault',
        value: resolvedTokens.border,
        target: { token: 'background', value: bg },
      },
      {
        token: 'colors.success',
        value: resolvedTokens.success,
        target: { token: 'background', value: bg },
      },
      {
        token: 'colors.warning',
        value: resolvedTokens.warning,
        target: { token: 'background', value: bg },
      },
      {
        token: 'colors.error',
        value: resolvedTokens.error,
        target: { token: 'background', value: bg },
      },
    ];

    return pairs.map((pair) => {
      if (!pair.target)
        return { ...pair, ratio: null, variant: 'default' as const };
      const ratio = contrastRatio(pair.value, pair.target.value);
      const variant =
        ratio >= 4.5
          ? ('success' as const)
          : ratio >= 3
            ? ('warning' as const)
            : ('error' as const);
      return { ...pair, ratio, variant };
    });
  }, [resolvedTokens, t.seedTextTarget]);

  return (
    <div
      className={cn(
        'border-border bg-card flex flex-col gap-6 rounded-(--just-radius-lg) border-(length:--just-border-width) p-6 shadow-sm',
        className
      )}
      data-testid="theme-configurator"
    >
      <section className="flex flex-col gap-4">
        <label htmlFor="seed-color-input" className={sectionTitle}>
          {t.seedColor}
        </label>

        <div className="flex items-center gap-3">
          <div className="border-border relative h-10 w-12 shrink-0 overflow-hidden rounded-(--just-radius-md) border-(length:--just-border-width)">
            <input
              id="seed-color-picker"
              type="color"
              value={HEX_PATTERN.test(seedColor) ? seedColor : '#a3e635'}
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
            aria-label={t.hexLabel}
          />
        </div>

        {recent.length > 1 ? (
          <div className="flex flex-wrap items-center gap-2">
            <span className="text-secondary text-xs">{t.recentColors}</span>
            {recent.map((hex) => (
              <button
                key={hex}
                type="button"
                onClick={() => setSeedColor(hex)}
                aria-label={hex}
                title={hex}
                className={cn(
                  'border-border h-6 w-6 rounded-(--just-radius-sm) border-(length:--just-border-width)',
                  'focus-visible:outline-accent focus-visible:outline-2 focus-visible:outline-offset-2',
                  hex === seedColor.toLowerCase() &&
                    'outline-foreground outline-2 outline-offset-2'
                )}
                style={{ backgroundColor: hex }}
              />
            ))}
          </div>
        ) : null}

        <LightnessSlider
          value={currentLightness}
          onChange={handleLightnessChange}
          label={t.lightness}
        />
      </section>

      <hr className="border-border" />

      <section className="flex flex-col gap-3">
        <div className="flex items-center justify-between">
          <span className={sectionTitle}>{t.mode}</span>
          <StateToggle
            value={isDark}
            onChange={setIsDark}
            label={isDark ? t.dark : t.light}
          />
        </div>
        <div className="flex items-center justify-between gap-3">
          <span className={sectionTitle}>{t.preset}</span>
          <code className="text-secondary font-mono text-xs">
            {preset === 'neobrutalism' ? t.presetNeobrutalism : t.presetDefault}
          </code>
        </div>
      </section>

      <hr className="border-border" />

      <section className="flex flex-col gap-2">
        <span className={sectionTitle}>{t.colorSpace}</span>
        <VariantPicker
          options={colorSpaceOptions}
          value={colorSpace}
          onChange={(val) => setColorSpace(val as ColorSpace)}
          label={t.colorSpace}
        />
        <p className="text-secondary text-xs leading-relaxed">
          {t.colorSpaceHint}
        </p>
      </section>

      <hr className="border-border" />

      <section className="flex flex-col gap-3">
        <div className="flex items-baseline justify-between gap-3">
          <span className={sectionTitle}>{t.resolvedPalette}</span>
          <span aria-live="polite" className="text-xs">
            {copiedToken ? (
              <span className="text-secondary">{t.copied}</span>
            ) : copyFailed ? (
              <span className="text-error">{t.copyFailed}</span>
            ) : (
              <span className="text-secondary">{t.resolvedPaletteHint}</span>
            )}
          </span>
        </div>

        <ul className="grid gap-2">
          {resolvedList.map((item) => (
            <li key={item.token}>
              <button
                type="button"
                onClick={() => handleCopyColor(item.token, item.value)}
                className={cn(
                  'border-border hover:bg-background flex w-full items-center justify-between gap-2 rounded-(--just-radius-md) border-(length:--just-border-width) p-2 text-left transition-colors',
                  copiedToken === item.token && 'bg-accent-muted'
                )}
                aria-label={formatMessage(t.copyToken, { token: item.token })}
              >
                <span className="flex min-w-0 items-center gap-2.5">
                  <span
                    className="border-border h-6 w-6 shrink-0 rounded-(--just-radius-sm) border-(length:--just-border-width)"
                    style={{ backgroundColor: item.value }}
                    aria-hidden="true"
                  />
                  <span className="flex min-w-0 flex-col">
                    <span className="text-foreground truncate font-mono text-xs">
                      {item.token}
                    </span>
                    <span className="text-secondary font-mono text-xs">
                      {item.value}
                    </span>
                  </span>
                </span>

                {item.ratio !== null && item.target ? (
                  <span className="flex shrink-0 flex-col items-end gap-0.5">
                    <Badge variant={item.variant} className="font-mono">
                      {item.ratio.toFixed(1)}:1
                    </Badge>
                    <span className="text-secondary text-xs">
                      {formatMessage(t.contrastOn, {
                        target: item.target.token,
                      })}
                    </span>
                  </span>
                ) : null}
              </button>
            </li>
          ))}
        </ul>
      </section>
    </div>
  );
}
