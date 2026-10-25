import Link from 'next/link';
import { ArrowUpRight } from 'lucide-react';
import { CopyGate } from '@/components/molecules/copy-gate';
import { LivePart } from '@/components/molecules/live-part';
import { KitPart } from '@/components/runner-kit/kit-part';
import { cn } from '@/lib/cn';
import { isFlutterScene } from '@/lib/flutter-bridge';
import { formatMessage } from '@/lib/format-message';
import { localizedHref } from '@/lib/i18n';
import { isWidePart } from '@/lib/part-groups';
import { partCode } from '@/lib/parts';
import type { PartCellProps } from './parts-index.types';
import { DEFAULT_STAGE, STAGE_HEIGHTS } from './stage-heights';

/** One part on its runner: the gate that copies its add command, a link to
 *  its docs and its demo, live when the bridge has its scene. */
export function PartCell({ slug, copy }: PartCellProps) {
  const command = `justui add ${slug}`;
  const part = <KitPart slug={slug} t={copy.kit} uid={`ix-${slug}`} />;
  return (
    <li
      className={cn(
        'border-ip-border-control mt-[-1.5px] flex min-w-0 grow flex-col items-start border-t-[1.5px] px-3.5 pb-5.5 sm:px-5 sm:pb-7',
        // One column on phones. Narrow cells keep 240 px for the scene and
        // wide ones 300 px (apps/showcase stage_heights_test.dart).
        isWidePart(slug) ? 'basis-full sm:basis-85' : 'basis-full sm:basis-70'
      )}
    >
      <div className="flex w-full items-start justify-between gap-2">
        <CopyGate
          code={partCode(slug)}
          name={slug}
          text={command}
          label={formatMessage(copy.page.copyPart, { name: slug })}
          copiedText={copy.copied}
        />
        <Link
          href={localizedHref(copy.lang, `/docs/components/${slug}`)}
          aria-label={formatMessage(copy.page.openDocs, { name: slug })}
          className="text-ip-text-secondary hover:bg-ip-hover hover:text-ip-text-primary mt-0.75 flex size-6.5 shrink-0 items-center justify-center rounded-[6px]"
        >
          <ArrowUpRight size={14} aria-hidden="true" />
        </Link>
      </div>
      <div
        className={cn(
          // A column, so the live part can grow to the stage's min height
          // (a row would only stretch it to its fallback's height).
          'flex w-full flex-1 flex-col items-start justify-center pt-2',
          STAGE_HEIGHTS[slug] ?? DEFAULT_STAGE
        )}
      >
        {isFlutterScene(slug) ? (
          <LivePart
            scene={slug}
            lang={copy.lang}
            className="w-full flex-1 self-stretch"
          >
            {part}
          </LivePart>
        ) : (
          part
        )}
      </div>
    </li>
  );
}
