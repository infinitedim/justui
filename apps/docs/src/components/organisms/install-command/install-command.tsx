'use client';

// Client leaf: the OS tab is shared state (hero and install band).
import { Fragment } from 'react';
import { CopyControl } from '@/components/molecules/copy-control';
import { SegmentedPill } from '@/components/molecules/segmented-pill';
import { useInstallOs } from '@/components/providers/install-os-provider';
import { cn } from '@/lib/cn';
import {
  INSTALL_COMMANDS,
  INSTALL_PLATFORM_LABELS,
  INSTALL_PLATFORMS,
  commandSegments,
} from '@/lib/install-commands';
import { getSiteDictionary } from '@/lib/site-translations';
import type { InstallCommandProps } from './install-command.types';

const options = INSTALL_PLATFORMS.map((value) => ({
  value,
  label: INSTALL_PLATFORM_LABELS[value],
}));

/**
 * OS tabs above the one-line installer. The command breaks only at `/`
 * and spaces, so the full URL is always visible.
 */
export function InstallCommand({
  lang,
  size = 'hero',
  className,
}: InstallCommandProps) {
  const t = getSiteDictionary(lang);
  const { platform, setPlatform } = useInstallOs();
  const command = INSTALL_COMMANDS[platform];
  return (
    <div className={cn('flex flex-col gap-3', className)}>
      <SegmentedPill
        label={t.os}
        options={options}
        value={platform}
        onChange={setPlatform}
      />
      <div
        role="tabpanel"
        aria-label={INSTALL_PLATFORM_LABELS[platform]}
        className="bg-ip-sunken flex min-h-14 items-center gap-3 rounded-[12px] py-2 pr-2 pl-[18px]"
      >
        <code className="text-ip-text-primary min-w-0 flex-1 font-mono text-sm leading-[22px]">
          {commandSegments(command).map((segment, index) => (
            <Fragment key={`${segment}-${index}`}>
              {index > 0 ? <wbr /> : null}
              <span className="whitespace-pre">{segment}</span>
            </Fragment>
          ))}
        </code>
        <CopyControl
          text={command}
          label={t.copyInstall}
          copyText={t.copy}
          copiedText={t.copied}
          variant={size === 'hero' ? 'labelled' : 'boxed'}
        />
      </div>
    </div>
  );
}
