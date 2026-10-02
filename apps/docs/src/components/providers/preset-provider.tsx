'use client';

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useRef,
  useState,
} from 'react';

import {
  type JustUIPreset,
  DEFAULT_PRESET,
} from '@/lib/presets';

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
  // Set when a child picks a preset before this provider has read storage
  // (child effects run first), e.g. the studio applying ?preset= from a
  // share link. That choice must win over the stored one.
  const chosenRef = useRef(false);

  useEffect(() => {
    // Read from localStorage on mount -- avoid SSR mismatch. Storage access
    // can throw (private browsing, blocked cookies/site data, some embedded
    // webviews); fall back to the default preset rather than crashing.
    try {
      const stored = localStorage.getItem(STORAGE_KEY) as JustUIPreset | null;
      if (
        !chosenRef.current &&
        (stored === 'neobrutalism' || stored === 'default')
      ) {
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
    chosenRef.current = true;
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
