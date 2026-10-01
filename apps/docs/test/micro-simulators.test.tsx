import { render, screen, fireEvent, within } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { MicroSimulator } from '@/components/organisms/simulators/micro-simulator';
import { SIMULATOR_REGISTRY } from '@/components/organisms/simulators/simulator-registry';
import { SwitchMock } from '@/components/organisms/simulators/preview-mocks/switch-mock';
import { CatalogI18nProvider } from '@/lib/catalog-i18n/context';
import { components } from '@/lib/components-data';

describe('Micro-Simulator System (33 Mocks)', () => {
  it('contains all 33 public components in the simulator registry', () => {
    expect(Object.keys(SIMULATOR_REGISTRY)).toHaveLength(33);
    for (const comp of components) {
      expect(SIMULATOR_REGISTRY).toHaveProperty(comp.slug);
    }
  });

  it('renders every mock in both locales without error', () => {
    for (const lang of ['en', 'id']) {
      for (const comp of components) {
        const { container, unmount } = render(
          <CatalogI18nProvider lang={lang}>
            <MicroSimulator slug={comp.slug} />
          </CatalogI18nProvider>
        );
        expect(
          container.querySelector('[data-testid="simulator-harness"]')
        ).toBeInTheDocument();
        unmount();
      }
    }
  });

  it('ButtonMock logs calls', () => {
    render(<MicroSimulator slug="button" />);
    const btn = screen.getByTestId('mock-button');
    expect(btn).toHaveTextContent('Log call');

    fireEvent.click(btn);
    expect(screen.getByText('1 call logged today')).toBeInTheDocument();
    fireEvent.click(btn);
    expect(screen.getByText('2 calls logged today')).toBeInTheDocument();
  });

  it('SwitchMock is a real switch and reports each toggle', () => {
    const onToggle = vi.fn();
    render(<SwitchMock onToggle={onToggle} />);
    const sw = screen.getByRole('switch', { name: 'Follow-up reminders' });
    expect(sw).toHaveAttribute('aria-checked', 'true');
    expect(screen.getByText('On')).toBeInTheDocument();

    fireEvent.click(sw);
    expect(sw).toHaveAttribute('aria-checked', 'false');
    expect(screen.getByText('Off')).toBeInTheDocument();
    expect(onToggle).toHaveBeenLastCalledWith(false);
  });

  it('CheckboxMock toggles aria-checked and its icon', () => {
    render(<MicroSimulator slug="checkbox" />);
    const cb = screen.getByRole('checkbox', {
      name: 'Send proposal to Hotel Arunika',
    });
    expect(cb).toHaveAttribute('aria-checked', 'true');
    expect(cb.querySelector('svg')).toBeInTheDocument();

    fireEvent.click(cb);
    expect(cb).toHaveAttribute('aria-checked', 'false');
    expect(cb.querySelector('svg')).not.toBeInTheDocument();
  });

  it('RadioMock uses native radios', () => {
    render(<MicroSimulator slug="radio" />);
    const email = screen.getByRole('radio', { name: 'Email' });
    expect(screen.getByRole('radio', { name: 'Phone' })).toBeChecked();
    fireEvent.click(email);
    expect(email).toBeChecked();
  });

  it('AccordionMock expands and collapses with aria-expanded', () => {
    render(<MicroSimulator slug="accordion" />);
    const trigger = within(screen.getByTestId('mock-accordion')).getByRole(
      'button',
      { name: 'Company' }
    );
    expect(screen.queryByText(/4 outlets in Bandung/)).not.toBeInTheDocument();

    fireEvent.click(trigger);
    expect(trigger).toHaveAttribute('aria-expanded', 'true');
    expect(screen.getByText(/4 outlets in Bandung/)).toBeInTheDocument();

    fireEvent.click(trigger);
    expect(screen.queryByText(/4 outlets in Bandung/)).not.toBeInTheDocument();
  });

  it('ToastMock shows a status message', () => {
    render(<MicroSimulator slug="toast" />);
    expect(screen.queryByTestId('mock-toast-popup')).not.toBeInTheDocument();

    fireEvent.click(screen.getByTestId('mock-toast-trigger'));
    expect(screen.getByRole('status')).toHaveTextContent('Deal moved to Won');
  });

  it('DialogMock opens on the safe choice and closes', () => {
    render(<MicroSimulator slug="dialog" />);
    expect(screen.queryByTestId('mock-dialog-content')).not.toBeInTheDocument();

    fireEvent.click(screen.getByTestId('mock-dialog-trigger'));
    expect(
      screen.getByRole('alertdialog', { name: 'Delete this contact?' })
    ).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Cancel' })).toHaveFocus();

    fireEvent.click(screen.getByRole('button', { name: 'Delete' }));
    expect(screen.queryByTestId('mock-dialog-content')).not.toBeInTheDocument();
  });

  it('SheetMock opens and closes', () => {
    render(<MicroSimulator slug="sheet" />);
    expect(screen.queryByTestId('mock-sheet-panel')).not.toBeInTheDocument();

    fireEvent.click(screen.getByTestId('mock-sheet-trigger'));
    expect(screen.getByTestId('mock-sheet-panel')).toBeInTheDocument();

    fireEvent.click(screen.getByRole('button', { name: 'Close' }));
    expect(screen.queryByTestId('mock-sheet-panel')).not.toBeInTheDocument();
  });

  it('TooltipMock opens on hover and on keyboard focus', () => {
    render(<MicroSimulator slug="tooltip" />);
    const trigger = screen.getByTestId('mock-tooltip-trigger');

    fireEvent.mouseEnter(trigger);
    expect(screen.getByRole('tooltip')).toHaveTextContent(
      'Called 3 days ago by Dewi'
    );
    fireEvent.mouseLeave(trigger);
    expect(screen.queryByRole('tooltip')).not.toBeInTheDocument();

    fireEvent.focus(trigger);
    expect(screen.getByRole('tooltip')).toBeInTheDocument();
    fireEvent.keyDown(trigger, { key: 'Escape' });
    expect(screen.queryByRole('tooltip')).not.toBeInTheDocument();
  });

  it('renders Indonesian CRM copy under CatalogI18nProvider lang="id"', () => {
    render(
      <CatalogI18nProvider lang="id">
        <MicroSimulator slug="button" />
      </CatalogI18nProvider>
    );
    expect(screen.getByTestId('mock-button')).toHaveTextContent(
      'Catat panggilan'
    );
  });
});
