'use client';

import { useState } from 'react';
import { cn } from '@/lib/cn';
import { CopyButton } from '@/components/molecules/copy-button';
import { getHomepageDictionary } from '@/lib/homepage-translations';
import type { InstallPlatform, InstallTabsProps } from './install-tabs.types';

interface PlatformMeta {
  id: InstallPlatform;
  defaultLabel: string;
  command: string;
}

const PLATFORMS: readonly PlatformMeta[] = [
  {
    id: 'curl',
    defaultLabel: 'macOS / Linux',
    command: 'curl -fsSL https://justui.dev/install.sh | bash',
  },
  {
    id: 'powershell',
    defaultLabel: 'Windows',
    command: 'irm https://justui.dev/install.ps1 | iex',
  },
  {
    id: 'cargo',
    defaultLabel: 'Cargo',
    command: 'cargo install justui_cli',
  },
] as const;

export function InstallTabs({ lang = 'en', className }: InstallTabsProps) {
  const [activePlatform, setActivePlatform] = useState<InstallPlatform>('curl');
  const t = getHomepageDictionary(lang);

  const getLabel = (platform: InstallPlatform, fallback: string): string => {
    if (platform === 'curl') return t.installTabCurl || fallback;
    if (platform === 'powershell') return t.installTabPowershell || fallback;
    if (platform === 'cargo') return t.installTabCargo || fallback;
    return fallback;
  };

  const activeMeta =
    PLATFORMS.find((p) => p.id === activePlatform) ?? PLATFORMS[0];

  return (
    <div
      className={cn('mx-auto flex w-full max-w-xl flex-col gap-2', className)}
    >
      <div
        role="tablist"
        aria-label="Installation platform"
        className="border-border flex items-center gap-1 border-b pb-1"
      >
        {PLATFORMS.map((platform) => {
          const isSelected = activePlatform === platform.id;
          return (
            <button
              key={platform.id}
              id={`install-tab-${platform.id}`}
              type="button"
              role="tab"
              aria-selected={isSelected}
              aria-controls={`install-tabpanel-${platform.id}`}
              onClick={() => setActivePlatform(platform.id)}
              className={cn(
                'rounded-(--just-radius-md) px-3 py-1.5 font-mono text-xs transition-colors',
                'border-(length:--just-border-width)',
                isSelected
                  ? 'border-border bg-accent text-foreground shadow-solid font-medium'
                  : 'border-transparent text-muted hover:border-border hover:text-foreground'
              )}
            >
              {getLabel(platform.id, platform.defaultLabel)}
            </button>  
          );
        })}
      </div>

      <div
        id={`install-tabpanel-${activePlatform}`}
        role="tabpanel"
        aria-labelledby={`install-tab-${activePlatform}`}
        className="border-border bg-card shadow-solid rounded-(--just-radius-md) flex items-center justify-between gap-3 border-(length:--just-border-width) p-3"
      >
        <code className="text-foreground overflow-x-auto font-mono text-xs whitespace-nowrap select-all sm:text-sm">
          {activeMeta.command}
        </code>
        <CopyButton
          text={activeMeta.command}
          label={`Copy ${activeMeta.command}`}
          className="shrink-0"
        />
      </div>
    </div>
  );
}
