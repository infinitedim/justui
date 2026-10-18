import type { ReactNode } from 'react';
import type { KitDictionary } from '@/lib/kit-translations';

/** Renders one part's default demo. `uid` keeps radio names unique. */
export type KitPartRenderer = (t: KitDictionary, uid: string) => ReactNode;

export interface KitPartProps {
  slug: string;
  t: KitDictionary;
  /** Unique per rendered part on the page. */
  uid: string;
}
