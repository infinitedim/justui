import {
  GENERATED_COMPONENTS,
  type GeneratedComponentCategory,
} from './components.generated';

export type ComponentCategory = GeneratedComponentCategory;

export interface ComponentMeta {
  name: string;
  slug: string;
  category: ComponentCategory;
  dartSnippet: string;
}

/** Display order of the catalog filter; labels live in lib/catalog-i18n. */
export const CATEGORY_ORDER: readonly ComponentCategory[] = [
  'primitive',
  'selection',
  'layout',
  'form',
  'navigation',
  'overlay',
  'composite',
];

/**
 * Hand-authored example snippets, keyed by slug. Name/slug/category come
 * from `registry/index.json` via `components.generated.ts`; descriptions are
 * localized in `lib/catalog-i18n/descriptions.ts`. Snippet strings follow the
 * same CRM scenario as the catalog previews.
 */
const CATALOG_OVERLAY: Record<string, { dartSnippet: string }> = {
  button: {
    dartSnippet: `JustButton(
  label: 'Log call',
  variant: .primary,
  onPressed: () => logCall(contact),
)`,
  },
  'icon-button': {
    dartSnippet: `JustIconButton(
  icon: const Icon(Icons.share),
  tooltip: 'Call Rina Wulandari',
  onPressed: () => call(contact),
)`,
  },
  input: {
    dartSnippet: `JustInput(
  label: 'Work email',
  placeholder: 'name@company.com',
  onChanged: (val) => print(val),
)`,
  },
  badge: {
    dartSnippet: `JustBadge(
  label: 'Qualified',
  variant: .outline,
)`,
  },
  avatar: {
    dartSnippet: `JustAvatar(
  name: 'Rina Wulandari',
  size: .md,
)`,
  },
  select: {
    dartSnippet: `JustSelect<String>(
  value: 'qualified',
  items: [
    JustSelectItem(value: 'lead', label: 'Lead'),
    JustSelectItem(value: 'qualified', label: 'Qualified'),
    JustSelectItem(value: 'won', label: 'Won'),
  ],
  onChanged: (val) => print(val),
)`,
  },
  progress: {
    dartSnippet: `JustProgress(
  value: 0.68,
  variant: .primary,
)`,
  },
  accordion: {
    dartSnippet: `JustAccordion(
  items: [
    JustAccordionItem(
      title: 'Company',
      content: Text('Kopi Senja, 4 outlets in Bandung.'),
    ),
  ],
)`,
  },
  toggle: {
    dartSnippet: `JustToggle(
  isSelected: true,
  child: Icon(Icons.format_bold),
  onChanged: (val) => print(val),
)`,
  },
  checkbox: {
    dartSnippet: `JustCheckbox(
  value: true,
  label: 'Send proposal to Hotel Arunika',
  onChanged: (val) => print(val),
)`,
  },
  radio: {
    dartSnippet: `JustRadio<String>(
  value: 'phone',
  groupValue: 'phone',
  label: 'Phone',
  onChanged: (val) => print(val),
)`,
  },
  switch: {
    dartSnippet: `JustSwitch(
  value: true,
  onChanged: (val) => print(val),
)`,
  },
  card: {
    dartSnippet: `JustCard(
  title: Text('Hotel Arunika'),
  child: Text('Rp 18.450.000, Proposal stage'),
)`,
  },
  separator: {
    dartSnippet: `JustSeparator(
  orientation: .horizontal,
)`,
  },
  'scroll-area': {
    dartSnippet: `JustScrollArea(
  child: Column(children: items),
)`,
  },
  resizable: {
    dartSnippet: `JustResizable(
  direction: .horizontal,
  left: LeftPanel(),
  right: RightPanel(),
)`,
  },
  carousel: {
    dartSnippet: `JustCarousel(
  itemCount: 5,
  itemBuilder: (context, index) => SlideWidget(index),
)`,
  },
  skeleton: {
    dartSnippet: `JustSkeleton(
  width: double.infinity,
  height: 24,
  borderRadius: .all(Radius.circular(6)),
)`,
  },
  slider: {
    dartSnippet: `JustSlider(
  value: 75.0,
  min: 0.0,
  max: 100.0,
  onChanged: (val) => print(val),
)`,
  },
  breadcrumb: {
    dartSnippet: `JustBreadcrumb(
  items: [
    JustBreadcrumbItem(label: 'Contacts', onTap: openContacts),
    JustBreadcrumbItem(label: 'Kopi Senja', onTap: openCompany),
    JustBreadcrumbItem(label: 'Deals'),
  ],
)`,
  },
  tabs: {
    dartSnippet: `JustTabs(
  tabs: ['Overview', 'Deals', 'Notes'],
  selectedIndex: 0,
  onChanged: (idx) => print(idx),
)`,
  },
  'bottom-nav': {
    dartSnippet: `JustBottomNav(
  currentIndex: 0,
  items: [
    JustBottomNavItem(icon: Icons.view_kanban, label: 'Pipeline'),
    JustBottomNavItem(icon: Icons.people, label: 'Contacts'),
    JustBottomNavItem(icon: Icons.checklist, label: 'Tasks'),
  ],
  onTap: (idx) => print(idx),
)`,
  },
  sidebar: {
    dartSnippet: `JustSidebar(
  isCollapsed: false,
  items: navItems,
)`,
  },
  toast: {
    dartSnippet: `JustToast.show(
  context,
  title: 'Deal moved to Won',
  message: 'Hotel Arunika, Rp 18.450.000',
  variant: .success,
)`,
  },
  dialog: {
    dartSnippet: `JustDialog(
  title: 'Delete this contact?',
  content: Text('Rina Wulandari and 3 notes will be removed.'),
  actions: [
    JustButton(label: 'Cancel', variant: .ghost),
    JustButton(label: 'Delete', variant: .destructive),
  ],
)`,
  },
  sheet: {
    dartSnippet: `JustSheet(
  side: .right,
  title: 'Bagas Pratama',
  child: FilterForm(),
)`,
  },
  tooltip: {
    dartSnippet: `JustTooltip(
  message: 'Called 3 days ago by Dewi',
  child: Icon(Icons.info_outline),
)`,
  },
  'avatar-group': {
    dartSnippet: `JustAvatarGroup(
  avatars: [
    JustAvatar(name: 'Rina Wulandari'),
    JustAvatar(name: 'Bagas Pratama'),
    JustAvatar(name: 'Dewi Lestari'),
  ],
  max: 3,
)`,
  },
  'radio-group': {
    dartSnippet: `JustRadioGroup<String>(
  value: selectedMethod,
  options: ['Low', 'Medium', 'High'],
  onChanged: (val) => print(val),
)`,
  },
  table: {
    dartSnippet: `JustTable(
  columns: ['Company', 'Stage', 'Value'],
  rows: tableRows,
)`,
  },
  'date-picker': {
    dartSnippet: `JustDatePicker(
  selectedDate: DateTime.now(),
  onDateSelected: (date) => print(date),
)`,
  },
  'date-range-picker': {
    dartSnippet: `JustDateRangePicker(
  startDate: start,
  endDate: end,
  onRangeSelected: (range) => print(range),
)`,
  },
  'time-picker': {
    dartSnippet: `JustTimePicker(
  initialTime: TimeOfDay.now(),
  onTimeChanged: (time) => print(time),
)`,
  },
};

export const components: ComponentMeta[] = GENERATED_COMPONENTS.map(
  (generated) => {
    const overlay = CATALOG_OVERLAY[generated.slug];
    if (!overlay) {
      throw new Error(
        `components-data: no catalog copy (description/dartSnippet) registered ` +
          `for "${generated.slug}" - add an entry to CATALOG_OVERLAY.`
      );
    }
    return { ...generated, ...overlay };
  }
);
