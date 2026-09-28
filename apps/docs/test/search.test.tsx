import { render, screen, fireEvent } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import CustomSearchDialog from '../src/components/search';

// Mock fumadocs-core hooks
const mockSetSearch = vi.fn();
const mockQueryData = { data: 'empty' as any };
const mockUseDocsSearch = vi.fn(() => ({
  search: 'test query',
  setSearch: mockSetSearch,
  query: mockQueryData,
}));
(globalThis as any).mockSetSearch = mockSetSearch;
(globalThis as any).mockQueryData = mockQueryData;

vi.mock('fumadocs-core/search/client', () => ({
  useDocsSearch: (...args: Array<unknown>) =>
    mockUseDocsSearch(...(args as [])),
}));

// Mock fumadocs-ui search components to render simple shells
vi.mock('fumadocs-ui/components/dialog/search', () => ({
  SearchDialog: ({
    children,
    open,
  }: {
    children: React.ReactNode;
    open?: boolean;
  }) => (open ? <div data-testid="search-dialog">{children}</div> : null),
  SearchDialogContent: ({ children }: { children: React.ReactNode }) => (
    <div data-testid="search-content">{children}</div>
  ),
  SearchDialogInput: ({
    placeholder,
    className,
  }: {
    placeholder?: string;
    className?: string;
  }) => (
    <input
      data-testid="search-input"
      placeholder={placeholder}
      className={className}
      onChange={(e) => mockSetSearch(e.target.value)}
    />
  ),
  SearchDialogList: ({
    items,
  }: {
    items?: Array<{ title: string }> | null;
  }) => (
    <div data-testid="search-list">
      {items
        ? items.map((item, idx) => <div key={idx}>{item.title}</div>)
        : 'No items'}
    </div>
  ),
}));

describe('CustomSearchDialog Component', () => {
  it('does not render when open is false', () => {
    const { container } = render(
      <CustomSearchDialog open={false} onOpenChange={() => {}} lang="en" />
    );
    expect(container.firstChild).toBeNull();
  });

  it('renders input and search list when open is true, without overriding the library default placeholder', () => {
    render(
      <CustomSearchDialog open={true} onOpenChange={() => {}} lang="en" />
    );

    // Verify dialog container is in the document
    expect(screen.getByTestId('search-dialog')).toBeInTheDocument();

    // No hardcoded placeholder is passed: SearchDialogInput's own default
    // (fumadocs' `t("Search")`, already localized via layout.shared.tsx)
    // must be left to take over instead of a hand-rolled, locale-blind string.
    const input = screen.getByTestId('search-input');
    expect(input).toBeInTheDocument();
    expect(input).not.toHaveAttribute('placeholder');

    // Verify list renders empty state when data is 'empty'
    expect(screen.getByTestId('search-list')).toHaveTextContent('No items');
  });

  it('filters search results to the active locale', () => {
    render(
      <CustomSearchDialog open={true} onOpenChange={() => {}} lang="id" />
    );
    expect(mockUseDocsSearch).toHaveBeenCalledWith(
      expect.objectContaining({ type: 'fetch', locale: 'id' })
    );
  });

  it('calls setSearch callback when typing in input', () => {
    render(
      <CustomSearchDialog open={true} onOpenChange={() => {}} lang="en" />
    );
    const input = screen.getByTestId('search-input');

    fireEvent.change(input, { target: { value: 'neobrutalism' } });
    expect(mockSetSearch).toHaveBeenCalledWith('neobrutalism');
  });

  it('renders search list with items when query data is not empty', () => {
    mockQueryData.data = [{ title: 'Button Component' }];
    render(
      <CustomSearchDialog open={true} onOpenChange={() => {}} lang="en" />
    );
    expect(screen.getByTestId('search-list')).toHaveTextContent(
      'Button Component'
    );
    // Restore default
    mockQueryData.data = 'empty';
  });
});
