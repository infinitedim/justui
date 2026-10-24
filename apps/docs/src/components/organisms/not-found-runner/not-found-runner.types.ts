import type { Locale } from '@/lib/i18n';
import type { KitDictionary } from '@/lib/kit-translations';
import type { NotFoundDictionary } from '@/lib/not-found-translations';
import type { SiteDictionary } from '@/lib/site-translations';

export interface RunnerFieldProps {
  /** The nearest real parts, best match first. */
  parts: readonly string[];
  /** Locale of the page, for the live parts' copy. */
  lang: Locale;
  t: NotFoundDictionary;
  kit: KitDictionary;
  site: SiteDictionary;
}

export interface MissingSocketProps {
  /** Label after the code on the empty gate. */
  missing: string;
}

export interface NearestPartProps {
  slug: string;
  /** Locale of the page, for the live part's copy. */
  lang: Locale;
  kit: KitDictionary;
  site: SiteDictionary;
}

export interface PartLookupFieldProps {
  /** What the visitor typed, or the part name taken from the path. */
  value: string;
  onChange: (value: string) => void;
  t: NotFoundDictionary;
}

export interface NotFoundStatementProps {
  /** The requested path; '' until the page knows it. */
  path: string;
  t: NotFoundDictionary;
}

export interface NotFoundExitsProps {
  lang: Locale;
  t: NotFoundDictionary;
}
