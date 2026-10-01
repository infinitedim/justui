import { render, screen, fireEvent } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { LivingStage } from '@/components/organisms/living-stage';

const widget = (component: string) => ({
  id: `widget-${component}`,
  component,
  mountedAt: Date.now(),
});

describe('LivingStage', () => {
  it('shows a one-line empty state when nothing is mounted', () => {
    render(<LivingStage widgets={[]} />);
    expect(
      screen.getByText(
        'Nothing added yet. Run justui add <name> in the terminal.'
      )
    ).toBeInTheDocument();
  });

  it('has a toolbar of view tabs and viewport only: no live dot, theme pill, tip or clear', () => {
    const { container } = render(
      <LivingStage widgets={[widget('button')]} preset="neobrutalism" />
    );

    expect(container.querySelector('.animate-ping')).toBeNull();
    expect(screen.queryByText(/Theme:/)).not.toBeInTheDocument();
    expect(screen.queryByText(/^Tip:/)).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Clear' })).toBeNull();
    expect(screen.getByRole('tab', { name: 'Preview' })).toBeInTheDocument();
    expect(
      screen.getByRole('tab', { name: 'widget.dart' })
    ).toBeInTheDocument();
  });

  it('renders the same mock as the catalog for a mounted component', () => {
    render(<LivingStage widgets={[widget('switch')]} />);
    expect(screen.getByTestId('mock-switch')).toHaveAttribute('role', 'switch');
  });

  it('constrains the preview width when the mobile viewport is chosen', () => {
    const { container } = render(<LivingStage widgets={[]} />);

    fireEvent.click(screen.getByRole('radio', { name: /mobile viewport/i }));

    expect(container.querySelector('.max-w-\\[375px\\]')).toBeInTheDocument();
  });

  it('shows the catalog Dart snippet in the widget.dart tab', () => {
    render(<LivingStage widgets={[widget('button')]} />);

    fireEvent.click(screen.getByRole('tab', { name: 'widget.dart' }));

    expect(screen.getByText(/JustButton\(/)).toBeInTheDocument();
    expect(screen.getByText(/variant: \.primary/)).toBeInTheDocument();
  });

  it('generates a fallback constructor for unknown components', () => {
    render(<LivingStage widgets={[widget('custom-widget')]} />);

    fireEvent.click(screen.getByRole('tab', { name: 'widget.dart' }));

    expect(screen.getByText(/JustCustomWidget\(\)/)).toBeInTheDocument();
  });

  it('dispatches justui-mounted telemetry for mounted widgets', () => {
    const windowSpy = vi.spyOn(window, 'postMessage');
    render(<LivingStage widgets={[widget('card')]} />);

    expect(windowSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        type: 'justui-mounted',
        component: 'card',
        success: true,
      }),
      window.location.origin
    );
  });
});
