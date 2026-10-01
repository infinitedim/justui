'use client';

import React, {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react';
import {
  type ColorSpace,
  type JustUIPreset,
  type ResolvedTokens,
  resolveTokens,
} from './theme/color-resolver';
import {
  buildShareUrl,
  deserializeStudioState,
  serializeStudioState,
} from './theme/url-serializer';
import { SITE_URL } from './site';
import { usePreset } from '@/components/providers';

export interface ThemeStudioState {
  seedColor: string;
  isDark: boolean;
  preset: JustUIPreset;
  colorSpace: ColorSpace;
  resolvedTokens: ResolvedTokens;
}

export interface ThemeStudioContextValue extends ThemeStudioState {
  setSeedColor: (color: string) => void;
  setIsDark: (isDark: boolean) => void;
  setPreset: (preset: JustUIPreset) => void;
  setColorSpace: (colorSpace: ColorSpace) => void;
  reset: () => void;
  shareUrl: string;
}

const DEFAULT_SEED_COLOR = '#a3e635';
const DEFAULT_IS_DARK = false;
const DEFAULT_PRESET: JustUIPreset = 'default';
const DEFAULT_COLOR_SPACE: ColorSpace = 'hsl';

const ThemeStudioContext = createContext<ThemeStudioContextValue | null>(null);

export interface ThemeStudioProviderProps {
  children: React.ReactNode;
  initialSeedColor?: string;
  initialIsDark?: boolean;
  initialPreset?: JustUIPreset;
  initialColorSpace?: ColorSpace;
}

export function ThemeStudioProvider({
  children,
  initialSeedColor = DEFAULT_SEED_COLOR,
  initialIsDark = DEFAULT_IS_DARK,
  initialPreset = DEFAULT_PRESET,
  initialColorSpace = DEFAULT_COLOR_SPACE,
}: ThemeStudioProviderProps) {
  const [seedColor, setSeedColorState] = useState<string>(initialSeedColor);
  const [isDark, setIsDarkState] = useState<boolean>(initialIsDark);
  // The preset is site-wide state (navbar toggle); the studio reads and
  // writes the same value instead of keeping a copy that can disagree.
  const { preset: sitePreset, setPreset: setPresetState } = usePreset();
  // A preset from the share link (server prop or ?preset=) is shown from the
  // first render and handed to the site-wide state once that has caught up.
  const [pendingPreset, setPendingPreset] = useState<JustUIPreset | null>(
    initialPreset !== DEFAULT_PRESET ? initialPreset : null
  );
  const preset = pendingPreset ?? sitePreset;

  useEffect(() => {
    if (pendingPreset === null) return;
    if (sitePreset === pendingPreset) {
      setPendingPreset(null);
    } else {
      setPresetState(pendingPreset);
    }
  }, [pendingPreset, sitePreset, setPresetState]);
  const [colorSpace, setColorSpaceState] =
    useState<ColorSpace>(initialColorSpace);

  const isInitialized = useRef(false);

  // Initialize from window location if in browser
  useEffect(() => {
    if (typeof window === 'undefined') return;
    const parsed = deserializeStudioState(window.location.search);
    if (parsed.seedColor) setSeedColorState(parsed.seedColor);
    if (parsed.isDark !== undefined) setIsDarkState(parsed.isDark);
    if (parsed.preset) setPendingPreset(parsed.preset);
    if (parsed.colorSpace) setColorSpaceState(parsed.colorSpace);
    isInitialized.current = true;
  }, []);

  // Synchronize URL search params with current studio state
  useEffect(() => {
    if (typeof window === 'undefined' || !isInitialized.current) return;
    const query = serializeStudioState({
      seedColor,
      isDark,
      preset,
      colorSpace,
    });
    const currentQuery = window.location.search.startsWith('?')
      ? window.location.search.slice(1)
      : window.location.search;

    if (currentQuery !== query && window.history?.replaceState) {
      const cleanPath = window.location.pathname;
      window.history.replaceState(null, '', `${cleanPath}?${query}`);
    }
  }, [seedColor, isDark, preset, colorSpace]);

  const setSeedColor = useCallback((color: string) => {
    setSeedColorState(color);
  }, []);

  const setIsDark = useCallback((dark: boolean) => {
    setIsDarkState(dark);
  }, []);

  const setPreset = useCallback(
    (nextPreset: JustUIPreset) => {
      setPendingPreset(null);
      setPresetState(nextPreset);
    },
    [setPresetState]
  );

  const setColorSpace = useCallback((cs: ColorSpace) => {
    setColorSpaceState(cs);
  }, []);

  const reset = useCallback(() => {
    setSeedColorState(DEFAULT_SEED_COLOR);
    setIsDarkState(DEFAULT_IS_DARK);
    setPendingPreset(null);
    setPresetState(DEFAULT_PRESET);
    setColorSpaceState(DEFAULT_COLOR_SPACE);
  }, [setPresetState]);

  const resolvedTokens = useMemo(() => {
    return resolveTokens(seedColor, isDark, preset, colorSpace);
  }, [seedColor, isDark, preset, colorSpace]);

  // Server and first client render agree on the canonical site URL; the
  // real page URL (preview deployments, localhost) replaces it after mount.
  const [pageUrl, setPageUrl] = useState(`${SITE_URL}/en/studio`);
  useEffect(() => {
    setPageUrl(window.location.href.split('?')[0] ?? window.location.href);
  }, []);

  const shareUrl = useMemo(
    () => buildShareUrl(pageUrl, { seedColor, isDark, preset, colorSpace }),
    [pageUrl, seedColor, isDark, preset, colorSpace]
  );

  const contextValue = useMemo<ThemeStudioContextValue>(() => {
    return {
      seedColor,
      isDark,
      preset,
      colorSpace,
      resolvedTokens,
      setSeedColor,
      setIsDark,
      setPreset,
      setColorSpace,
      reset,
      shareUrl,
    };
  }, [
    seedColor,
    isDark,
    preset,
    colorSpace,
    resolvedTokens,
    setSeedColor,
    setIsDark,
    setPreset,
    setColorSpace,
    reset,
    shareUrl,
  ]);

  return (
    <ThemeStudioContext.Provider value={contextValue}>
      {children}
    </ThemeStudioContext.Provider>
  );
}

export function useThemeStudio(): ThemeStudioContextValue {
  const context = useContext(ThemeStudioContext);
  if (!context) {
    throw new Error('useThemeStudio must be used within a ThemeStudioProvider');
  }
  return context;
}
