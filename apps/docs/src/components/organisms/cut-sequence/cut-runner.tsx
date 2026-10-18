import type { ReactNode } from 'react';
import { Scissors } from 'lucide-react';
import { Gate } from '@/components/atoms/gate';
import { PresetStage } from '@/components/organisms/preset-stage';
import { usePreset } from '@/components/providers';
import { KitBadge } from '@/components/runner-kit/kit-display';
import { KitCheckbox, KitSwitch } from '@/components/runner-kit/kit-selection';
import { cn } from '@/lib/cn';
import {
  kitButtonBase,
  kitButtonSizes,
  kitButtonVariants,
  kitField,
} from '@/lib/kit-classes';
import { partCode } from '@/lib/parts';
import { PRESET_LABELS } from '@/lib/presets';
import type { CutRunnerProps } from './cut-sequence.types';

/** The primary button look without button semantics (slot and mover). */
export const partButton = cn(
  kitButtonBase,
  kitButtonSizes.md,
  kitButtonVariants.primary,
  'pointer-events-none'
);

/** Base state is the finished cut: the gate already narrowed to 45%. */
const gateLine = 'bg-ip-border-control h-4 w-[1.5px] [transform:scaleY(0.45)]';

function Hanging({ slug, children }: { slug: string; children: ReactNode }) {
  return (
    <div className="flex flex-col items-start">
      <Gate
        code={partCode(slug)}
        name={slug}
        selected={false}
        className="ml-5"
      />
      {children}
    </div>
  );
}

/** Part 07 on its gate. The scroll arms its label and narrows the gate. */
function CutPart({ label, cutEmpty }: { label: string; cutEmpty: string }) {
  return (
    <div className="flex flex-col items-start">
      <div className="ml-5 flex items-start gap-2">
        <div aria-hidden="true" className="flex w-0.5 flex-col">
          <span data-cut="gate" className={cn(gateLine, 'origin-top')} />
          <span data-cut="gate" className={cn(gateLine, 'origin-bottom')} />
        </div>
        <span
          data-cut="label"
          className="bg-ip-inverse text-ip-on-inverse mt-[3px] flex h-[26px] items-center gap-1.5 rounded-[6px] px-2 text-xs font-bold whitespace-nowrap"
        >
          <Scissors data-cut="scissors" size={13} aria-hidden="true" />
          <span>{partCode('button')}</span>
          <span className="font-medium">button</span>
        </span>
      </div>
      <div className="relative">
        <span
          data-cut="slot"
          aria-hidden="true"
          className={cn(partButton, 'opacity-0')}
        >
          {label}
        </span>
        <span
          data-cut="cut-tag"
          aria-hidden="true"
          className="border-ip-border-control text-ip-text-tertiary absolute inset-0 flex items-center justify-center rounded-[8px] border-[1.5px] border-dashed text-xs font-semibold whitespace-nowrap"
        >
          {cutEmpty}
        </span>
      </div>
    </div>
  );
}

/**
 * The five-part runner the button is cut from (three below 960px). It
 * follows the visitor's preset and joins the preset cross-dissolve.
 */
export function CutRunner({ kit, cutEmpty, partsCount }: CutRunnerProps) {
  const { preset } = usePreset();
  return (
    <PresetStage className="border-ip-border-control relative flex min-w-0 flex-[1_1_340px] items-start rounded-[20px] border-[1.5px] px-[clamp(16px,2.5vw,28px)] pb-7">
      <div className="bg-ip-canvas absolute right-6 bottom-[-15px] flex items-center gap-2.5 px-2.5">
        <span className="text-2xl/7 font-bold">{PRESET_LABELS[preset]}</span>
        <span className="text-ip-text-secondary text-sm font-semibold">
          {partsCount}
        </span>
      </div>
      <div className="flex flex-wrap items-start gap-x-11 gap-y-5">
        <CutPart label={kit.saveChanges} cutEmpty={cutEmpty} />
        <Hanging slug="switch">
          <KitSwitch
            label={kit.wifi}
            defaultChecked
            hideLabel
            className="ml-2"
          />
        </Hanging>
        <Hanging slug="checkbox">
          <KitCheckbox label={kit.remember} defaultChecked hideLabel />
        </Hanging>
        <div className="max-[960px]:hidden">
          <Hanging slug="badge">
            <div className="flex min-h-8 items-center">
              <KitBadge>{kit.draft}</KitBadge>
            </div>
          </Hanging>
        </div>
        <div className="max-[960px]:hidden">
          <Hanging slug="input">
            <input
              aria-label={kit.project}
              value="just_ui"
              readOnly
              className={cn(kitField, 'w-[180px]')}
            />
          </Hanging>
        </div>
      </div>
    </PresetStage>
  );
}
