import { CopyControl } from '@/components/molecules/copy-control';
import { formatMessage } from '@/lib/format-message';
import { getLandingDictionary } from '@/lib/landing-translations';
import { PART_COUNT, PART_SLUGS, partCode } from '@/lib/parts';
import { getSiteDictionary } from '@/lib/site-translations';
import type { PartsIndexProps } from './parts-index.types';

/**
 * Every public part with its runner number. Each row copies
 * `justui add <part>`. The nav and footer "Components" links land here.
 */
export function PartsIndex({ lang }: PartsIndexProps) {
  const t = getLandingDictionary(lang);
  const site = getSiteDictionary(lang);
  return (
    <section
      id="parts"
      aria-labelledby="landing-parts"
      className="scroll-mt-16"
    >
      <div className="mx-auto max-w-[1440px] px-[clamp(20px,4vw,48px)] pb-[clamp(72px,9vw,128px)]">
        <div className="flex flex-wrap items-end justify-between gap-x-12 gap-y-4">
          <h2
            id="landing-parts"
            className="text-[clamp(32px,4.2vw,56px)] leading-[1.06] font-bold tracking-[-0.03em]"
          >
            {t.partsTitle}
          </h2>
          <p className="text-ip-text-secondary max-w-[50ch] text-[17px] leading-[1.6]">
            {formatMessage(t.partsLead, { count: PART_COUNT })}
          </p>
        </div>
        <ul className="border-ip-border-subtle mt-[clamp(32px,4vw,48px)] grid grid-cols-[repeat(auto-fill,minmax(200px,1fr))] border-t">
          {PART_SLUGS.map((slug) => (
            <li key={slug} className="border-ip-border-subtle border-b">
              <CopyControl
                variant="row"
                text={`justui add ${slug}`}
                label={formatMessage(t.copyPart, { name: slug })}
                copyText={site.copy}
                copiedText={site.copied}
              >
                <span className="flex min-w-0 flex-1 items-center gap-3">
                  <span className="text-ip-text-secondary w-[34px] shrink-0 text-[13px] font-bold tabular-nums">
                    {partCode(slug)}
                  </span>
                  <code className="min-w-0 flex-1 truncate font-mono text-sm">
                    {slug}
                  </code>
                </span>
              </CopyControl>
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}
