'use client';

// Client leaf: the step rules draw in order as the band scrolls in.
import { useLayoutEffect, useRef } from 'react';
import { FilePlus, Folder } from 'lucide-react';
import { InstallCommand } from '@/components/organisms/install-command';
import { formatMessage } from '@/lib/format-message';
import { getLandingDictionary } from '@/lib/landing-translations';
import { partDir, partFiles, partMainFile } from '@/lib/parts';
import { clamp01, expoOut, viewportProgress } from '@/lib/scroll-progress';
import { getSiteDictionary } from '@/lib/site-translations';
import { useReducedMotion } from '@/lib/use-reduced-motion';
import { useScrollFrame } from '@/lib/use-scroll-frame';
import { CommandBox, InstallStep, WrittenFiles } from './install-step';
import type { InstallStepsProps } from './install-steps.types';

/** What `justui init` writes (packages/cli: config.rs and init.rs). */
const INIT_WRITES = ['justui.config.yaml', 'lib/core/theme/just_theme.dart'];

const PART = 'button';
const path =
  'text-ip-text-primary flex items-center gap-2 font-mono text-[13px] leading-6';
const icon = { size: 14, 'aria-hidden': true, className: 'shrink-0' } as const;

/** Draws each step's rule in turn; `done` shows the finished state. */
function drawRules(list: HTMLElement | null, done: boolean) {
  if (!list) return;
  const rules = list.querySelectorAll<HTMLElement>('[data-step-rule]');
  const top = list.getBoundingClientRect().top;
  const p = done ? 1 : viewportProgress(top, window.innerHeight, 0.9, 0.55);
  rules.forEach((rule, index) => {
    const v = clamp01(p * rules.length - index);
    rule.style.transform = `scaleX(${done ? 1 : expoOut(v)})`;
    const number =
      rule.parentElement?.querySelector<HTMLElement>('[data-step-number]');
    if (!number) return;
    number.style.color =
      v >= 1 ? 'var(--ip-text-primary)' : 'var(--ip-text-tertiary)';
    number.style.transition = 'color 200ms ease-out';
  });
}

/** "Three steps, in order." on the inverted band. */
export function InstallSteps({ lang }: InstallStepsProps) {
  const t = getLandingDictionary(lang);
  const site = getSiteDictionary(lang);
  const reduced = useReducedMotion();
  const steps = useRef<HTMLOListElement | null>(null);
  useScrollFrame(!reduced, () => drawRules(steps.current, false));
  useLayoutEffect(() => {
    if (reduced) drawRules(steps.current, true);
  }, [reduced]);
  const copy = {
    copyLabel: site.copyCommand,
    copyText: site.copy,
    copiedText: site.copied,
  };
  return (
    <section
      aria-labelledby="landing-install"
      className="ink-paper-invert text-ip-text-primary bg-(--ip-band)"
    >
      <div className="mx-auto max-w-[1440px] px-[clamp(20px,4vw,48px)] py-[clamp(72px,9vw,128px)]">
        <h2
          id="landing-install"
          className="text-[clamp(32px,4.2vw,56px)] leading-[1.06] font-bold tracking-[-0.03em]"
        >
          {t.installTitle}
        </h2>
        <ol
          ref={steps}
          className="mt-[clamp(32px,4vw,48px)] grid grid-cols-[repeat(auto-fit,minmax(280px,1fr))] gap-x-8 gap-y-10"
        >
          <InstallStep number={1} title={t.stepInstall}>
            <InstallCommand lang={lang} size="compact" />
          </InstallStep>
          <InstallStep number={2} title={t.stepInit}>
            <CommandBox command="justui init" {...copy} />
            <WrittenFiles label={t.stepInitWrites}>
              {INIT_WRITES.map((file) => (
                <code key={file} className={path}>
                  <FilePlus {...icon} />
                  {file}
                </code>
              ))}
            </WrittenFiles>
          </InstallStep>
          <InstallStep number={3} title={t.stepAdd}>
            <CommandBox command={`justui add ${PART}`} {...copy} />
            <WrittenFiles label={t.stepAddLands}>
              <code className={path}>
                <Folder {...icon} />
                {`${partDir(PART)}/`}
              </code>
              <code className="text-ip-text-secondary pl-[22px] font-mono text-[13px]/6">
                {partMainFile(PART)}
              </code>
              <code className="text-ip-text-secondary pl-[22px] font-mono text-[13px]/6">
                {formatMessage(t.moreFiles, {
                  count: partFiles(PART).length - 1,
                })}
              </code>
            </WrittenFiles>
          </InstallStep>
        </ol>
      </div>
    </section>
  );
}
