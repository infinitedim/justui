'use client';

// Client provider: the hero and the install band share one OS choice.
import { createContext, useContext, useState, type ReactNode } from 'react';
import type { InstallPlatform } from '@/lib/install-commands';

interface InstallOsContextValue {
  platform: InstallPlatform;
  setPlatform: (platform: InstallPlatform) => void;
}

const InstallOsContext = createContext<InstallOsContextValue>({
  platform: 'unix',
  setPlatform: () => {},
});

/** Holds the install-command OS tab for every command on the landing. */
export function InstallOsProvider({ children }: { children: ReactNode }) {
  const [platform, setPlatform] = useState<InstallPlatform>('unix');
  return (
    <InstallOsContext.Provider value={{ platform, setPlatform }}>
      {children}
    </InstallOsContext.Provider>
  );
}

export function useInstallOs(): InstallOsContextValue {
  return useContext(InstallOsContext);
}
