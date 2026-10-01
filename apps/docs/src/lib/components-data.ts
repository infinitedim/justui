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

/** Category order in the catalog filter. Labels live in the dictionaries. */
export const CATEGORIES: readonly ComponentCategory[] = [
  'primitive',
  'selection',
  'layout',
  'form',
  'navigation',
  'overlay',
  'composite',
];

/**
 * Hand-authored catalog copy, keyed by slug. Name/slug/category come from
 * `registry/index.json` via `components.generated.ts`; this overlay only
 * supplies what a generator can't derive.
 *
 * Rules: the description is one sentence saying what the widget does, no
 * adjectives; a special capability is named by its prop. Snippets use the
 * real constructors in packages/core/lib/src/components.
 */
const CATALOG_OVERLAY: Record<
  string,
  { description: string; dartSnippet: string }
> = {
  button: {
    description:
      'Runs an action; variants primary, secondary, ghost, destructive and link, with isLoading.',
    dartSnippet: `JustButton(
  label: 'Place order',
  variant: .primary,
  onPressed: () {},
)`,
  },
  'icon-button': {
    description: 'A button with only an icon; tooltip is required.',
    dartSnippet: `JustIconButton(
  icon: const Icon(Icons.favorite_border),
  tooltip: 'Save for later',
  onPressed: () {},
)`,
  },
  input: {
    description:
      'Single-line or multi-line text field with label, hint, helper and errorText.',
    dartSnippet: `JustInput(
  label: 'Delivery note',
  hint: 'Leave it at the front desk',
  onChanged: (value) {},
)`,
  },
  badge: {
    description: 'Short status label; variants solid, outline, soft and dot.',
    dartSnippet: `JustBadge(
  label: 'Shipped',
  color: .success,
  variant: .soft,
)`,
  },
  avatar: {
    description:
      'Shows a photo, initials from name, or an icon, with an optional statusDot.',
    dartSnippet: `JustAvatar(
  name: 'Alex Rivera',
  statusDot: .online,
)`,
  },
  select: {
    description:
      'Picks one option from a dropdown list; set searchable for long lists.',
    dartSnippet: `JustSelect<String>(
  label: 'Shipping',
  value: 'standard',
  options: const [
    JustSelectOption(value: 'standard', label: 'Standard, 3-5 days'),
    JustSelectOption(value: 'express', label: 'Express, 1-2 days'),
  ],
  onChanged: (value) {},
)`,
  },
  progress: {
    description:
      'Shows how far a task has got, from min to max; leave value null for indeterminate.',
    dartSnippet: `JustProgress(
  value: 0.75,
  showLabel: true,
)`,
  },
  accordion: {
    description:
      'Stack of sections that expand and collapse; allowMultiple keeps several open.',
    dartSnippet: `JustAccordion(
  items: const [
    JustAccordionItem(
      title: 'Can I change the address?',
      content: Text('Yes, until the order is packed.'),
    ),
  ],
)`,
  },
  toggle: {
    description:
      'A button that stays pressed or not; JustToggleGroup combines several.',
    dartSnippet: `JustToggle(
  selected: true,
  onPressed: () {},
  child: const Text('Paid'),
)`,
  },
  table: {
    description:
      'Rows and columns of data, with optional sorting and row selection.',
    dartSnippet: `JustTable<Order>(
  columns: [
    JustTableColumn(header: 'Order', cell: (o) => Text(o.id)),
    JustTableColumn(header: 'Total', cell: (o) => Text(o.total)),
  ],
  rows: orders,
)`,
  },
  checkbox: {
    description:
      'On, off, or mixed (value: null) choice with an optional label.',
    dartSnippet: `JustCheckbox(
  value: true,
  label: const Text('Email me when it ships'),
  onChanged: (value) {},
)`,
  },
  radio: {
    description:
      'One option out of a set; selected when value equals groupValue.',
    dartSnippet: `JustRadio<String>(
  value: 'standard',
  groupValue: delivery,
  label: const Text('Standard delivery'),
  onChanged: (value) {},
)`,
  },
  switch: {
    description: 'Turns a setting on or off; supports tap and drag.',
    dartSnippet: `JustSwitch(
  value: true,
  label: const Text('Order updates'),
  onChanged: (value) {},
)`,
  },
  card: {
    description:
      'Groups related content on a surface; variants elevated, outlined and filled.',
    dartSnippet: `JustCard(
  header: const Text('Order #1042'),
  child: const Text('2 items, arriving Friday'),
)`,
  },
  separator: {
    description:
      'A line between sections, horizontal or vertical, with an optional label.',
    dartSnippet: `JustSeparator(
  direction: .horizontal,
)`,
  },
  'scroll-area': {
    description:
      'Scrolling region with a scrollbar that follows the theme tokens.',
    dartSnippet: `JustScrollArea(
  maxHeight: 240,
  child: Column(children: orderLines),
)`,
  },
  resizable: {
    description:
      'Panels split by draggable handles, with min, max and snap sizes per panel.',
    dartSnippet: `JustResizable(
  direction: .horizontal,
  children: [
    JustResizablePanel(initialSize: 0.4, child: OrderList()),
    JustResizablePanel(initialSize: 0.6, child: OrderDetails()),
  ],
)`,
  },
  carousel: {
    description:
      'Pages through children one at a time; arrows, dots and autoScroll are optional.',
    dartSnippet: `JustCarousel(
  children: productPhotos,
)`,
  },
  skeleton: {
    description:
      'Shows a placeholder in the shape of its child while loading is true.',
    dartSnippet: `JustSkeleton(
  loading: isLoading,
  child: OrderCard(order),
)`,
  },
  slider: {
    description: 'Picks a number between min and max; divisions makes it step.',
    dartSnippet: `JustSlider(
  value: 80,
  min: 0,
  max: 200,
  onChanged: (value) {},
)`,
  },
  breadcrumb: {
    description:
      'Shows where the current page sits in a hierarchy; maxItems collapses long trails.',
    dartSnippet: `JustBreadcrumb(
  items: [
    JustBreadcrumbItem(label: 'Shop', onTap: () {}),
    JustBreadcrumbItem(label: 'Orders', onTap: () {}),
    const JustBreadcrumbItem(label: '#1042'),
  ],
)`,
  },
  tabs: {
    description:
      'Switches between panels; variants line, enclosed, pill and vertical.',
    dartSnippet: `JustTabs(
  tabs: const [
    JustTab(label: 'Details', content: OrderDetails()),
    JustTab(label: 'Shipping', content: ShippingInfo()),
  ],
)`,
  },
  'bottom-nav': {
    description:
      'Top-level navigation for phones; variants fixed, shifting and floating.',
    dartSnippet: `JustBottomNav(
  selectedIndex: 2,
  items: const [
    JustBottomNavItem(icon: Icon(Icons.home), label: 'Home'),
    JustBottomNavItem(icon: Icon(Icons.search), label: 'Search'),
    JustBottomNavItem(icon: Icon(Icons.inventory_2), label: 'Orders'),
  ],
  onItemSelected: (index) {},
)`,
  },
  sidebar: {
    description: 'Side navigation for wide screens that can collapse to icons.',
    dartSnippet: `JustSidebar(
  selectedIndex: 0,
  items: const [
    JustSidebarItem(label: 'Orders', icon: Icon(Icons.inventory_2)),
    JustSidebarItem(label: 'Settings', icon: Icon(Icons.settings)),
  ],
)`,
  },
  toast: {
    description:
      'Brief message that dismisses itself; shown through JustToastScope.',
    dartSnippet: `JustToastScope.of(context).show(
  message: 'Order #1042 shipped',
  variant: .success,
)`,
  },
  dialog: {
    description: 'Modal content above the page; shown through JustDialogScope.',
    dartSnippet: `JustDialogScope.of(context).show(
  content: const RemoveAddressDialog(),
)`,
  },
  sheet: {
    description:
      'Panel that slides in from any edge; shown through JustSheetScope.',
    dartSnippet: `JustSheetScope.of(context).show(
  direction: .right,
  content: const OrderFilters(),
)`,
  },
  tooltip: {
    description: 'Short hint shown on hover or long press.',
    dartSnippet: `JustTooltip(
  message: 'Free on orders over $50',
  child: const Icon(Icons.info_outline),
)`,
  },
  'avatar-group': {
    description:
      'Overlapping avatars that collapse into a +N count after maxDisplay.',
    dartSnippet: `JustAvatarGroup(
  maxDisplay: 3,
  avatars: const [
    JustAvatar(name: 'Alex Rivera'),
    JustAvatar(name: 'Mia Santoso'),
    JustAvatar(name: 'Kai Tan'),
    JustAvatar(name: 'Rina Putri'),
  ],
)`,
  },
  'radio-group': {
    description:
      'A labelled set of radios laid out vertically or horizontally.',
    dartSnippet: `JustRadioGroup<String>(
  value: 'card',
  options: const [
    JustRadioOption(value: 'card', label: Text('Card')),
    JustRadioOption(value: 'cod', label: Text('Pay on delivery')),
  ],
  onChanged: (value) {},
)`,
  },
  'date-picker': {
    description:
      'Picks one date; variants inline, modal, dropdown and responsive.',
    dartSnippet: `JustDatePicker(
  label: 'Delivery date',
  value: deliveryDate,
  onChanged: (date) {},
)`,
  },
  'date-range-picker': {
    description: 'Picks a start and end date, with optional quick presets.',
    dartSnippet: `JustDateRangePicker(
  value: reportRange,
  onChanged: (range) {},
)`,
  },
  'time-picker': {
    description:
      'Picks a time with a dial, a spinner or typed input, in 12- or 24-hour format.',
    dartSnippet: `JustTimePicker(
  label: 'Pickup time',
  value: pickupTime,
  onChanged: (time) {},
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
