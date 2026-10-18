'use client';

// Client leaf: tracks which part is being cut.
import { useState } from 'react';
import { PresetStage } from '@/components/organisms/preset-stage';
import { usePreset } from '@/components/providers';
import { KitButton } from '@/components/runner-kit/kit-actions';
import { KitBadge } from '@/components/runner-kit/kit-display';
import { KitInput } from '@/components/runner-kit/kit-fields';
import { KitTabs } from '@/components/runner-kit/kit-navigation';
import { KitSlider } from '@/components/runner-kit/kit-range';
import { KitCheckbox, KitSwitch } from '@/components/runner-kit/kit-selection';
import { KitToast } from '@/components/runner-kit/kit-surfaces';
import { PRESET_LABELS } from '@/lib/presets';
import { getSiteDictionary } from '@/lib/site-translations';
import { CutBar } from './cut-bar';
import { RunnerPart } from './runner-part';
import type { RunnerBoxProps } from './runner-box.types';

const row =
  'flex flex-wrap items-start gap-x-12 gap-y-5 px-[clamp(16px,2.5vw,32px)] pb-7';
const ruled = 'border-ip-border-control border-t-[1.5px]';

/** The hero runner: eight live parts and the command that cuts one. */
export function RunnerBox({ lang, kit, partsCount, landsAs }: RunnerBoxProps) {
  const site = getSiteDictionary(lang);
  const { preset } = usePreset();
  const [cut, setCut] = useState('button');
  const part = { cut, onCut: setCut };
  return (
    <div className="flex min-w-0 flex-col gap-4">
      <PresetStage className="border-ip-border-control relative flex flex-col rounded-[20px] border-[1.5px]">
        <div className="bg-ip-canvas absolute right-6 -bottom-3.75 flex items-center gap-2.5 px-2.5">
          <span className="text-2xl/7 font-bold">{PRESET_LABELS[preset]}</span>
          <span className="text-ip-text-secondary text-sm font-semibold">
            {partsCount}
          </span>
        </div>
        <div className={row}>
          <RunnerPart slug="button" {...part}>
            <KitButton>{kit.saveChanges}</KitButton>
          </RunnerPart>
          <RunnerPart slug="switch" {...part}>
            <KitSwitch
              label={kit.wifi}
              defaultChecked
              hideLabel
              className="ml-2"
            />
          </RunnerPart>
          <RunnerPart slug="checkbox" {...part}>
            <KitCheckbox label={kit.remember} defaultChecked />
          </RunnerPart>
        </div>
        <div className={`${row} ${ruled}`}>
          <RunnerPart
            slug="input"
            {...part}
            className="min-w-50 flex-[0_1_250px]"
          >
            <KitInput
              label={kit.project}
              defaultValue="just_ui"
              rule="project"
              errorMessage={kit.badProject}
            />
          </RunnerPart>
          <RunnerPart
            slug="slider"
            {...part}
            className="min-w-45 flex-[0_1_200px]"
          >
            <KitSlider label={kit.volume} />
          </RunnerPart>
          <RunnerPart slug="badge" {...part}>
            <KitBadge className="ml-1.5">{kit.draft}</KitBadge>
          </RunnerPart>
        </div>
        <div className={`${row} ${ruled}`}>
          <RunnerPart slug="tabs" {...part}>
            <KitTabs label={kit.tabsLabel} tabs={kit.tabs} />
          </RunnerPart>
          <RunnerPart slug="toast" {...part} className="max-w-full min-w-0">
            <KitToast title={kit.saved} body={kit.savedBody} size="md" />
          </RunnerPart>
        </div>
      </PresetStage>
      <CutBar cut={cut} site={site} landsAs={landsAs} />
    </div>
  );
}
