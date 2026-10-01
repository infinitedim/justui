import { render, screen, fireEvent } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { ComponentsCatalogClient } from '@/app/[lang]/components/components-catalog-client';
import { components } from '@/lib/components-data';
import { getHomepageDictionary } from '@/lib/homepage-translations';
import { PresetProvider, usePreset } from '@/components/providers';

function PresetSetter() {
  const { setPreset } = usePreset();
  return (
    <button type="button" onClick={() => setPreset('neobrutalism')}>
      navbar preset
    </button>
  );
}

describe('Living Component Catalog', () => {
  const dictionary = getHomepageDictionary('en');

  function renderCatalog(lang = 'en') {
    return render(
      <PresetProvider>
        <PresetSetter />
        <ComponentsCatalogClient
          components={components}
          lang={lang}
          dictionary={getHomepageDictionary(lang)}
        />
      </PresetProvider>
    );
  }

  it('renders all 33 components without a redundant result counter', () => {
    renderCatalog();

    expect(screen.getByTestId('components-grid').children).toHaveLength(33);
    expect(screen.queryByText(/^Showing/)).not.toBeInTheDocument();
    expect(
      screen.getByTestId('living-component-card-table')
    ).toBeInTheDocument();
  });

  it('filters by search query and shows the count only while filtering', () => {
    renderCatalog();

    fireEvent.change(screen.getByTestId('catalog-search-input'), {
      target: { value: 'JustSwitch' },
    });

    expect(screen.getByText('Showing 1 of 33')).toBeInTheDocument();
    expect(
      screen.getByTestId('living-component-card-switch')
    ).toBeInTheDocument();
    expect(
      screen.queryByTestId('living-component-card-button')
    ).not.toBeInTheDocument();
  });

  it('filters by category, with no count badges on the category buttons', () => {
    renderCatalog();

    const selection = screen.getByRole('button', { name: 'Selection' });
    fireEvent.click(selection);

    expect(selection).toHaveAttribute('aria-pressed', 'true');
    expect(screen.getByText('Showing 3 of 33')).toBeInTheDocument();
    expect(
      screen.getByTestId('living-component-card-checkbox')
    ).toBeInTheDocument();
  });

  it('localizes categories and the search placeholder', () => {
    renderCatalog('id');

    expect(screen.getByRole('button', { name: 'Pilihan' })).toBeInTheDocument();
    expect(screen.getByTestId('catalog-search-input')).toHaveAttribute(
      'placeholder',
      'Cari komponen'
    );
  });

  it('shows a one-line empty state naming the query, with a reset link', () => {
    renderCatalog();

    fireEvent.change(screen.getByTestId('catalog-search-input'), {
      target: { value: 'nonexistent-xyz' },
    });

    expect(screen.getByTestId('catalog-empty-state')).toHaveTextContent(
      "Nothing matches 'nonexistent-xyz'."
    );

    fireEvent.click(
      screen.getByRole('button', { name: dictionary.catalogResetFilters })
    );
    expect(screen.getByTestId('components-grid').children).toHaveLength(33);
  });

  it('follows the site-wide preset instead of keeping its own switcher', () => {
    renderCatalog();

    expect(screen.queryByTestId('catalog-preset-toggle')).toBeNull();
    const harness = () =>
      screen
        .getByTestId('living-component-card-button')
        .querySelector('[data-testid="simulator-harness"]');
    expect(harness()).toHaveAttribute('data-preset', 'default');

    fireEvent.click(screen.getByRole('button', { name: 'navbar preset' }));
    expect(harness()).toHaveAttribute('data-preset', 'neobrutalism');
    expect(harness()).toHaveClass('theme-neobrutalism');
  });

  it('links each card to its docs and offers the CLI command as the main action', () => {
    renderCatalog();

    const card = screen.getByTestId('living-component-card-button');
    expect(screen.getByRole('link', { name: 'JustButton' })).toHaveAttribute(
      'href',
      '/en/docs/components/button'
    );
    expect(card).toHaveTextContent('justui add button');
    expect(card.querySelector('.font-mono.text-sm.font-bold')).toBeNull();
  });

  it('opens and closes the Dart example via button, backdrop click and Escape', () => {
    renderCatalog();

    const viewCodeBtn = screen
      .getByTestId('living-component-card-button')
      .querySelector('[data-testid="view-code-button"]');
    expect(viewCodeBtn).toBeInTheDocument();

    fireEvent.click(viewCodeBtn!);
    expect(screen.getByTestId('dart-code-modal')).toBeInTheDocument();
    expect(screen.getByText(/JustButton\(/)).toBeInTheDocument();

    fireEvent.click(screen.getByRole('button', { name: 'Close' }));
    expect(screen.queryByTestId('dart-code-modal')).not.toBeInTheDocument();

    fireEvent.click(viewCodeBtn!);
    fireEvent.keyDown(document, { key: 'Escape' });
    expect(screen.queryByTestId('dart-code-modal')).not.toBeInTheDocument();

    fireEvent.click(viewCodeBtn!);
    fireEvent.click(screen.getByTestId('dart-code-modal'));
    expect(screen.queryByTestId('dart-code-modal')).not.toBeInTheDocument();
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
