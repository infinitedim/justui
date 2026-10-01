import type { ComponentCategory } from '@/lib/components-data';

/** Interface strings for the component catalog, card and code dialog. */
export interface CatalogUiStrings {
  searchLabel: string;
  searchPlaceholder: string;
  clearSearch: string;
  categoriesLabel: string;
  allCategories: string;
  categories: Readonly<Record<ComponentCategory, string>>;
  /** Shown only while a search or category filter is active. */
  resultCount: (shown: number, total: number) => string;
  noResults: (query: string) => string;
  noResultsInCategory: string;
  resetFilters: string;
  copyCommand: (slug: string) => string;
  copied: string;
  viewCode: string;
  docs: string;
  codeDialogCopy: string;
  codeDialogClose: string;
}

export const catalogUiEn: CatalogUiStrings = {
  searchLabel: 'Search components',
  searchPlaceholder: 'Search components',
  clearSearch: 'Clear search',
  categoriesLabel: 'Category',
  allCategories: 'All',
  categories: {
    primitive: 'Primitives',
    selection: 'Selection',
    layout: 'Layout',
    form: 'Forms',
    navigation: 'Navigation',
    overlay: 'Overlays',
    composite: 'Composite',
  },
  resultCount: (shown, total) => `${shown} of ${total}`,
  noResults: (query) => `Nothing matches "${query}".`,
  noResultsInCategory: 'Nothing in this category.',
  resetFilters: 'Reset filters',
  copyCommand: (slug) => `Copy justui add ${slug}`,
  copied: 'Copied',
  viewCode: 'Code',
  docs: 'Docs',
  codeDialogCopy: 'Copy Dart code',
  codeDialogClose: 'Close',
};

export const catalogUiId: CatalogUiStrings = {
  searchLabel: 'Cari komponen',
  searchPlaceholder: 'Cari komponen',
  clearSearch: 'Hapus pencarian',
  categoriesLabel: 'Kategori',
  allCategories: 'Semua',
  categories: {
    primitive: 'Primitif',
    selection: 'Pilihan',
    layout: 'Tata letak',
    form: 'Form',
    navigation: 'Navigasi',
    overlay: 'Overlay',
    composite: 'Komposit',
  },
  resultCount: (shown, total) => `${shown} dari ${total}`,
  noResults: (query) => `Tidak ada yang cocok dengan "${query}".`,
  noResultsInCategory: 'Belum ada komponen di kategori ini.',
  resetFilters: 'Reset filter',
  copyCommand: (slug) => `Salin justui add ${slug}`,
  copied: 'Tersalin',
  viewCode: 'Kode',
  docs: 'Docs',
  codeDialogCopy: 'Salin kode Dart',
  codeDialogClose: 'Tutup',
};
