'use client';

import { useDocsSearch } from 'fumadocs-core/search/client';
import {
  SearchDialog,
  SearchDialogContent,
  SearchDialogInput,
  SearchDialogList,
} from 'fumadocs-ui/components/dialog/search';

interface SharedProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export default function CustomSearchDialog(props: SharedProps) {
  const { search, setSearch, query } = useDocsSearch({ type: 'fetch' });

  return (
    <SearchDialog search={search} onSearchChange={setSearch} {...props}>
      <SearchDialogContent className="border-border bg-card max-w-2xl rounded-lg border [border-width:var(--just-border-width)] [box-shadow:var(--just-shadow-solid)]">
        <SearchDialogInput
          placeholder="Cari dokumentasi..."
          className="border-border bg-card text-foreground placeholder:text-muted w-full border-b [border-bottom-width:var(--just-border-width)] px-4 py-3 text-lg focus:outline-none"
        />
        <SearchDialogList
          items={query.data !== 'empty' ? query.data : null}
          className="max-h-100 overflow-y-auto p-2"
        />
      </SearchDialogContent>
    </SearchDialog>
  );
}
