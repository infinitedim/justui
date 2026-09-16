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

  it('renders every single mock in default and neobrutalism presets without error', () => {
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
      expect(
        neoContainer.querySelector('[data-testid="simulator-harness"]')
      ).toHaveAttribute('data-preset', 'neobrutalism');
      neoUnmount();
    }
  });

  it('verifies ButtonMock counter interaction', () => {
    render(<MicroSimulator slug="button" preset="default" />);
    const btn = screen.getByTestId('mock-button');
    expect(btn).toHaveTextContent('Click Me');

    fireEvent.click(btn);
    expect(btn).toHaveTextContent('Click Me (1)');
    fireEvent.click(btn);
    expect(btn).toHaveTextContent('Click Me (2)');
  });

  it('verifies SwitchMock toggle interaction', () => {
    render(<MicroSimulator slug="switch" preset="default" />);
    const sw = screen.getByTestId('mock-switch');
    expect(sw).toHaveTextContent('Active');

    fireEvent.click(sw);
    expect(sw).toHaveTextContent('Inactive');
    fireEvent.click(sw);
    expect(sw).toHaveTextContent('Active');
  });

  it('verifies CheckboxMock toggle interaction', () => {
    render(<MicroSimulator slug="checkbox" preset="default" />);
    const cb = screen.getByTestId('mock-checkbox');
    expect(cb.querySelector('svg')).toBeInTheDocument(); // Checked has check icon

    fireEvent.click(cb);
    expect(cb.querySelector('svg')).not.toBeInTheDocument(); // Unchecked
  });

  it('verifies AccordionMock expand and collapse interaction', () => {
    render(<MicroSimulator slug="accordion" preset="default" />);
    const acc = screen.getByTestId('mock-accordion');
    expect(
      screen.queryByText(/All widgets are copied/i)
    ).not.toBeInTheDocument();

    const trigger = acc.querySelector('button');
    fireEvent.click(trigger!);
    expect(screen.getByText(/All widgets are copied/i)).toBeInTheDocument();

    fireEvent.click(trigger!);
    expect(
      screen.queryByText(/All widgets are copied/i)
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

    const confirmBtn = screen.getByRole('button', { name: 'Confirm' });
    fireEvent.click(confirmBtn);
    expect(screen.queryByTestId('mock-dialog-content')).not.toBeInTheDocument();
  });

  it('verifies SheetMock open and close interaction', () => {
    render(<MicroSimulator slug="sheet" preset="default" />);
    expect(screen.queryByTestId('mock-sheet-panel')).not.toBeInTheDocument();

    const trigger = screen.getByTestId('mock-sheet-trigger');
    fireEvent.click(trigger);
    expect(screen.getByTestId('mock-sheet-panel')).toBeInTheDocument();

    const dismissBtn = screen.getByRole('button', { name: 'Dismiss' });
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
