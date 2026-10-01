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
import { usePreset } from '@/components/providers/preset-provider';

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
const DEFAULT_COLOR_SPACE: ColorSpace = 'hsl';

const ThemeStudioContext = createContext<ThemeStudioContextValue | null>(null);

export interface ThemeStudioProviderProps {
  children: React.ReactNode;
  initialSeedColor?: string;
  initialIsDark?: boolean;
  initialColorSpace?: ColorSpace;
}

export function ThemeStudioProvider({
  children,
  initialSeedColor = DEFAULT_SEED_COLOR,
  initialIsDark = DEFAULT_IS_DARK,
  initialColorSpace = DEFAULT_COLOR_SPACE,
}: ThemeStudioProviderProps) {
  const [seedColor, setSeedColorState] = useState<string>(initialSeedColor);
  const [isDark, setIsDarkState] = useState<boolean>(initialIsDark);
  // The preset is site-wide (navbar PresetToggle); the Studio only reads it.
  const { preset, setPreset: setGlobalPreset } = usePreset();
  const [colorSpace, setColorSpaceState] =
    useState<ColorSpace>(initialColorSpace);

  const isInitialized = useRef(false);

  // Initialize from window location if in browser
  useEffect(() => {
    if (typeof window === 'undefined') return;
    const parsed = deserializeStudioState(window.location.search);
    if (parsed.seedColor) setSeedColorState(parsed.seedColor);
    if (parsed.isDark !== undefined) setIsDarkState(parsed.isDark);
    // A shared link wins over the viewer's stored preset: they should see
    // exactly what was shared. `parsed.preset` is whitelisted by the parser.
    if (parsed.preset) setGlobalPreset(parsed.preset);
    if (parsed.colorSpace) setColorSpaceState(parsed.colorSpace);
    isInitialized.current = true;
  }, [setGlobalPreset]);

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
      setGlobalPreset(nextPreset);
    },
    [setGlobalPreset]
  );

  const setColorSpace = useCallback((cs: ColorSpace) => {
    setColorSpaceState(cs);
  }, []);

  const reset = useCallback(() => {
    setSeedColorState(DEFAULT_SEED_COLOR);
    setIsDarkState(DEFAULT_IS_DARK);
    setColorSpaceState(DEFAULT_COLOR_SPACE);
  }, []);

  const resolvedTokens = useMemo(() => {
    return resolveTokens(seedColor, isDark, preset, colorSpace);
  }, [seedColor, isDark, preset, colorSpace]);

  // Derive the base URL after hydration to avoid SSR/client mismatch.
  // During SSR and the first client render we use the production origin so
  // the generated YAML comment is deterministic; once mounted we switch to
  // the real window.location so localhost / preview deploys are reflected.
  const [baseUrl, setBaseUrl] = useState('https://justui.vercel.app/en/studio');
  useEffect(() => {
    setBaseUrl(window.location.href.split('?')[0] ?? window.location.href);
  }, []);

  const shareUrl = useMemo(() => {
    return buildShareUrl(baseUrl, {
      seedColor,
      isDark,
      preset,
      colorSpace,
    });
  }, [baseUrl, seedColor, isDark, preset, colorSpace]);

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
