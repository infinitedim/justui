import { Gate } from '@/components/atoms/gate';
import { CopyControl } from '@/components/molecules/copy-control';
import { KitPart } from '@/components/runner-kit/kit-part';
import { partCode } from '@/lib/parts';
import type { NearestPartProps } from './not-found-runner.types';

/** A real part close to the missing one: its gate, live demo and command. */
export function NearestPart({ slug, kit, site }: NearestPartProps) {
  const command = `justui add ${slug}`;
  return (
    <div className="flex min-w-0 flex-[1_1_220px] flex-col items-start gap-3.5">
      <Gate
        code={partCode(slug)}
        name={slug}
        selected={false}
        className="ml-5"
      />
      <div className="flex min-h-28 w-full flex-1 items-center">
        <KitPart slug={slug} t={kit} uid={`nf-${slug}`} />
      </div>
      <div className="bg-ip-sunken flex h-10 w-full max-w-70 items-center gap-1 rounded-[10px] pr-1 pl-3">
        <code className="text-ip-text-primary min-w-0 flex-1 truncate font-mono text-[13px]">
          {command}
        </code>
        <CopyControl
          text={command}
          label={`${site.copy} ${command}`}
          copyText={site.copy}
          copiedText={site.copied}
          className="size-8"
        />
      </div>
    </div>
  );
}
