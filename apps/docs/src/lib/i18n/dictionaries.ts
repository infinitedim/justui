import {
  type HomepageDictionary,
  getHomepageDictionary,
} from '@/lib/homepage-translations';
import {
  type StudioDictionary,
  getStudioDictionary,
} from '@/lib/theme-studio-translations';

export {
  type HomepageDictionary,
  getHomepageDictionary,
  type StudioDictionary,
  getStudioDictionary,
};

export interface AppDictionary extends HomepageDictionary, StudioDictionary {}

export function getDictionary(lang: string): AppDictionary {
  return {
    ...getHomepageDictionary(lang),
    ...getStudioDictionary(lang),
  };
}

