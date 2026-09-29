import { cn } from '@/lib/cn';
import { getHomepageDictionary } from '@/lib/homepage-translations';
import { ContrastDemo } from './contrast-demo';

interface WhatYouGetProps {
  lang?: string;
  className?: string;
}

const card =
  'bg-card border-border flex flex-col gap-4 rounded-(--just-radius-lg) border-(length:--just-border-width) p-6 shadow-sm';

/** A card that is always rendered with a fixed preset, whatever the page uses. */
function PresetSample({
  name,
  scope,
}: {
  name: string;
  scope: 'preset-default' | 'theme-neobrutalism';
}) {
  return (
    <div
      className={cn(
        scope,
        'bg-background text-foreground border-border flex flex-col items-start gap-3 rounded-(--just-radius-md) border-(length:--just-border-width) p-3.5',
        scope === 'theme-neobrutalism' && 'shadow-md'
      )}
    >
      <span className="text-muted font-mono text-xs">{name}</span>
      <span className="bg-accent text-accent-foreground border-border inline-flex h-8 items-center rounded-(--just-radius-md) border-(length:--just-border-width) px-3.5 text-[13px] font-medium shadow-sm">
        Button
      </span>
      <span className="bg-card text-muted border-border inline-flex h-8 w-full items-center rounded-(--just-radius-md) border-(length:--just-border-width) px-2.5 font-mono text-xs shadow-sm">
        Input
      </span>
    </div>
  );
}

export function WhatYouGet({ lang = 'en', className }: WhatYouGetProps) {
  const t = getHomepageDictionary(lang);

  return (
    <section className={cn('flex flex-col', className)}>
      <h2 className="text-foreground text-3xl font-medium tracking-tight">
        {t.wygHeading}
      </h2>
      <p className="text-secondary mt-3 max-w-xl text-base leading-relaxed">
        {t.wygDescription}
      </p>

      <div className="mt-12 grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        <article className={card}>
          <div>
            <span className="text-accent-text font-mono text-xs">01</span>
            <h3 className="text-foreground mt-1.5 text-lg font-medium">
              {t.wygCard1Title}
            </h3>
            <p className="text-secondary mt-2 text-sm leading-relaxed">
              {t.wygCard1Desc}
            </p>
          </div>
          <pre className="border-border bg-background text-foreground overflow-x-auto rounded-(--just-radius-md) border p-3.5 font-mono text-[12.5px] leading-7">
            <code>
              {'$ justui add button card\n'}
              <span className="text-muted">
                {'lib/\n|-- theme/just_theme.dart\n\\-- ui/\n'}
              </span>
              <span className="text-accent-text">
                {'   |-- just_button.dart\n   \\-- just_card.dart\n'}
              </span>
              <span className="text-muted">{'pubspec.yaml  (unchanged)'}</span>
            </code>
          </pre>
        </article>

        <article className={card}>
          <div>
            <span className="text-accent-text font-mono text-xs">02</span>
            <h3 className="text-foreground mt-1.5 text-lg font-medium">
              {t.wygCard2Title}
            </h3>
            <p className="text-secondary mt-2 text-sm leading-relaxed">
              {t.wygCard2Desc}
            </p>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <PresetSample name="default" scope="preset-default" />
            <PresetSample name="neobrutalism" scope="theme-neobrutalism" />
          </div>
        </article>

        <article className={card}>
          <div>
            <span className="text-accent-text font-mono text-xs">03</span>
            <h3 className="text-foreground mt-1.5 text-lg font-medium">
              {t.wygCard3Title}
            </h3>
            <p className="text-secondary mt-2 text-sm leading-relaxed">
              {t.wygCard3Desc}
            </p>
          </div>
          <ContrastDemo />
        </article>
      </div>
    </section>
  );
}
