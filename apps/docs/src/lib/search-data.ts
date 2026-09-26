import type { Route } from 'next';
import { components } from '@/lib/components-data';
import { localizedHref } from '@/lib/i18n';

export type SearchItem = {
  label: string;
  href: Route;
  type: 'component' | 'doc';
};

const docItems = (lang: string): SearchItem[] => [
  {
    label: 'Introduction',
    href: localizedHref(lang, '/docs/introduction'),
    type: 'doc',
  },
  {
    label: 'Installation',
    href: localizedHref(lang, '/docs/installation'),
    type: 'doc',
  },
  {
    label: 'Quick Start',
    href: localizedHref(lang, '/docs/quick-start'),
    type: 'doc',
  },
  { label: 'Theming', href: localizedHref(lang, '/docs/theming'), type: 'doc' },
  {
    label: 'CLI Setup',
    href: localizedHref(lang, '/docs/cli-setup'),
    type: 'doc',
  },
  {
    label: 'Colors',
    href: localizedHref(lang, '/docs/tokens/colors'),
    type: 'doc',
  },
  {
    label: 'Typography',
    href: localizedHref(lang, '/docs/tokens/typography'),
    type: 'doc',
  },
  {
    label: 'Spacing',
    href: localizedHref(lang, '/docs/tokens/spacing'),
    type: 'doc',
  },
  {
    label: 'Shadows',
    href: localizedHref(lang, '/docs/tokens/shadows'),
    type: 'doc',
  },
  {
    label: 'Accessibility',
    href: localizedHref(lang, '/docs/guides/accessibility'),
    type: 'doc',
  },
  {
    label: 'Copy-Paste Workflow',
    href: localizedHref(lang, '/docs/guides/copy-paste-workflow'),
    type: 'doc',
  },
  {
    label: 'Custom Theme',
    href: localizedHref(lang, '/docs/guides/custom-theme'),
    type: 'doc',
  },
  {
    label: 'Migration',
    href: localizedHref(lang, '/docs/guides/migration'),
    type: 'doc',
  },
  {
    label: 'Responsive Design',
    href: localizedHref(lang, '/docs/guides/responsive-design'),
    type: 'doc',
  },
  ...components.map((component) => ({
    label: component.name,
    href: localizedHref(lang, `/docs/components/${component.slug}`),
    type: 'component' as const,
  })),
];

export function getSearchData(lang: string): SearchItem[] {
  return docItems(lang);
}
