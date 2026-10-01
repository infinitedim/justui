'use client';

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useRef,
  useState,
} from 'react';
import { DEFAULT_PRESET, isPreset, type JustUIPreset } from '@/lib/presets';

export type { JustUIPreset };

const STORAGE_KEY = 'justui-preset';

interface PresetContextValue {
  preset: JustUIPreset;
  setPreset: (preset: JustUIPreset) => void;
}

const PresetContext = createContext<PresetContextValue>({
  preset: DEFAULT_PRESET,
  setPreset: () => {},
});

export function PresetProvider({ children }: { children: React.ReactNode }) {
  const [preset, setPresetState] = useState<JustUIPreset>(DEFAULT_PRESET);
  const [mounted, setMounted] = useState(false);
  // Child effects run before this provider's mount effect. A child that sets
  // the preset on mount (the Studio applying ?preset= from a shared link)
  // must win over the stored value, so the stored value is only applied when
  // nothing chose a preset explicitly first.
  const explicitRef = useRef(false);

  useEffect(() => {
    // Read from localStorage on mount -- avoid SSR mismatch. Storage access
    // can throw (private browsing, blocked cookies/site data, some embedded
    // webviews); fall back to the default preset rather than crashing.
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      if (!explicitRef.current && isPreset(stored)) {
        setPresetState(stored);
      }
    } catch {
      // Ignore: default preset already applied.
    }
    setMounted(true);
  }, []);

  useEffect(() => {
    if (!mounted) return;
    // Apply/remove theme-neobrutalism class on <html> and <body>
    if (preset === 'neobrutalism') {
      document.documentElement.classList.add('theme-neobrutalism');
      document.body.classList.add('theme-neobrutalism');
    } else {
      document.documentElement.classList.remove('theme-neobrutalism');
      document.body.classList.remove('theme-neobrutalism');
    }
    try {
      localStorage.setItem(STORAGE_KEY, preset);
    } catch {
      // Ignore: preset still applies for this session, just isn't persisted.
    }
  }, [preset, mounted]);

  const setPreset = useCallback((next: JustUIPreset) => {
    explicitRef.current = true;
    setPresetState(next);
  }, []);

  return (
    <PresetContext.Provider value={{ preset, setPreset }}>
      {children}
    </PresetContext.Provider>
  );
}

export function usePreset() {
  return useContext(PresetContext);
}
