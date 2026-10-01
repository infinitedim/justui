import { render, screen, fireEvent } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { MicroSimulator } from '@/components/organisms/simulators/micro-simulator';
import { SIMULATOR_REGISTRY } from '@/components/organisms/simulators/simulator-registry';
import { components } from '@/lib/components-data';

describe('Micro-Simulator System (33 Mocks)', () => {
  it('contains all 33 public components in the simulator registry', () => {
    expect(Object.keys(SIMULATOR_REGISTRY)).toHaveLength(33);
    for (const comp of components) {
      expect(SIMULATOR_REGISTRY).toHaveProperty(comp.slug);
    }
  });

  it('renders every mock in both presets, applying the preset as a token scope', () => {
    for (const comp of components) {
      const { container: defContainer, unmount: defUnmount } = render(
        <MicroSimulator slug={comp.slug} preset="default" />
      );
      expect(
        defContainer.querySelector('[data-testid="simulator-harness"]')
      ).toHaveAttribute('data-preset', 'default');
      defUnmount();

      const { container: neoContainer, unmount: neoUnmount } = render(
        <MicroSimulator slug={comp.slug} preset="neobrutalism" />
      );
      const neoHarness = neoContainer.querySelector(
        '[data-testid="simulator-harness"]'
      );
      expect(neoHarness).toHaveAttribute('data-preset', 'neobrutalism');
      expect(neoHarness).toHaveClass('theme-neobrutalism');
      neoUnmount();
    }
  });

  it('keeps preset-specific styling out of the mocks (tokens only)', () => {
    for (const comp of components) {
      const { container, unmount } = render(
        <MicroSimulator slug={comp.slug} preset="neobrutalism" />
      );
      const html = container.innerHTML;
      expect(html).not.toMatch(/border-black|#000\]|shadow-\[\d/);
      expect(html).not.toMatch(/text-\[(9|10|11)px\]/);
      expect(container.querySelector('.animate-pulse')).toBeNull();
      unmount();
    }
  });

  it('verifies ButtonMock counter interaction', () => {
    render(<MicroSimulator slug="button" preset="default" />);
    const btn = screen.getByTestId('mock-button');
    expect(btn).toHaveTextContent('Add to cart');

    fireEvent.click(btn);
    expect(btn).toHaveTextContent('In cart (1)');
    fireEvent.click(btn);
    expect(btn).toHaveTextContent('In cart (2)');
  });

  it('verifies SwitchMock toggle interaction', () => {
    render(<MicroSimulator slug="switch" preset="default" />);
    const sw = screen.getByTestId('mock-switch');
    expect(sw).toHaveAttribute('aria-checked', 'true');

    fireEvent.click(sw);
    expect(sw).toHaveAttribute('aria-checked', 'false');
    fireEvent.click(sw);
    expect(sw).toHaveAttribute('aria-checked', 'true');
  });

  it('verifies CheckboxMock toggle interaction', () => {
    render(<MicroSimulator slug="checkbox" preset="default" />);
    const cb = screen.getByTestId('mock-checkbox');
    expect(cb).toHaveAttribute('aria-checked', 'true');
    expect(cb.querySelector('svg')).toBeInTheDocument();

    fireEvent.click(cb);
    expect(cb).toHaveAttribute('aria-checked', 'false');
    expect(cb.querySelector('svg')).not.toBeInTheDocument();
  });

  it('verifies AccordionMock expand and collapse interaction', () => {
    render(<MicroSimulator slug="accordion" preset="default" />);
    const acc = screen.getByTestId('mock-accordion');
    expect(
      screen.queryByText(/until the order is packed/i)
    ).not.toBeInTheDocument();

    const trigger = acc.querySelector('button');
    fireEvent.click(trigger!);
    expect(screen.getByText(/until the order is packed/i)).toBeInTheDocument();

    fireEvent.click(trigger!);
    expect(
      screen.queryByText(/until the order is packed/i)
    ).not.toBeInTheDocument();
  });

  it('verifies ToastMock trigger interaction', () => {
    render(<MicroSimulator slug="toast" preset="default" />);
    expect(screen.queryByTestId('mock-toast-popup')).not.toBeInTheDocument();

    const trigger = screen.getByTestId('mock-toast-trigger');
    fireEvent.click(trigger);
    expect(screen.getByTestId('mock-toast-popup')).toBeInTheDocument();
  });

  it('verifies DialogMock open and close interaction', () => {
    render(<MicroSimulator slug="dialog" preset="default" />);
    expect(screen.queryByTestId('mock-dialog-content')).not.toBeInTheDocument();

    const trigger = screen.getByTestId('mock-dialog-trigger');
    fireEvent.click(trigger);
    expect(screen.getByTestId('mock-dialog-content')).toBeInTheDocument();

    const confirmBtn = screen.getByRole('button', { name: 'Remove' });
    fireEvent.click(confirmBtn);
    expect(screen.queryByTestId('mock-dialog-content')).not.toBeInTheDocument();
  });

  it('verifies SheetMock open and close interaction', () => {
    render(<MicroSimulator slug="sheet" preset="default" />);
    expect(screen.queryByTestId('mock-sheet-panel')).not.toBeInTheDocument();

    const trigger = screen.getByTestId('mock-sheet-trigger');
    fireEvent.click(trigger);
    expect(screen.getByTestId('mock-sheet-panel')).toBeInTheDocument();

    const dismissBtn = screen.getByRole('button', { name: 'Apply' });
    fireEvent.click(dismissBtn);
    expect(screen.queryByTestId('mock-sheet-panel')).not.toBeInTheDocument();
  });

  it('verifies TooltipMock hover and click interaction', () => {
    render(<MicroSimulator slug="tooltip" preset="default" />);
    expect(screen.queryByTestId('mock-tooltip-bubble')).not.toBeInTheDocument();

    const trigger = screen.getByTestId('mock-tooltip-trigger');
    fireEvent.mouseEnter(trigger);
    expect(screen.getByTestId('mock-tooltip-bubble')).toBeInTheDocument();

    fireEvent.mouseLeave(trigger);
    expect(screen.queryByTestId('mock-tooltip-bubble')).not.toBeInTheDocument();
  });
});
