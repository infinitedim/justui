import { Scissors } from 'lucide-react';
import { CopyControl } from '@/components/molecules/copy-control';
import { partCode, partDir, partMainFile } from '@/lib/parts';
import type { SiteDictionary } from '@/lib/site-translations';

interface CutBarProps {
  cut: string;
  site: SiteDictionary;
  landsAs: string;
}

/** The command that cuts the selected part and where its file lands. */
export function CutBar({ cut, site, landsAs }: CutBarProps) {
  const command = `justui add ${cut}`;
  return (
    <div className="bg-ip-sunken flex min-h-14 flex-wrap items-center gap-x-3.5 gap-y-2.5 rounded-[12px] py-2 pr-2 pl-[18px]">
      <Scissors size={16} aria-hidden="true" />
      <span className="text-sm font-bold whitespace-nowrap">
        {partCode(cut)}
      </span>
      <code className="font-mono text-sm whitespace-nowrap">{command}</code>
      <CopyControl
        text={command}
        label={site.copyCommand}
        copyText={site.copy}
        copiedText={site.copied}
      />
      <span className="ml-auto flex min-w-0 flex-wrap items-center gap-x-2 gap-y-1 pr-2.5">
        <span className="text-ip-text-tertiary text-[13px] whitespace-nowrap">
          {landsAs}
        </span>
        <code className="font-mono text-[13px] [overflow-wrap:anywhere]">
          {`${partDir(cut)}/${partMainFile(cut)}`}
        </code>
      </span>
    </div>
  );
}
