import { render, screen, fireEvent, act } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { HeroInteractive } from '@/components/organisms/hero-interactive';
import { PresetProvider } from '@/components/providers';

describe('HeroInteractive', () => {
  it('renders both terminal and living stage organisms side-by-side', () => {
    render(<HeroInteractive />);

    expect(
      screen.getByRole('region', { name: /interactive terminal/i })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('region', { name: /living widget stage/i })
    ).toBeInTheDocument();
  });

  it('mounts widgets in living stage when command is typed in terminal', () => {
    render(<HeroInteractive />);

    const input = screen.getByLabelText('Terminal input');
    fireEvent.change(input, { target: { value: 'justui add button' } });
    fireEvent.keyDown(input, { key: 'Enter' });

    expect(
      screen.getByRole('button', { name: 'Press me' })
    ).toBeInTheDocument();
  });

  it('clears living stage when justui init is executed', () => {
    render(<HeroInteractive />);

    const input = screen.getByLabelText('Terminal input');
    fireEvent.change(input, { target: { value: 'justui add button' } });
    fireEvent.keyDown(input, { key: 'Enter' });

    expect(
      screen.getByRole('button', { name: 'Press me' })
    ).toBeInTheDocument();

    fireEvent.change(input, { target: { value: 'justui init' } });
    fireEvent.keyDown(input, { key: 'Enter' });

    expect(
      screen.queryByRole('button', { name: 'Press me' })
    ).not.toBeInTheDocument();
    expect(screen.getByText('Flutter Canvas Ready')).toBeInTheDocument();
  });

  it('clears living stage when stage Clear button is clicked', () => {
    render(<HeroInteractive />);

    const input = screen.getByLabelText('Terminal input');
    fireEvent.change(input, { target: { value: 'justui add button' } });
    fireEvent.keyDown(input, { key: 'Enter' });

    expect(
      screen.getByRole('button', { name: 'Press me' })
    ).toBeInTheDocument();

    const clearButton = screen.getByRole('button', { name: 'Clear' });
    fireEvent.click(clearButton);

    expect(
      screen.queryByRole('button', { name: 'Press me' })
    ).not.toBeInTheDocument();
    expect(screen.getByText('Flutter Canvas Ready')).toBeInTheDocument();
  });

  it('triggers command simulation and mounts widget when stage CTA is clicked', async () => {
    vi.useFakeTimers();
    render(<HeroInteractive />);

    const ctaButton = screen.getByRole('button', {
      name: /run: justui add button/i,
    });
    fireEvent.click(ctaButton);

    await act(async () => {
      await vi.advanceTimersByTimeAsync(3000);
    });

    expect(
      screen.getByRole('button', { name: 'Press me' })
    ).toBeInTheDocument();

    vi.useRealTimers();
  });

  it('switches preset when preset command is executed in terminal', () => {
    render(
      <PresetProvider>
        <HeroInteractive />
      </PresetProvider>
    );

    const input = screen.getByLabelText('Terminal input');
    fireEvent.change(input, {
      target: { value: 'justui preset apply neobrutalism' },
    });
    fireEvent.keyDown(input, { key: 'Enter' });

    expect(
      screen.getByRole('region', { name: /living widget stage/i })
    ).toHaveAttribute('data-preset', 'neobrutalism');
  });
});
