'use client';

import { useDocsSearch } from 'fumadocs-core/search/client';
import { useI18n } from 'fumadocs-ui/contexts/i18n';
import {
  SearchDialog,
  SearchDialogContent,
  SearchDialogInput,
  SearchDialogList,
} from 'fumadocs-ui/components/dialog/search';

interface SharedProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  /** Defaults to the fumadocs i18n locale of the page. */
  lang?: string;
}

export function CustomSearchDialog({ lang, ...props }: SharedProps) {
  const { locale } = useI18n();
  // No `placeholder`/"no results" text here: SearchDialogInput/List already
  // default to fumadocs' own translated strings (t("Search"), "No results
  // found"), which layout.shared.tsx already registers an Indonesian
  // override for. Overriding them here would hardcode a single locale.
  const { search, setSearch, query } = useDocsSearch({
    type: 'fetch',
    locale: lang ?? locale,
  });

  return (
    <SearchDialog search={search} onSearchChange={setSearch} {...props}>
      <SearchDialogContent className="border-border bg-card max-w-2xl rounded-lg border [border-width:var(--just-border-width)] [box-shadow:var(--just-shadow-solid)]">
        <SearchDialogInput className="border-border bg-card text-foreground placeholder:text-muted w-full border-b [border-bottom-width:var(--just-border-width)] px-4 py-3 text-lg focus:outline-none" />
        <SearchDialogList
          items={query.data !== 'empty' ? query.data : null}
          className="max-h-100 overflow-y-auto p-2"
        />
      </SearchDialogContent>
    </SearchDialog>
  );
}
