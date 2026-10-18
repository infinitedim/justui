import Link from 'next/link';
import { CopyControl } from '@/components/molecules/copy-control';
import { getComponentsPageDictionary } from '@/lib/components-page-translations';
import { formatMessage } from '@/lib/format-message';
import { localizedHref } from '@/lib/i18n';
import { PART_COUNT, PART_SLUGS, partCode } from '@/lib/parts';
import { getSiteDictionary } from '@/lib/site-translations';
import type { PartsIndexProps } from './parts-index.types';

/**
 * Every public part with its runner number, as the components page. Each
 * row opens the part's docs; the button at its end copies
 * `justui add <part>`. The nav and footer "Components" links land here.
 */
export function PartsIndex({ lang }: PartsIndexProps) {
  const t = getComponentsPageDictionary(lang);
  const site = getSiteDictionary(lang);
  return (
    <div className="mx-auto max-w-360 px-[clamp(20px,4vw,48px)] pt-[clamp(40px,5vw,64px)] pb-[clamp(72px,9vw,128px)]">
      <div className="flex flex-wrap items-end justify-between gap-x-12 gap-y-4">
        <h1 className="text-[clamp(32px,4.2vw,56px)] leading-[1.06] font-bold tracking-[-0.03em]">
          {t.title}
        </h1>
        <p className="text-ip-text-secondary max-w-[50ch] text-[17px] leading-[1.6]">
          {formatMessage(t.lead, { count: PART_COUNT })}
        </p>
      </div>
      {/* 256px fits the longest slug (date-range-picker) beside the copy
          button, so no part name is cut off. */}
      <ul className="border-ip-border-subtle mt-[clamp(32px,4vw,48px)] grid grid-cols-[repeat(auto-fill,minmax(256px,1fr))] border-t">
        {PART_SLUGS.map((slug) => (
          <li
            key={slug}
            className="border-ip-border-subtle flex items-center border-b pr-1.5"
          >
            <Link
              href={localizedHref(lang, `/docs/components/${slug}`)}
              className="text-ip-text-primary hover:bg-ip-hover flex h-12 min-w-0 flex-1 items-center gap-3 px-3"
            >
              <span className="text-ip-text-secondary w-8.5 shrink-0 text-[13px] font-bold tabular-nums">
                {partCode(slug)}
              </span>{' '}
              <code className="min-w-0 flex-1 truncate font-mono text-sm">
                {slug}
              </code>
            </Link>
            <CopyControl
              text={`justui add ${slug}`}
              label={formatMessage(t.copyPart, { name: slug })}
              copyText={site.copy}
              copiedText={site.copied}
            />
          </li>
        ))}
      </ul>
    </div>
  );
}
