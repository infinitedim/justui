import { render, screen, fireEvent } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { LivingStage } from '@/components/organisms/living-stage';

describe('LivingStage', () => {
  it('shows empty state placeholder when no widgets are mounted', () => {
    render(<LivingStage widgets={[]} />);
    expect(screen.getByText('Flutter Canvas Ready')).toBeInTheDocument();
    expect(
      screen.getByRole('button', { name: /run: justui add button/i })
    ).toBeInTheDocument();
  });

  it('triggers onRunCommand when empty state CTA button is clicked', () => {
    const handleRunCommand = vi.fn();
    render(<LivingStage widgets={[]} onRunCommand={handleRunCommand} />);

    const ctaButton = screen.getByRole('button', {
      name: /run: justui add button/i,
    });
    fireEvent.click(ctaButton);

    expect(handleRunCommand).toHaveBeenCalledWith('justui add button');
  });

  it('renders toolbar badge, theme indicator, micro-hint, and handles clear button', () => {
    const handleClear = vi.fn();
    render(
      <LivingStage
        widgets={[
          {
            id: 'widget-1',
            component: 'button',
            mountedAt: Date.now(),
          },
        ]}
        preset="neobrutalism"
        onClear={handleClear}
      />
    );

    expect(screen.getByText('Live Flutter Canvas')).toBeInTheDocument();
    expect(screen.getByText('Theme: neobrutalism')).toBeInTheDocument();
    expect(
      screen.getByText(
        'Tip: Click or interact with widgets above to test state animations.'
      )
    ).toBeInTheDocument();

    const clearButton = screen.getByRole('button', { name: 'Clear' });
    expect(clearButton).toBeInTheDocument();
    fireEvent.click(clearButton);
    expect(handleClear).toHaveBeenCalledTimes(1);
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
            id: 'widget-custom',
            component: 'custom-widget',
            mountedAt: Date.now(),
          },
        ]}
      />
    );

    const codeTab = screen.getByRole('tab', { name: /flutter code/i });
    fireEvent.click(codeTab);

    expect(screen.getByText(/JustCustomWidget\(\)/)).toBeInTheDocument();
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
      window.location.origin
    );
  });
});
