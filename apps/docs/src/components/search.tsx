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
      <SearchDialogContent className="max-w-2xl rounded-lg border border-slate-200 bg-white shadow-lg dark:border-slate-800 dark:bg-slate-900">
        <SearchDialogInput
          placeholder="Cari dokumentasi..."
          className="w-full border-b border-slate-200 px-4 py-3 text-lg focus:outline-none dark:border-slate-800"
        />
        <SearchDialogList
          items={query.data !== 'empty' ? query.data : null}
          className="max-h-[400px] overflow-y-auto p-2"
        />
      </SearchDialogContent>
    </SearchDialog>
  );
}
