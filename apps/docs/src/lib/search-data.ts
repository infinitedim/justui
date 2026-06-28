import { components } from '@/lib/components-data';

export type SearchItem = {
  label: string;
  href: string;
  type: 'component' | 'doc';
};

const docItems = (lang: string): SearchItem[] => [
  { label: 'Introduction', href: `/${lang}/docs/introduction`, type: 'doc' },
  { label: 'Installation', href: `/${lang}/docs/installation`, type: 'doc' },
  { label: 'Quick Start', href: `/${lang}/docs/quick-start`, type: 'doc' },
  { label: 'Theming', href: `/${lang}/docs/theming`, type: 'doc' },
  { label: 'CLI Setup', href: `/${lang}/docs/cli-setup`, type: 'doc' },
  { label: 'Colors', href: `/${lang}/docs/tokens/colors`, type: 'doc' },
  { label: 'Typography', href: `/${lang}/docs/tokens/typography`, type: 'doc' },
  { label: 'Spacing', href: `/${lang}/docs/tokens/spacing`, type: 'doc' },
  { label: 'Shadows', href: `/${lang}/docs/tokens/shadows`, type: 'doc' },
  {
    label: 'Accessibility',
    href: `/${lang}/docs/guides/accessibility`,
    type: 'doc',
  },
  {
    label: 'Copy-Paste Workflow',
    href: `/${lang}/docs/guides/copy-paste-workflow`,
    type: 'doc',
  },
  {
    label: 'Custom Theme',
    href: `/${lang}/docs/guides/custom-theme`,
    type: 'doc',
  },
  { label: 'Migration', href: `/${lang}/docs/guides/migration`, type: 'doc' },
  {
    label: 'Responsive Design',
    href: `/${lang}/docs/guides/responsive-design`,
    type: 'doc',
  },
  ...components.map((component) => ({
    label: component.name,
    href: `/${lang}/docs/components/${component.slug}`,
    type: 'component' as const,
  })),
];

export function getSearchData(lang: string): SearchItem[] {
  return docItems(lang);
}

export const searchData = docItems('en');
