'use client';

import { createContext, useContext, useEffect, useRef, useState } from 'react';

import { type JustUIPreset, DEFAULT_PRESET, isPreset } from '@/lib/presets';

export type { JustUIPreset };

export const PRESET_STORAGE_KEY = 'justui-preset';

interface PresetContextValue {
  preset: JustUIPreset;
  setPreset: (preset: JustUIPreset) => void;
}

const PresetContext = createContext<PresetContextValue>({
  preset: DEFAULT_PRESET,
  setPreset: () => {},
});

/**
 * Holds the visitor's preset choice and persists it. The choice is never
 * applied to `<html>` or `<body>`: only stage regions (landing runner parts,
 * docs demos) apply it, through `presetScopeClass()`, so the page chrome
 * looks the same in every preset.
 */
export function PresetProvider({ children }: { children: React.ReactNode }) {
  const [preset, setPresetState] = useState<JustUIPreset>(DEFAULT_PRESET);
  const [mounted, setMounted] = useState(false);
  // Set when a child picks a preset before this provider has read storage
  // (child effects run first). That choice must win over the stored one.
  const chosenRef = useRef(false);

  useEffect(() => {
    // Read on mount to avoid an SSR mismatch. Storage can throw (private
    // browsing, blocked site data, embedded webviews); the default preset
    // is then kept, which is safe.
    try {
      const stored = localStorage.getItem(PRESET_STORAGE_KEY);
      if (!chosenRef.current && isPreset(stored)) {
        setPresetState(stored);
      }
    } catch {
      // Intentional fallback: keep the default preset.
    }
    setMounted(true);
  }, []);

  useEffect(() => {
    if (!mounted) return;
    try {
      localStorage.setItem(PRESET_STORAGE_KEY, preset);
    } catch {
      // Intentional fallback: the preset still applies for this session.
    }
  }, [preset, mounted]);

  function setPreset(next: JustUIPreset) {
    chosenRef.current = true;
    setPresetState(next);
  }

  return (
    <PresetContext.Provider value={{ preset, setPreset }}>
      {children}
    </PresetContext.Provider>
  );
}

export function usePreset() {
  return useContext(PresetContext);
}
