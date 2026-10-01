import { render, screen, fireEvent, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { ComponentsCatalogClient } from '@/app/[lang]/components/components-catalog-client';
import { components } from '@/lib/components-data';
import { descriptionsId } from '@/lib/catalog-i18n/descriptions';
import { PresetProvider } from '@/components/providers';

describe('Living Component Catalog', () => {
  function renderCatalog(lang = 'en') {
    return render(
      <PresetProvider>
        <ComponentsCatalogClient components={components} lang={lang} />
      </PresetProvider>
    );
  }

  it('renders every component and no result count while nothing is filtered', () => {
    renderCatalog();

    expect(screen.getByTestId('components-grid')).toBeInTheDocument();
    for (const slug of ['button', 'switch', 'table']) {
      expect(
        screen.getByTestId(`living-component-card-${slug}`)
      ).toBeInTheDocument();
    }
    expect(screen.getAllByRole('article')).toHaveLength(components.length);
    expect(
      screen.queryByTestId('catalog-result-count')
    ).not.toBeInTheDocument();
  });

  it('has no preset control of its own (the navbar owns the preset)', () => {
    renderCatalog();
    expect(
      screen.queryByTestId('catalog-preset-toggle')
    ).not.toBeInTheDocument();
    expect(
      screen.queryByRole('button', { name: /neobrutalism/i })
    ).not.toBeInTheDocument();
  });

  it('filters by search query and shows the count once while filtering', () => {
    renderCatalog();

    fireEvent.change(screen.getByTestId('catalog-search-input'), {
      target: { value: 'JustSwitch' },
    });

    expect(screen.getByTestId('catalog-result-count')).toHaveTextContent(
      `1 of ${components.length}`
    );
    expect(
      screen.getByTestId('living-component-card-switch')
    ).toBeInTheDocument();
    expect(
      screen.queryByTestId('living-component-card-button')
    ).not.toBeInTheDocument();
  });

  it('filters by category chip without count badges', () => {
    renderCatalog();

    const chip = screen.getByRole('button', { name: 'Selection' });
    expect(chip).toHaveTextContent(/^Selection$/);
    fireEvent.click(chip);

    expect(chip).toHaveAttribute('aria-pressed', 'true');
    for (const slug of ['checkbox', 'radio', 'switch']) {
      expect(
        screen.getByTestId(`living-component-card-${slug}`)
      ).toBeInTheDocument();
    }
    expect(
      screen.queryByTestId('living-component-card-button')
    ).not.toBeInTheDocument();
  });

  it('shows a one-line empty state that names the query, with a reset link', () => {
    renderCatalog();

    fireEvent.change(screen.getByTestId('catalog-search-input'), {
      target: { value: 'nonexistent-xyz' },
    });

    const empty = screen.getByTestId('catalog-empty-state');
    expect(empty).toHaveTextContent('Nothing matches "nonexistent-xyz".');

    fireEvent.click(
      within(empty).getByRole('button', { name: 'Reset filters' })
    );
    expect(screen.getAllByRole('article')).toHaveLength(components.length);
  });

  it('links each card to its docs page and offers the install command', () => {
    renderCatalog();

    const card = screen.getByTestId('living-component-card-button');
    expect(
      within(card).getByRole('link', { name: 'JustButton' })
    ).toHaveAttribute('href', '/en/docs/components/button');
    expect(within(card).getByText('justui add button')).toBeInTheDocument();
    expect(
      within(card).getByRole('button', { name: 'Copy justui add button' })
    ).toBeInTheDocument();
  });

  it('renders Indonesian descriptions and labels on /id', () => {
    renderCatalog('id');

    const card = screen.getByTestId('living-component-card-switch');
    expect(
      within(card).getByText(descriptionsId.switch ?? '')
    ).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Semua' })).toBeInTheDocument();
    expect(
      screen.getByRole('searchbox', { name: 'Cari komponen' })
    ).toBeInTheDocument();
  });

  it('opens the Dart code dialog with focus inside and closes via button, Escape and backdrop', () => {
    renderCatalog();

    const card = screen.getByTestId('living-component-card-button');
    const viewCode = within(card).getByTestId('view-code-button');

    fireEvent.click(viewCode);
    const dialog = screen.getByRole('dialog', { name: 'just_button.dart' });
    expect(within(dialog).getByText(/JustButton\(/)).toBeInTheDocument();
    const close = within(dialog).getByRole('button', { name: 'Close' });
    expect(close).toHaveFocus();

    fireEvent.click(close);
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
    expect(viewCode).toHaveFocus();

    fireEvent.click(viewCode);
    fireEvent.keyDown(document, { key: 'Escape' });
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();

    fireEvent.click(viewCode);
    fireEvent.click(screen.getByTestId('dart-code-modal-backdrop'));
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
  });

  it('handles hotkeys "/" and "Escape"', () => {
    renderCatalog();

    const searchInput = screen.getByTestId('catalog-search-input');
    fireEvent.keyDown(window, { key: '/' });
    expect(document.activeElement).toBe(searchInput);

    fireEvent.change(searchInput, { target: { value: 'card' } });
    fireEvent.keyDown(window, { key: 'Escape' });
    expect(searchInput).toHaveValue('');
  });
});
