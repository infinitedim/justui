'use client';

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useState,
} from 'react';

export type JustUIPreset = 'default' | 'neobrutalism';

const STORAGE_KEY = 'justui-preset';
const DEFAULT_PRESET: JustUIPreset = 'default';

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

  useEffect(() => {
    // Read from localStorage on mount — avoid SSR mismatch
    const stored = localStorage.getItem(STORAGE_KEY) as JustUIPreset | null;
    if (stored === 'neobrutalism' || stored === 'default') {
      setPresetState(stored);
    }
    setMounted(true);
  }, []);

  useEffect(() => {
    if (!mounted) return;
    // Apply/remove theme-neobrutalism class on <body>
    if (preset === 'neobrutalism') {
      document.body.classList.add('theme-neobrutalism');
    } else {
      document.body.classList.remove('theme-neobrutalism');
    }
    localStorage.setItem(STORAGE_KEY, preset);
  }, [preset, mounted]);

  const setPreset = useCallback((next: JustUIPreset) => {
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
