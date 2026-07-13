export interface ComponentMeta {
  name: string;
  slug: string;
  description: string;
}

export const components: Array<ComponentMeta> = [
  {
    name: 'JustButton',
    slug: 'button',
    description: 'Flexible button with all theme presets',
  },
  {
    name: 'JustInput',
    slug: 'input',
    description: 'Text input with label and validation states',
  },
  {
    name: 'JustBadge',
    slug: 'badge',
    description: 'Status and label badges',
  },
  {
    name: 'JustAvatar',
    slug: 'avatar',
    description: 'User avatar with fallback initials',
  },
  {
    name: 'JustCard',
    slug: 'card',
    description: 'Surface container with optional header/footer',
  },
  {
    name: 'JustCheckbox',
    slug: 'checkbox',
    description: 'Accessible checkbox with custom styles',
  },
  {
    name: 'JustRadio',
    slug: 'radio',
    description: 'Radio group with preset support',
  },
  {
    name: 'JustSwitch',
    slug: 'switch',
    description: 'Toggle switch, zero Material',
  },
  {
    name: 'JustSeparator',
    slug: 'separator',
    description: 'Horizontal or vertical divider',
  },
  {
    name: 'JustSkeleton',
    slug: 'skeleton',
    description: 'Loading placeholder with shimmer',
  },
  {
    name: 'JustTabs',
    slug: 'tabs',
    description: 'Segmented tab navigation',
  },
  {
    name: 'JustBreadcrumb',
    slug: 'breadcrumb',
    description: 'Hierarchical path indicator',
  },
  {
    name: 'JustSidebar',
    slug: 'sidebar',
    description: 'Collapsible vertical nav with nested items',
  },
  {
    name: 'JustBottomNav',
    slug: 'bottom-nav',
    description: 'Mobile-style bottom navigation bar',
  },
  {
    name: 'JustScrollArea',
    slug: 'scroll-area',
    description: 'Custom scrollbar container',
  },
  {
    name: 'JustToast',
    slug: 'toast',
    description: 'Imperative toast notification overlay',
  },
  {
    name: 'JustDialog',
    slug: 'dialog',
    description: 'Modal overlay with focus trapping',
  },
  {
    name: 'JustSheet',
    slug: 'sheet',
    description: 'Slide-over side drawer overlay',
  },
  {
    name: 'JustTooltip',
    slug: 'tooltip',
    description: 'Declarative hover contextual tooltip',
  },
  {
    name: 'JustSelect',
    slug: 'select',
    description: 'Accessible select dropdown overlay',
  },
  {
    name: 'JustProgress',
    slug: 'progress',
    description: 'Determinate or indeterminate progress bar',
  },
  {
    name: 'JustAccordion',
    slug: 'accordion',
    description: 'Stacked collapsible content panels',
  },
  {
    name: 'JustToggle',
    slug: 'toggle',
    description: 'State toggle buttons and groups',
  },
  {
    name: 'JustTable',
    slug: 'table',
    description: 'Interactive data grid table',
  },
] as const;
