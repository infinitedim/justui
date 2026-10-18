import { Plus } from 'lucide-react';
import { partDir } from '@/lib/parts';
import { KitButton, KitIconButton } from '@/components/runner-kit/kit-actions';
import {
  KitAccordion,
  KitCarousel,
  KitResizable,
  KitScrollArea,
} from '@/components/runner-kit/kit-disclosure';
import {
  KitDatePicker,
  KitDateRangePicker,
  KitTable,
  KitTimePicker,
} from '@/components/runner-kit/kit-data';
import {
  KitAvatar,
  KitAvatarGroup,
  KitBadge,
  KitSeparator,
  KitSkeleton,
  KitTooltip,
} from '@/components/runner-kit/kit-display';
import { KitInput, KitSelect } from '@/components/runner-kit/kit-fields';
import {
  KitBottomNav,
  KitBreadcrumb,
  KitSidebar,
  KitTabs,
} from '@/components/runner-kit/kit-navigation';
import { KitProgress, KitSlider } from '@/components/runner-kit/kit-range';
import {
  KitCheckbox,
  KitRadioGroup,
  KitSwitch,
  KitToggle,
} from '@/components/runner-kit/kit-selection';
import {
  KitCard,
  KitDialog,
  KitSheet,
  KitToast,
} from '@/components/runner-kit/kit-surfaces';
import { kitLabel } from '@/lib/kit-classes';
import type { KitPartProps, KitPartRenderer } from './kit-part.types';

const radios: KitPartRenderer = (t, uid) => (
  <KitRadioGroup
    label={t.frequency}
    name={`${uid}-radio`}
    options={[t.weekly, t.monthly]}
  />
);

const days: KitPartRenderer = (t) => (
  <KitDatePicker month={t.month} label={t.daysLabel} />
);

/** Default demo for every public part, keyed by registry slug. */
export const KIT_PARTS: Readonly<Record<string, KitPartRenderer>> = {
  accordion: (t) => (
    <KitAccordion question={t.accordionQuestion} answer={t.accordionAnswer} />
  ),
  avatar: () => (
    <span className="flex items-center gap-2.5">
      <KitAvatar initials="JU" />
      <span className={kitLabel}>my_app</span>
    </span>
  ),
  'avatar-group': () => <KitAvatarGroup initials={['JU', 'MA', '+3']} />,
  badge: (t) => (
    <span className="flex gap-2">
      <KitBadge>{t.draft}</KitBadge>
      <KitBadge>v2</KitBadge>
    </span>
  ),
  'bottom-nav': (t) => (
    <KitBottomNav label={t.bottomNavLabel} items={t.bottomNav} />
  ),
  breadcrumb: (t) => (
    <KitBreadcrumb
      label={t.breadcrumb}
      trail={['lib', 'widgets']}
      current="button"
    />
  ),
  button: (t) => <KitButton>{t.saveChanges}</KitButton>,
  card: (t) => (
    <KitCard title={t.notifications} description={t.notificationsBody} />
  ),
  carousel: (t) => (
    <KitCarousel
      label={t.slidesLabel}
      slideTemplate={t.slide}
      dotTemplate={t.slideAria}
    />
  ),
  checkbox: (t) => <KitCheckbox label={t.remember} defaultChecked />,
  'date-picker': days,
  'date-range-picker': (t) => (
    <KitDateRangePicker month={t.month} label={t.daysLabel} />
  ),
  dialog: (t) => (
    <KitDialog title={t.discardTitle} cancel={t.cancel} confirm={t.discard} />
  ),
  'icon-button': (t) => (
    <KitIconButton label={t.add}>
      <Plus size={16} aria-hidden="true" />
    </KitIconButton>
  ),
  input: (t) => (
    <KitInput
      label={t.project}
      defaultValue="my_app"
      rule="project"
      errorMessage={t.badProject}
      className="max-w-[240px]"
    />
  ),
  progress: (t) => (
    <KitProgress label={t.uploading} value={65} className="max-w-[220px]" />
  ),
  radio: radios,
  'radio-group': radios,
  resizable: (t) => <KitResizable start={t.files} end={t.editor} />,
  'scroll-area': () => (
    <KitScrollArea
      lines={[
        `${partDir('button')}/`,
        `${partDir('card')}/`,
        `${partDir('input')}/`,
      ]}
    />
  ),
  select: (t) => (
    <KitSelect
      label={t.frequency}
      options={[t.weekly, t.monthly]}
      className="max-w-[220px]"
    />
  ),
  separator: (t) => <KitSeparator start={t.tabs[0]} end={t.tabs[1]} />,
  sheet: (t) => <KitSheet title={t.share} />,
  sidebar: (t) => <KitSidebar label={t.sidebarLabel} items={t.sidebar} />,
  skeleton: () => <KitSkeleton />,
  slider: (t) => <KitSlider label={t.volume} className="max-w-[220px]" />,
  switch: (t) => <KitSwitch label={t.wifi} defaultChecked />,
  table: (t) => (
    <KitTable
      columns={[t.part, t.folder]}
      rows={[
        ['button', partDir('button')],
        ['card', partDir('card')],
      ]}
    />
  ),
  tabs: (t) => <KitTabs label={t.tabsLabel} tabs={t.tabs} />,
  'time-picker': () => <KitTimePicker hours="09" minutes="41" />,
  toast: (t) => <KitToast title={t.saved} body={t.savedBody} />,
  toggle: (t) => <KitToggle label={t.bold} />,
  tooltip: (t) => <KitTooltip label={t.copy} />,
};

/** Renders the default demo for `slug`, or nothing for an unknown slug. */
export function KitPart({ slug, t, uid }: KitPartProps) {
  const render = KIT_PARTS[slug];
  return render ? render(t, uid) : null;
}
