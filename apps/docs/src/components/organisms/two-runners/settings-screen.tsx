import { KitButton } from '@/components/runner-kit/kit-actions';
import { KitInput } from '@/components/runner-kit/kit-fields';
import { KitSlider } from '@/components/runner-kit/kit-range';
import { KitSwitch } from '@/components/runner-kit/kit-selection';
import { KitCard, KitToast } from '@/components/runner-kit/kit-surfaces';
import { cn } from '@/lib/cn';
import { kitLabel } from '@/lib/kit-classes';
import type { SettingsScreenProps } from './two-runners.types';

const separator =
  'border-b-(length:--ip-separator-width) border-(--ip-part-separator)';

function SettingRow({
  label,
  first = false,
  defaultChecked = false,
}: {
  label: string;
  first?: boolean;
  defaultChecked?: boolean;
}) {
  return (
    <div
      className={cn(
        'flex items-center justify-between gap-4 py-3',
        separator,
        first && 'mt-4 border-t-(length:--ip-separator-width)'
      )}
    >
      <span aria-hidden="true" className={kitLabel}>
        {label}
      </span>
      <KitSwitch label={label} hideLabel defaultChecked={defaultChecked} />
    </div>
  );
}

/**
 * One notifications screen built from the runner-kit parts. The same
 * markup renders in both columns; only the stage's preset differs.
 */
export function SettingsScreen({ kit }: SettingsScreenProps) {
  return (
    <>
      <KitCard
        title={kit.notifications}
        description={kit.notificationsBody}
        size="md"
      >
        <SettingRow first label={kit.productUpdates} defaultChecked />
        <SettingRow label={kit.weeklyDigest} />
        <KitSlider label={kit.alertVolume} className="mt-3.5" />
        <KitInput
          label={kit.sendTo}
          defaultValue="team@example.com"
          rule="email"
          type="email"
          errorMessage={kit.badEmail}
          className="mt-3"
        />
        <div className="mt-5 flex flex-wrap justify-end gap-3">
          <KitButton variant="secondary">{kit.cancel}</KitButton>
          <KitButton>{kit.save}</KitButton>
        </div>
      </KitCard>
      <KitToast title={kit.saved} body={kit.notifSaved} size="md" />
    </>
  );
}
