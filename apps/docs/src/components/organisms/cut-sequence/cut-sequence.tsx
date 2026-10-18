'use client';

// Client leaf: scroll scrubs the cut; reduced motion gets before/after.
import { useId, useRef } from 'react';
import { SegmentedPill } from '@/components/molecules/segmented-pill';
import { cn } from '@/lib/cn';
import { formatMessage } from '@/lib/format-message';
import { getKitDictionary } from '@/lib/kit-translations';
import { getLandingDictionary } from '@/lib/landing-translations';
import { partDir, partFiles, partSharedDeps } from '@/lib/parts';
import { CutHeader } from './cut-header';
import { CutStage } from './cut-stage';
import { useCutMotion } from './use-cut-motion';
import type { CutSequenceProps } from './cut-sequence.types';

/** The part the sequence cuts (part 07). */
const PART = 'button';

/**
 * "Cut one part. One file lands.": part 07 leaves the runner and lands in
 * the project as its own files plus the shared ones. File names and counts
 * come from the generated registry data.
 */
export function CutSequence({ lang }: CutSequenceProps) {
  const t = getLandingDictionary(lang);
  const headingId = useId();
  const section = useRef<HTMLElement | null>(null);
  const sticky = useRef<HTMLDivElement | null>(null);
  const content = useRef<HTMLDivElement | null>(null);
  const stage = useRef<HTMLDivElement | null>(null);
  const files = partFiles(PART);
  const { mode, after, setAfter } = useCutMotion(
    { section, sticky, content, stage },
    Math.max(0, files.length - 1)
  );
  const pinned = mode === 'pinned';
  return (
    <section
      ref={section}
      aria-labelledby={headingId}
      className={cn(
        'border-ip-border-subtle relative border-t',
        pinned && 'h-[280vh]'
      )}
    >
      <div
        ref={sticky}
        data-raster-sticky={pinned ? '' : undefined}
        className={
          pinned
            ? 'sticky top-16 h-[calc(100vh-64px)] overflow-hidden'
            : 'relative'
        }
      >
        <div className="mx-auto flex h-full max-w-[1440px] flex-col justify-center px-[clamp(20px,4vw,48px)] py-10">
          <div
            ref={content}
            className="flex flex-col gap-[clamp(28px,3.5vw,48px)]"
          >
            <CutHeader
              id={headingId}
              title={t.cutTitle}
              lead={t.cutLead}
              command={`justui add ${PART}`}
              tail={formatMessage(t.cutTail, { dir: `${partDir(PART)}/` })}
              control={
                mode === 'stepped' ? (
                  <SegmentedPill
                    kind="toggle"
                    label={t.cutTitle}
                    options={[
                      { value: 'before', label: t.before },
                      { value: 'after', label: t.after },
                    ]}
                    value={after ? 'after' : 'before'}
                    onChange={(value) => setAfter(value === 'after')}
                  />
                ) : null
              }
            />
            <CutStage
              stageRef={stage}
              part={PART}
              files={files}
              shared={partSharedDeps(PART).length}
              t={t}
              kit={getKitDictionary(lang)}
            />
          </div>
        </div>
      </div>
    </section>
  );
}
