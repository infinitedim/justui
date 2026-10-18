'use client';

// Client leaf: the one static 404 learns the requested path, its locale
// and the lookup query in the browser.
import { useEffect, useState } from 'react';
import { HtmlLang } from '@/components/html-lang';
import { SiteNav } from '@/components/organisms/site-nav';
import { InkPaperPage } from '@/components/templates/ink-paper-page';
import { localeFromPath, switchLocalePath } from '@/lib/i18n';
import { getKitDictionary } from '@/lib/kit-translations';
import { getNotFoundDictionary } from '@/lib/not-found-translations';
import { nearestParts, normalizePartQuery } from '@/lib/part-lookup';
import { getSiteDictionary } from '@/lib/site-translations';
import { useRequestPath } from '@/lib/use-request-path';
import { NotFoundExits, NotFoundStatement } from './not-found-statement';
import { PartLookupField } from './part-lookup-field';
import { RunnerField } from './runner-field';

/**
 * The 404 for every unknown URL. One static page serves them all, so the
 * locale (`/id/...`) and the lookup query (`/en/buton` -> `buton`) come
 * from the path once the page runs in the browser; the prerendered HTML is
 * the English page with the default nearest parts.
 */
export function NotFoundRunner() {
  const path = useRequestPath();
  const lang = localeFromPath(path);
  const t = getNotFoundDictionary(lang);
  const [typed, setTyped] = useState<string | null>(null);
  const query = typed ?? normalizePartQuery(path);
  useEffect(() => {
    // The page is prerendered once in English; swap the title text in place
    // so the layout's title template stays the single source.
    const english = getNotFoundDictionary('en').metaTitle;
    document.title = document.title.replace(english, t.metaTitle);
  }, [t.metaTitle]);
  const localeHrefs = {
    en: switchLocalePath(path, 'en'),
    id: switchLocalePath(path, 'id'),
  };
  return (
    <InkPaperPage
      nav={
        <SiteNav
          lang={lang}
          localeHrefs={localeHrefs}
          showSearch={false}
          prefetchLocales={false}
        />
      }
      footer={null}
    >
      <HtmlLang lang={lang} />
      <div className="mx-auto max-w-[1440px] px-[clamp(20px,4vw,48px)] pt-[clamp(40px,5vw,64px)] pb-[clamp(48px,6vw,80px)]">
        <RunnerField
          parts={nearestParts(normalizePartQuery(query))}
          t={t}
          kit={getKitDictionary(lang)}
          site={getSiteDictionary(lang)}
        />
        <div className="mt-[clamp(36px,4.5vw,64px)] flex flex-wrap items-end justify-between gap-x-16 gap-y-8">
          <NotFoundStatement path={path} t={t} />
          <div className="flex w-full max-w-[420px] min-w-0 flex-[0_1_420px] flex-col gap-4">
            <PartLookupField value={query} onChange={setTyped} t={t} />
            <NotFoundExits lang={lang} t={t} />
          </div>
        </div>
      </div>
    </InkPaperPage>
  );
}
