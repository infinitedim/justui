import { getComponentsPageDictionary } from '@/lib/components-page-translations';
import { formatMessage } from '@/lib/format-message';
import { getKitDictionary } from '@/lib/kit-translations';
import { PART_GROUPS } from '@/lib/part-groups';
import { PART_COUNT } from '@/lib/parts';
import { getSiteDictionary } from '@/lib/site-translations';
import { PartRunner } from './part-runner';
import type { PartCopy, PartsIndexProps } from './parts-index.types';

/**
 * The components page (landing v3 "Parts index"): every public part on six
 * runners, live in the visitor's preset. Each label copies
 * `justui add <part>`; the arrow beside it opens the part's docs. The nav
 * and footer "Components" links land here.
 */
export function PartsIndex({ lang }: PartsIndexProps) {
  const page = getComponentsPageDictionary(lang);
  const copy: PartCopy = {
    lang,
    page,
    kit: getKitDictionary(lang),
    copied: getSiteDictionary(lang).copied,
  };
  return (
    <div className="mx-auto max-w-360 px-[clamp(20px,4vw,48px)] pt-[clamp(40px,5vw,64px)] pb-[clamp(72px,9vw,128px)]">
      <div className="flex max-w-[64ch] flex-col gap-4">
        <h1 className="max-w-[20ch] text-[clamp(32px,4.2vw,56px)] leading-[1.06] font-bold tracking-[-0.03em] text-balance">
          {page.title}
        </h1>
        <p className="text-ip-text-secondary text-[17px] leading-[1.6] text-pretty">
          {formatMessage(page.lead, { count: PART_COUNT })}
        </p>
      </div>
      <div className="mt-[clamp(40px,5vw,64px)] flex flex-col gap-10">
        {PART_GROUPS.map((group) => (
          <PartRunner key={group.id} group={group} copy={copy} />
        ))}
      </div>
    </div>
  );
}
