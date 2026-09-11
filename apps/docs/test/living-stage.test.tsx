import { render, screen, fireEvent } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { LivingStage } from '@/components/organisms/living-stage';

describe('LivingStage', () => {
  it('shows empty state placeholder when no widgets are mounted', () => {
    render(<LivingStage widgets={[]} />);
    expect(
      screen.getByText(
        'Run a command in the terminal to see components appear here.'
      )
    ).toBeInTheDocument();
  });

  it('renders mounted button widget in preview mode', () => {
    render(
      <LivingStage
        widgets={[
          {
            id: 'widget-1',
            component: 'button',
            mountedAt: Date.now(),
          },
        ]}
      />
    );

    expect(
      screen.getByRole('button', { name: 'Press me' })
    ).toBeInTheDocument();
  });

  it('updates container max-width class when viewport is switched to mobile', () => {
    const { container } = render(<LivingStage widgets={[]} />);

    const mobileButton = screen.getByRole('radio', {
      name: /mobile viewport/i,
    });
    fireEvent.click(mobileButton);

    const viewportContainer = container.querySelector('.max-w-\\[375px\\]');
    expect(viewportContainer).toBeInTheDocument();
  });

  it('switches to code view and displays Dart Flutter source', () => {
    render(
      <LivingStage
        widgets={[
          {
            id: 'widget-1',
            component: 'button',
            mountedAt: Date.now(),
          },
        ]}
      />
    );

    const codeTab = screen.getByRole('tab', { name: /flutter code/i });
    fireEvent.click(codeTab);

    expect(screen.getByText(/JustButton\(/)).toBeInTheDocument();
    expect(screen.getByText(/JustButtonVariant\.primary/)).toBeInTheDocument();
  });

  it('generates fallback Dart source for components outside preview registry', () => {
    render(
      <LivingStage
        widgets={[
          {
            id: 'widget-dialog',
            component: 'dialog',
            mountedAt: Date.now(),
          },
        ]}
      />
    );

    const codeTab = screen.getByRole('tab', { name: /flutter code/i });
    fireEvent.click(codeTab);

    expect(screen.getByText(/JustDialog\(\)/)).toBeInTheDocument();
  });

  it('dispatches justui-mounted telemetry event when widgets are mounted', () => {
    const windowSpy = vi.spyOn(window, 'postMessage');
    render(
      <LivingStage
        widgets={[
          {
            id: 'widget-card',
            component: 'card',
            mountedAt: Date.now(),
          },
        ]}
      />
    );

    expect(windowSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        type: 'justui-mounted',
        component: 'card',
        success: true,
      }),
      '*'
    );
  });
});
