export type ComponentCategory =
  | 'primitive'
  | 'selection'
  | 'layout'
  | 'form'
  | 'navigation'
  | 'overlay'
  | 'composite';

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

export const components: ComponentMeta[] = [
  // 1. Primitives (9)
  {
    name: 'JustButton',
    slug: 'button',
    description:
      'Versatile interactive button with dynamic variant and scale-down state animations.',
    category: 'primitive',
    dartSnippet: `JustButton(
  label: 'Save Changes',
  variant: .primary,
  onPressed: () => print('Saved'),
)`,
  },
  {
    name: 'JustIconButton',
    slug: 'icon-button',
    description:
      'Dedicated icon button with tooltip assertions and press interactions.',
    category: 'primitive',
    dartSnippet: `JustIconButton(
  icon: const Icon(Icons.share),
  tooltip: 'Share document',
  onPressed: () => print('Share clicked'),
)`,
  },
  {
    name: 'JustInput',
    slug: 'input',
    description:
      'Interactive text field component with dynamic label animations and validation states.',
    category: 'primitive',
    dartSnippet: `JustInput(
  label: 'Email address',
  placeholder: 'you@domain.com',
  onChanged: (val) => print(val),
)`,
  },
  {
    name: 'JustBadge',
    slug: 'badge',
    description:
      'Compact status and label indicators supporting variant accents.',
    category: 'primitive',
    dartSnippet: `JustBadge(
  label: 'v0.13.2',
  variant: .outline,
)`,
  },
  {
    name: 'JustAvatar',
    slug: 'avatar',
    description:
      'User avatar display with automatic initials fallback and status indicators.',
    category: 'primitive',
    dartSnippet: `JustAvatar(
  name: 'Alex Rivera',
  size: .md,
)`,
  },
  {
    name: 'JustSelect',
    slug: 'select',
    description:
      'Accessible select dropdown menu with keyboard navigation and search.',
    category: 'primitive',
    dartSnippet: `JustSelect<String>(
  value: 'flutter',
  items: [
    JustSelectItem(value: 'flutter', label: 'Flutter'),
    JustSelectItem(value: 'dart', label: 'Dart'),
  ],
  onChanged: (val) => print(val),
)`,
  },
  {
    name: 'JustProgress',
    slug: 'progress',
    description:
      'Linear determinate and indeterminate progress bars with smooth animations.',
    category: 'primitive',
    dartSnippet: `JustProgress(
  value: 0.68,
  variant: .primary,
)`,
  },
  {
    name: 'JustAccordion',
    slug: 'accordion',
    description:
      'Vertically stacked collapsible panels for expandable content sections.',
    category: 'primitive',
    dartSnippet: `JustAccordion(
  items: [
    JustAccordionItem(
      title: 'What is JustUI?',
      content: Text('A zero-dependency Flutter component library.'),
    ),
  ],
)`,
  },
  {
    name: 'JustToggle',
    slug: 'toggle',
    description:
      'Two-state button toggle for binary controls and grouped state filters.',
    category: 'primitive',
    dartSnippet: `JustToggle(
  isSelected: true,
  child: Icon(Icons.format_bold),
  onChanged: (val) => print(val),
)`,
  },

  // 2. Selection (3)
  {
    name: 'JustCheckbox',
    slug: 'checkbox',
    description:
      'Accessible checkbox control with custom check icon animations.',
    category: 'selection',
    dartSnippet: `JustCheckbox(
  value: true,
  label: 'Accept terms and conditions',
  onChanged: (val) => print(val),
)`,
  },
  {
    name: 'JustRadio',
    slug: 'radio',
    description:
      'Radio button selection control for mutually exclusive options.',
    category: 'selection',
    dartSnippet: `JustRadio<String>(
  value: 'pro',
  groupValue: 'pro',
  label: 'Pro Plan ($29/mo)',
  onChanged: (val) => print(val),
)`,
  },
  {
    name: 'JustSwitch',
    slug: 'switch',
    description: 'Smooth sliding toggle switch with inner-border compensation.',
    category: 'selection',
    dartSnippet: `JustSwitch(
  value: true,
  onChanged: (val) => print(val),
)`,
  },

  // 3. Layout (6)
  {
    name: 'JustCard',
    slug: 'card',
    description:
      'Surface container with optional header, footer, and preset shadows.',
    category: 'layout',
    dartSnippet: `JustCard(
  title: Text('Project Metrics'),
  child: Text('All systems operational at 99.98% uptime.'),
)`,
  },
  {
    name: 'JustSeparator',
    slug: 'separator',
    description:
      'Horizontal or vertical line divider separating content sections.',
    category: 'layout',
    dartSnippet: `JustSeparator(
  orientation: .horizontal,
)`,
  },
  {
    name: 'JustScrollArea',
    slug: 'scroll-area',
    description: 'Custom styled scrollable container with momentum physics.',
    category: 'layout',
    dartSnippet: `JustScrollArea(
  child: Column(children: items),
)`,
  },
  {
    name: 'JustResizable',
    slug: 'resizable',
    description:
      'Split-view container with interactive draggable divider handles.',
    category: 'layout',
    dartSnippet: `JustResizable(
  direction: .horizontal,
  left: LeftPanel(),
  right: RightPanel(),
)`,
  },
  {
    name: 'JustCarousel',
    slug: 'carousel',
    description:
      'Interactive touch carousel slider with indicator dots and pagination.',
    category: 'layout',
    dartSnippet: `JustCarousel(
  itemCount: 5,
  itemBuilder: (context, index) => SlideWidget(index),
)`,
  },
  {
    name: 'JustSkeleton',
    slug: 'skeleton',
    description:
      'Shimmer placeholder loading skeleton for asynchronous content rendering.',
    category: 'layout',
    dartSnippet: `JustSkeleton(
  width: double.infinity,
  height: 24,
  borderRadius: .all(Radius.circular(6)),
)`,
  },

  // 4. Forms (1)
  {
    name: 'JustSlider',
    slug: 'slider',
    description:
      'Continuous and discrete range slider with live thumb tracking.',
    category: 'form',
    dartSnippet: `JustSlider(
  value: 75.0,
  min: 0.0,
  max: 100.0,
  onChanged: (val) => print(val),
)`,
  },

  // 5. Navigation (4)
  {
    name: 'JustBreadcrumb',
    slug: 'breadcrumb',
    description:
      'Hierarchical navigation trail indicating current page location.',
    category: 'navigation',
    dartSnippet: `JustBreadcrumb(
  items: [
    JustBreadcrumbItem(label: 'Home', href: '/'),
    JustBreadcrumbItem(label: 'Components', href: '/components'),
    JustBreadcrumbItem(label: 'Button'),
  ],
)`,
  },
  {
    name: 'JustTabs',
    slug: 'tabs',
    description:
      'Segmented content switcher organizing views into distinct panes.',
    category: 'navigation',
    dartSnippet: `JustTabs(
  tabs: ['Overview', 'Analytics', 'Settings'],
  selectedIndex: 0,
  onChanged: (idx) => print(idx),
)`,
  },
  {
    name: 'JustBottomNav',
    slug: 'bottom-nav',
    description:
      'Mobile-first bottom navigation bar with icons and badge indicators.',
    category: 'navigation',
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
  {
    name: 'JustSidebar',
    slug: 'sidebar',
    description:
      'Collapsible desktop navigation drawer with nested item trees.',
    category: 'navigation',
    dartSnippet: `JustSidebar(
  isCollapsed: false,
  items: navItems,
)`,
  },

  // 6. Overlays (4)
  {
    name: 'JustToast',
    slug: 'toast',
    description:
      'Imperative brief alert notifications appearing at screen edges.',
    category: 'overlay',
    dartSnippet: `JustToast.show(
  context,
  title: 'Success',
  message: 'Component installed successfully',
  variant: .success,
)`,
  },
  {
    name: 'JustDialog',
    slug: 'dialog',
    description: 'Modal window overlay with focus trapping and backdrop blur.',
    category: 'overlay',
    dartSnippet: `JustDialog(
  title: 'Confirm Action',
  content: Text('Are you sure you want to proceed?'),
  actions: [
    JustButton(label: 'Cancel', variant: .ghost),
    JustButton(label: 'Confirm', variant: .destructive),
  ],
)`,
  },
  {
    name: 'JustSheet',
    slug: 'sheet',
    description: 'Slide-over side drawer container for contextual actions.',
    category: 'overlay',
    dartSnippet: `JustSheet(
  side: .right,
  title: 'Filter Results',
  child: FilterForm(),
)`,
  },
  {
    name: 'JustTooltip',
    slug: 'tooltip',
    description: 'Hover and long-press contextual microcopy bubble.',
    category: 'overlay',
    dartSnippet: `JustTooltip(
  message: 'Verified WCAG AA 4.5:1',
  child: Icon(Icons.info_outline),
)`,
  },

  // 7. Composite (6)
  {
    name: 'JustAvatarGroup',
    slug: 'avatar-group',
    description:
      'Overlapping stack of avatars with dynamic overflow counter indicator.',
    category: 'composite',
    dartSnippet: `JustAvatarGroup(
  avatars: [
    JustAvatar(name: 'Sarah Connor'),
    JustAvatar(name: 'John Doe'),
    JustAvatar(name: 'Alex Rivera'),
  ],
  max: 3,
)`,
  },
  {
    name: 'JustRadioGroup',
    slug: 'radio-group',
    description:
      'Vertical or horizontal group wrapper coordinating radio state.',
    category: 'composite',
    dartSnippet: `JustRadioGroup<String>(
  value: selectedMethod,
  options: ['Credit Card', 'PayPal', 'Wire Transfer'],
  onChanged: (val) => print(val),
)`,
  },
  {
    name: 'JustTable',
    slug: 'table',
    description:
      'Interactive data grid table with sortable columns and zebra rows.',
    category: 'composite',
    dartSnippet: `JustTable(
  columns: ['Component', 'Category', 'Version'],
  rows: tableRows,
)`,
  },
  {
    name: 'JustDatePicker',
    slug: 'date-picker',
    description:
      'Single date selection calendar dropdown with locale awareness.',
    category: 'composite',
    dartSnippet: `JustDatePicker(
  selectedDate: DateTime.now(),
  onDateSelected: (date) => print(date),
)`,
  },
  {
    name: 'JustDateRangePicker',
    slug: 'date-range-picker',
    description:
      'Dual-calendar range picker selecting start and end date bounds.',
    category: 'composite',
    dartSnippet: `JustDateRangePicker(
  startDate: start,
  endDate: end,
  onRangeSelected: (range) => print(range),
)`,
  },
  {
    name: 'JustTimePicker',
    slug: 'time-picker',
    description: 'Time selector dial and inputs supporting 12h/24h formats.',
    category: 'composite',
    dartSnippet: `JustTimePicker(
  initialTime: TimeOfDay.now(),
  onTimeChanged: (time) => print(time),
)`,
  },
];
