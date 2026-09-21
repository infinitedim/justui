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
  const [preset, setPresetState] = useState<JustUIPreset>(initialPreset);
  const [colorSpace, setColorSpaceState] = useState<ColorSpace>(initialColorSpace);

  const isInitialized = useRef(false);

  // Initialize from window location if in browser
  useEffect(() => {
    if (typeof window === 'undefined') return;
    const parsed = deserializeStudioState(window.location.search);
    if (parsed.seedColor) setSeedColorState(parsed.seedColor);
    if (parsed.isDark !== undefined) setIsDarkState(parsed.isDark);
    if (parsed.preset) setPresetState(parsed.preset);
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

  const setPreset = useCallback((nextPreset: JustUIPreset) => {
    setPresetState(nextPreset);
  }, []);

  const setColorSpace = useCallback((cs: ColorSpace) => {
    setColorSpaceState(cs);
  }, []);

  const reset = useCallback(() => {
    setSeedColorState(DEFAULT_SEED_COLOR);
    setIsDarkState(DEFAULT_IS_DARK);
    setPresetState(DEFAULT_PRESET);
    setColorSpaceState(DEFAULT_COLOR_SPACE);
  }, []);

  const resolvedTokens = useMemo(() => {
    return resolveTokens(seedColor, isDark, preset, colorSpace);
  }, [seedColor, isDark, preset, colorSpace]);

  const shareUrl = useMemo(() => {
    const baseUrl =
      typeof window !== 'undefined'
        ? window.location.href.split('?')[0] ?? window.location.href
        : 'https://justui.dev/en/studio';
    return buildShareUrl(baseUrl, {
      seedColor,
      isDark,
      preset,
      colorSpace,
    });
  }, [seedColor, isDark, preset, colorSpace]);

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
