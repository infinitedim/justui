import {
  GENERATED_COMPONENTS,
  type GeneratedComponentCategory,
} from './components.generated';

export type ComponentCategory = GeneratedComponentCategory;

export interface ComponentMeta {
  name: string;
  slug: string;
  description: string;
  category: ComponentCategory;
  dartSnippet: string;
}

export const CATEGORIES: { id: ComponentCategory; label: string }[] = [
  { id: 'primitive', label: 'Primitives' },
  { id: 'selection', label: 'Selection' },
  { id: 'layout', label: 'Layout' },
  { id: 'form', label: 'Forms' },
  { id: 'navigation', label: 'Navigation' },
  { id: 'overlay', label: 'Overlays' },
  { id: 'composite', label: 'Composite' },
];

/**
 * Hand-authored catalog copy, keyed by slug. Name/slug/category come from
 * `registry/index.json` via `components.generated.ts` - this overlay only
 * supplies the prose and example snippet that a generator can't derive.
 */
const CATALOG_OVERLAY: Record<
  string,
  { description: string; dartSnippet: string }
> = {
  button: {
    description:
      'Versatile interactive button with dynamic variant and scale-down state animations.',
    dartSnippet: `JustButton(
  label: 'Save Changes',
  variant: .primary,
  onPressed: () => print('Saved'),
)`,
  },
  'icon-button': {
    description:
      'Dedicated icon button with tooltip assertions and press interactions.',
    dartSnippet: `JustIconButton(
  icon: const Icon(Icons.share),
  tooltip: 'Share document',
  onPressed: () => print('Share clicked'),
)`,
  },
  input: {
    description:
      'Interactive text field component with dynamic label animations and validation states.',
    dartSnippet: `JustInput(
  label: 'Email address',
  placeholder: 'you@domain.com',
  onChanged: (val) => print(val),
)`,
  },
  badge: {
    description:
      'Compact status and label indicators supporting variant accents.',
    dartSnippet: `JustBadge(
  label: 'v0.13.2',
  variant: .outline,
)`,
  },
  avatar: {
    description:
      'User avatar display with automatic initials fallback and status indicators.',
    dartSnippet: `JustAvatar(
  name: 'Alex Rivera',
  size: .md,
)`,
  },
  select: {
    description:
      'Accessible select dropdown menu with keyboard navigation and search.',
    dartSnippet: `JustSelect<String>(
  value: 'flutter',
  items: [
    JustSelectItem(value: 'flutter', label: 'Flutter'),
    JustSelectItem(value: 'dart', label: 'Dart'),
  ],
  onChanged: (val) => print(val),
)`,
  },
  progress: {
    description:
      'Linear determinate and indeterminate progress bars with smooth animations.',
    dartSnippet: `JustProgress(
  value: 0.68,
  variant: .primary,
)`,
  },
  accordion: {
    description:
      'Vertically stacked collapsible panels for expandable content sections.',
    dartSnippet: `JustAccordion(
  items: [
    JustAccordionItem(
      title: 'What is JustUI?',
      content: Text('A zero-dependency Flutter component library.'),
    ),
  ],
)`,
  },
  toggle: {
    description:
      'Two-state button toggle for binary controls and grouped state filters.',
    dartSnippet: `JustToggle(
  isSelected: true,
  child: Icon(Icons.format_bold),
  onChanged: (val) => print(val),
)`,
  },
  checkbox: {
    description:
      'Accessible checkbox control with custom check icon animations.',
    dartSnippet: `JustCheckbox(
  value: true,
  label: 'Accept terms and conditions',
  onChanged: (val) => print(val),
)`,
  },
  radio: {
    description:
      'Radio button selection control for mutually exclusive options.',
    dartSnippet: `JustRadio<String>(
  value: 'pro',
  groupValue: 'pro',
  label: 'Pro Plan ($29/mo)',
  onChanged: (val) => print(val),
)`,
  },
  switch: {
    description: 'Smooth sliding toggle switch with inner-border compensation.',
    dartSnippet: `JustSwitch(
  value: true,
  onChanged: (val) => print(val),
)`,
  },
  card: {
    description:
      'Surface container with optional header, footer, and preset shadows.',
    dartSnippet: `JustCard(
  title: Text('Project Metrics'),
  child: Text('All systems operational at 99.98% uptime.'),
)`,
  },
  separator: {
    description:
      'Horizontal or vertical line divider separating content sections.',
    dartSnippet: `JustSeparator(
  orientation: .horizontal,
)`,
  },
  'scroll-area': {
    description: 'Custom styled scrollable container with momentum physics.',
    dartSnippet: `JustScrollArea(
  child: Column(children: items),
)`,
  },
  resizable: {
    description:
      'Split-view container with interactive draggable divider handles.',
    dartSnippet: `JustResizable(
  direction: .horizontal,
  left: LeftPanel(),
  right: RightPanel(),
)`,
  },
  carousel: {
    description:
      'Interactive touch carousel slider with indicator dots and pagination.',
    dartSnippet: `JustCarousel(
  itemCount: 5,
  itemBuilder: (context, index) => SlideWidget(index),
)`,
  },
  skeleton: {
    description:
      'Shimmer placeholder loading skeleton for asynchronous content rendering.',
    dartSnippet: `JustSkeleton(
  width: double.infinity,
  height: 24,
  borderRadius: .all(Radius.circular(6)),
)`,
  },
  slider: {
    description:
      'Continuous and discrete range slider with live thumb tracking.',
    dartSnippet: `JustSlider(
  value: 75.0,
  min: 0.0,
  max: 100.0,
  onChanged: (val) => print(val),
)`,
  },
  breadcrumb: {
    description:
      'Hierarchical navigation trail indicating current page location.',
    dartSnippet: `JustBreadcrumb(
  items: [
    JustBreadcrumbItem(label: 'Home', href: '/'),
    JustBreadcrumbItem(label: 'Components', href: '/components'),
    JustBreadcrumbItem(label: 'Button'),
  ],
)`,
  },
  tabs: {
    description:
      'Segmented content switcher organizing views into distinct panes.',
    dartSnippet: `JustTabs(
  tabs: ['Overview', 'Analytics', 'Settings'],
  selectedIndex: 0,
  onChanged: (idx) => print(idx),
)`,
  },
  'bottom-nav': {
    description:
      'Mobile-first bottom navigation bar with icons and badge indicators.',
    dartSnippet: `JustBottomNav(
  currentIndex: 0,
  items: [
    JustBottomNavItem(icon: Icons.home, label: 'Home'),
    JustBottomNavItem(icon: Icons.search, label: 'Search'),
    JustBottomNavItem(icon: Icons.person, label: 'Profile'),
  ],
  onTap: (idx) => print(idx),
)`,
  },
  sidebar: {
    description:
      'Collapsible desktop navigation drawer with nested item trees.',
    dartSnippet: `JustSidebar(
  isCollapsed: false,
  items: navItems,
)`,
  },
  toast: {
    description:
      'Imperative brief alert notifications appearing at screen edges.',
    dartSnippet: `JustToast.show(
  context,
  title: 'Success',
  message: 'Component installed successfully',
  variant: .success,
)`,
  },
  dialog: {
    description: 'Modal window overlay with focus trapping and backdrop blur.',
    dartSnippet: `JustDialog(
  title: 'Confirm Action',
  content: Text('Are you sure you want to proceed?'),
  actions: [
    JustButton(label: 'Cancel', variant: .ghost),
    JustButton(label: 'Confirm', variant: .destructive),
  ],
)`,
  },
  sheet: {
    description: 'Slide-over side drawer container for contextual actions.',
    dartSnippet: `JustSheet(
  side: .right,
  title: 'Filter Results',
  child: FilterForm(),
)`,
  },
  tooltip: {
    description: 'Hover and long-press contextual microcopy bubble.',
    dartSnippet: `JustTooltip(
  message: 'Verified WCAG AA 4.5:1',
  child: Icon(Icons.info_outline),
)`,
  },
  'avatar-group': {
    description:
      'Overlapping stack of avatars with dynamic overflow counter indicator.',
    dartSnippet: `JustAvatarGroup(
  avatars: [
    JustAvatar(name: 'Sarah Connor'),
    JustAvatar(name: 'John Doe'),
    JustAvatar(name: 'Alex Rivera'),
  ],
  max: 3,
)`,
  },
  'radio-group': {
    description:
      'Vertical or horizontal group wrapper coordinating radio state.',
    dartSnippet: `JustRadioGroup<String>(
  value: selectedMethod,
  options: ['Credit Card', 'PayPal', 'Wire Transfer'],
  onChanged: (val) => print(val),
)`,
  },
  table: {
    description:
      'Interactive data grid table with sortable columns and zebra rows.',
    dartSnippet: `JustTable(
  columns: ['Component', 'Category', 'Version'],
  rows: tableRows,
)`,
  },
  'date-picker': {
    description:
      'Single date selection calendar dropdown with locale awareness.',
    dartSnippet: `JustDatePicker(
  selectedDate: DateTime.now(),
  onDateSelected: (date) => print(date),
)`,
  },
  'date-range-picker': {
    description:
      'Dual-calendar range picker selecting start and end date bounds.',
    dartSnippet: `JustDateRangePicker(
  startDate: start,
  endDate: end,
  onRangeSelected: (range) => print(range),
)`,
  },
  'time-picker': {
    description: 'Time selector dial and inputs supporting 12h/24h formats.',
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
