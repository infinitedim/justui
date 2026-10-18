import { RunnerShelf } from '@/components/molecules/runner-shelf';
import { InstallCommand } from '@/components/organisms/install-command';
import { RunnerBox } from '@/components/organisms/runner-box';
import { cn } from '@/lib/cn';
import { formatMessage } from '@/lib/format-message';
import { getKitDictionary } from '@/lib/kit-translations';
import { getLandingDictionary } from '@/lib/landing-translations';
import { PART_COUNT } from '@/lib/parts';
import { getSiteDictionary } from '@/lib/site-translations';
import type { LandingHeroProps } from './landing-hero.types';

/**
 * First viewport: the headline, the working install command, the runner
 * shelf (presets) and the runner with live parts.
 */
export function LandingHero({ lang }: LandingHeroProps) {
  const t = getLandingDictionary(lang);
  const site = getSiteDictionary(lang);
  return (
    <section className="mx-auto w-full max-w-360 px-[clamp(20px,4vw,48px)] pt-[clamp(40px,6vw,64px)] pb-[clamp(64px,8vw,112px)]">
      <h1
        className={cn(
          'text-[44px] font-bold tracking-[-0.03em] text-balance min-[960px]:tracking-[-0.035em] min-[960px]:text-nowrap',
          lang === 'id'
            ? 'text-[40px] min-[960px]:text-[clamp(36px,5vw,72px)]'
            : 'min-[960px]:text-[clamp(40px,5.9vw,84px)]',
          // After the sizes: tailwind-merge drops a leading-* that a later
          // text-* size overrides.
          'leading-[1.04] min-[960px]:leading-[1.02]'
        )}
      >
        {t.heroTitle}
      </h1>
      <div className="mt-[clamp(28px,3vw,40px)] flex flex-wrap items-start gap-x-14 gap-y-12">
        <div className="flex max-w-140 min-w-0 flex-[1_1_380px] flex-col gap-8">
          <p className="text-ip-text-secondary text-lg leading-[1.6] text-pretty">
            {t.heroDescription}
          </p>
          <InstallCommand lang={lang} />
          <RunnerShelf
            heading={t.runners}
            label={site.presetLabel}
            notes={t.presetNotes}
          />
        </div>
        <div className="min-w-0 flex-[999_1_560px]">
          <RunnerBox
            lang={lang}
            kit={getKitDictionary(lang)}
            partsCount={formatMessage(t.partsCount, { count: PART_COUNT })}
            landsAs={t.landsAs}
          />
        </div>
      </div>
    </section>
  );
}
