import type { ComponentsPageDictionary } from '@/lib/components-page-translations';
import type { Locale } from '@/lib/i18n';
import type { KitDictionary } from '@/lib/kit-translations';
import type { PartGroup } from '@/lib/part-groups';

export interface PartsIndexProps {
  lang: Locale;
}

/** Copy every cell needs, resolved once per page. */
export interface PartCopy {
  lang: Locale;
  page: ComponentsPageDictionary;
  kit: KitDictionary;
  copied: string;
}

export interface PartRunnerProps {
  group: PartGroup;
  copy: PartCopy;
}

export interface PartCellProps {
  slug: string;
  copy: PartCopy;
}
