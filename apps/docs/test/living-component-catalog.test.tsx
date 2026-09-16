import { render, screen, fireEvent } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { ComponentsCatalogClient } from '@/app/[lang]/components/components-catalog-client';
import { components } from '@/lib/components-data';
import { getHomepageDictionary } from '@/lib/homepage-translations';
import { PresetProvider } from '@/lib/preset-context';

describe('Living Component Catalog', () => {
  const dictionary = getHomepageDictionary('en');

  function renderCatalog() {
    return render(
      <PresetProvider>
        <ComponentsCatalogClient
          components={components}
          lang="en"
          dictionary={dictionary}
        />
      </PresetProvider>
    );
  }

  it('renders all 33 components initially', () => {
    renderCatalog();

    expect(
      screen.getByTestId('components-catalog-container')
    ).toBeInTheDocument();
    expect(screen.getByTestId('components-grid')).toBeInTheDocument();
    expect(screen.getByText('Showing 33 of 33 components')).toBeInTheDocument();

    // Verify key component cards appear
    expect(
      screen.getByTestId('living-component-card-button')
    ).toBeInTheDocument();
    expect(
      screen.getByTestId('living-component-card-switch')
    ).toBeInTheDocument();
    expect(
      screen.getByTestId('living-component-card-table')
    ).toBeInTheDocument();
  });

  it('filters components by search query', () => {
    renderCatalog();

    const searchInput = screen.getByTestId('catalog-search-input');
    fireEvent.change(searchInput, { target: { value: 'JustSwitch' } });

    expect(screen.getByText('Showing 1 of 33 components')).toBeInTheDocument();
    expect(
      screen.getByTestId('living-component-card-switch')
    ).toBeInTheDocument();
    expect(
      screen.queryByTestId('living-component-card-button')
    ).not.toBeInTheDocument();
  });

  it('filters components by category', () => {
    renderCatalog();

    // Selection has 3 components: checkbox, radio, switch
    const selectionPill = screen.getByRole('button', { name: /selection/i });
    fireEvent.click(selectionPill);

    expect(screen.getByText('Showing 3 of 33 components')).toBeInTheDocument();
    expect(
      screen.getByTestId('living-component-card-checkbox')
    ).toBeInTheDocument();
    expect(
      screen.getByTestId('living-component-card-radio')
    ).toBeInTheDocument();
    expect(
      screen.getByTestId('living-component-card-switch')
    ).toBeInTheDocument();
    expect(
      screen.queryByTestId('living-component-card-button')
    ).not.toBeInTheDocument();
  });

  it('shows empty state when no components match search', () => {
    renderCatalog();

    const searchInput = screen.getByTestId('catalog-search-input');
    fireEvent.change(searchInput, {
      target: { value: 'nonexistent-xyz-query' },
    });

    expect(screen.getByTestId('catalog-empty-state')).toBeInTheDocument();
    expect(screen.getByText(dictionary.catalogNoResults)).toBeInTheDocument();

    // Clicking reset button clears search
    const resetButtons = screen.getAllByRole('button', {
      name: dictionary.catalogResetFilters,
    });
    fireEvent.click(resetButtons[0]);

    expect(screen.getByText('Showing 33 of 33 components')).toBeInTheDocument();
  });

  it('switches preset between default and neobrutalism', () => {
    renderCatalog();

    const neoBtn = screen.getByTestId('preset-btn-neobrutalism');
    fireEvent.click(neoBtn);

    // Button card should adapt to neobrutalism preset
    const buttonHarness = screen
      .getByTestId('living-component-card-button')
      .querySelector('[data-testid="simulator-harness"]');
    expect(buttonHarness).toHaveAttribute('data-preset', 'neobrutalism');

    const cleanBtn = screen.getByTestId('preset-btn-default');
    fireEvent.click(cleanBtn);
    expect(buttonHarness).toHaveAttribute('data-preset', 'default');
  });

  it('opens and closes the Dart code modal via button, backdrop click, and Escape', () => {
    renderCatalog();

    const buttonCard = screen.getByTestId('living-component-card-button');
    const viewCodeBtn = buttonCard.querySelector(
      '[data-testid="view-code-button"]'
    );
    expect(viewCodeBtn).toBeInTheDocument();

    fireEvent.click(viewCodeBtn!);
    expect(screen.getByTestId('dart-code-modal')).toBeInTheDocument();
    expect(screen.getByText(/JustButton\(/)).toBeInTheDocument();

    // Close modal via close button
    const closeBtn = screen.getByRole('button', { name: 'Close modal' });
    fireEvent.click(closeBtn);
    expect(screen.queryByTestId('dart-code-modal')).not.toBeInTheDocument();

    // Reopen and close via Escape key
    fireEvent.click(viewCodeBtn!);
    expect(screen.getByTestId('dart-code-modal')).toBeInTheDocument();
    fireEvent.keyDown(document, { key: 'Escape' });
    expect(screen.queryByTestId('dart-code-modal')).not.toBeInTheDocument();

    // Reopen and close via backdrop click
    fireEvent.click(viewCodeBtn!);
    const modalBackdrop = screen.getByTestId('dart-code-modal');
    fireEvent.click(modalBackdrop);
    expect(screen.queryByTestId('dart-code-modal')).not.toBeInTheDocument();
  });

  it('handles hotkeys "/" and "Escape"', () => {
    renderCatalog();

    const searchInput = screen.getByTestId('catalog-search-input');

    // Press "/"
    fireEvent.keyDown(window, { key: '/' });
    expect(document.activeElement).toBe(searchInput);

    // Type text and press Escape
    fireEvent.change(searchInput, { target: { value: 'card' } });
    expect(searchInput).toHaveValue('card');

    fireEvent.keyDown(window, { key: 'Escape' });
    expect(searchInput).toHaveValue('');
  });
});
