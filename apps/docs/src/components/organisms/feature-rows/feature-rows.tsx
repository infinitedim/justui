import { cn } from '@/lib/cn';
import { getKitDictionary } from '@/lib/kit-translations';
import { getLandingDictionary } from '@/lib/landing-translations';
import { TextWipe } from './text-wipe';
import { TokenTable } from './token-table';
import type { FeatureRowProps, FeatureRowsProps } from './feature-rows.types';

/** Commands from packages/cli/src/main.rs (`add --dry-run`, `diff`). */
const PREVIEW_COMMANDS = ['justui add button --dry-run', 'justui diff button'];

function FeatureRow({ title, body, last = false, children }: FeatureRowProps) {
  return (
    <div
      className={cn(
        'border-ip-border-subtle flex flex-wrap gap-x-12 gap-y-4 border-t py-8',
        last && 'border-b'
      )}
    >
      <h3 className="flex-[1_1_240px] text-[22px] leading-[1.3] font-bold tracking-[-0.01em] text-balance">
        {title}
      </h3>
      <p className="text-ip-text-secondary max-w-[62ch] flex-[2_1_320px] text-base leading-[1.65]">
        {body}
      </p>
      <div className="min-w-0 flex-[1_1_300px]">{children}</div>
    </div>
  );
}

/** "What you actually get": source, tokens, and text on any surface. */
export function FeatureRows({ lang }: FeatureRowsProps) {
  const t = getLandingDictionary(lang);
  const kit = getKitDictionary(lang);
  const notes = [t.dryRunNote, t.diffNote];
  return (
    <section aria-labelledby="landing-features">
      <div className="mx-auto max-w-[1440px] px-[clamp(20px,4vw,48px)] py-[clamp(72px,9vw,128px)]">
        <h2
          id="landing-features"
          className="text-[clamp(32px,4.2vw,56px)] leading-[1.06] font-bold tracking-[-0.03em]"
        >
          {t.featuresTitle}
        </h2>
        <div className="mt-[clamp(32px,4vw,48px)] flex flex-col">
          <FeatureRow title={t.sourceTitle} body={t.sourceBody}>
            <div className="bg-ip-sunken flex flex-col gap-3 rounded-[12px] px-[18px] py-4">
              {PREVIEW_COMMANDS.map((command, index) => (
                <div key={command} className="flex flex-col gap-0.5">
                  <code className="text-ip-text-primary font-mono text-[13px]">
                    {command}
                  </code>
                  <span className="text-ip-text-secondary text-[13px]">
                    {notes[index]}
                  </span>
                </div>
              ))}
            </div>
          </FeatureRow>
          <FeatureRow title={t.tokensTitle} body={t.tokensBody}>
            <TokenTable tokenColumn={t.tokenColumn} />
          </FeatureRow>
          <FeatureRow title={t.textTitle} body={t.textBody} last>
            <TextWipe
              onPaper={t.onPaper}
              onInk={t.onInk}
              save={kit.save}
              saveDraft={kit.saveDraft}
            />
          </FeatureRow>
        </div>
      </div>
    </section>
  );
}
