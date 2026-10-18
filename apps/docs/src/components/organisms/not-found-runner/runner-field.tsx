import { PresetStage } from '@/components/organisms/preset-stage';
import { usePreset } from '@/components/providers';
import { formatMessage } from '@/lib/format-message';
import { PART_SLUGS, partCode } from '@/lib/parts';
import { PRESET_LABELS } from '@/lib/presets';
import { MissingSocket } from './missing-socket';
import { NearestPart } from './nearest-part';
import type { RunnerFieldProps } from './not-found-runner.types';

const range = {
  first: partCode(PART_SLUGS[0] ?? ''),
  last: partCode(PART_SLUGS.at(-1) ?? ''),
};

/**
 * The 404 runner in the visitor's preset: the empty socket for part 404
 * and the nearest real parts, live.
 */
export function RunnerField({ parts, t, kit, site }: RunnerFieldProps) {
  const { preset } = usePreset();
  return (
    <PresetStage
      animated={false}
      className="border-ip-border-control relative flex flex-col rounded-[20px] border-[1.5px]"
    >
      <div className="bg-ip-canvas absolute -top-3.75 right-6 flex h-7 items-center px-2.5">
        <span className="text-ip-text-secondary text-sm font-semibold">
          {PRESET_LABELS[preset]}
        </span>
      </div>
      <div className="flex flex-wrap items-stretch gap-x-10 gap-y-7 px-[clamp(16px,2.5vw,32px)] pb-7">
        <MissingSocket missing={t.missing} />
        {parts.map((slug) => (
          <NearestPart key={slug} slug={slug} kit={kit} site={site} />
        ))}
      </div>
      <div className="border-ip-border-control text-ip-text-secondary flex flex-wrap items-center justify-between gap-x-6 gap-y-2 border-t-[1.5px] px-[clamp(16px,2.5vw,32px)] py-3.5 text-[13px]">
        <span className="font-semibold">
          {formatMessage(t.runnerNote, range)}
        </span>
        <span>{t.nearestNote}</span>
      </div>
    </PresetStage>
  );
}
