import { render, screen, fireEvent, act } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { InteractiveTerminal } from '@/components/organisms/interactive-terminal';

describe('InteractiveTerminal', () => {
  it('renders macOS window chrome with 3 control buttons and title', () => {
    const { container } = render(<InteractiveTerminal />);

    const red = container.querySelector('.bg-\\[\\#FF5F57\\]');
    const yellow = container.querySelector('.bg-\\[\\#FEBC2E\\]');
    const green = container.querySelector('.bg-\\[\\#28C840\\]');

    expect(red).toBeInTheDocument();
    expect(yellow).toBeInTheDocument();
    expect(green).toBeInTheDocument();
    expect(
      screen.getByText('justui@v0.14.0 ~ /my-flutter-app')
    ).toBeInTheDocument();
  });

  it('renders all 4 action chips', () => {
    render(<InteractiveTerminal />);

    expect(
      screen.getByRole('button', { name: 'justui init' })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('button', { name: 'justui add button' })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('button', { name: 'justui add switch card' })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('button', { name: 'justui preset apply neobrutalism' })
    ).toBeInTheDocument();
  });

  it('renders blinking cursor on empty terminal', () => {
    const { container } = render(<InteractiveTerminal />);
    const cursor = container.querySelector('.animate-pulse');
    expect(cursor).toBeInTheDocument();
  });

  it('triggers automated typing and command execution when a chip is clicked', async () => {
    vi.useFakeTimers();

    const handleClear = vi.fn();
    render(<InteractiveTerminal onClear={handleClear} />);

    const initChip = screen.getByRole('button', { name: 'justui init' });
    fireEvent.click(initChip);

    // Fast-forward keystroke typing timers
    await act(async () => {
      await vi.advanceTimersByTimeAsync(3000);
    });

    expect(
      screen.getByText('Initializing JustUI project...')
    ).toBeInTheDocument();
    expect(
      screen.getByText('Done! Run `justui add <component>` to start.')
    ).toBeInTheDocument();
    expect(handleClear).toHaveBeenCalled();

    vi.useRealTimers();
  });

  it('supports direct keyboard typing and Enter submission', async () => {
    const handleMount = vi.fn();
    render(<InteractiveTerminal onMount={handleMount} />);

    const input = screen.getByLabelText('Terminal input');
    fireEvent.change(input, { target: { value: 'justui add button' } });
    fireEvent.keyDown(input, { key: 'Enter' });

    expect(screen.getByText('Downloading button...')).toBeInTheDocument();
    expect(handleMount).toHaveBeenCalledWith(['button']);
  });

  it('records automated command in history for Up Arrow recall', async () => {
    vi.useFakeTimers();
    render(<InteractiveTerminal />);

    const buttonChip = screen.getByRole('button', {
      name: 'justui add button',
    });
    fireEvent.click(buttonChip);

    await act(async () => {
      await vi.advanceTimersByTimeAsync(3000);
    });

    const input = screen.getByLabelText('Terminal input');
    fireEvent.keyDown(input, { key: 'ArrowUp' });

    expect(input).toHaveValue('justui add button');
    vi.useRealTimers();
  });

  it('supports multi-token component Tab autocomplete', () => {
    render(<InteractiveTerminal />);

    const input = screen.getByLabelText('Terminal input');
    fireEvent.change(input, { target: { value: 'justui add button ca' } });
    fireEvent.keyDown(input, { key: 'Tab' });

    expect(input).toHaveValue('justui add button card');
  });

  it('supports justui prefix Tab autocomplete', () => {
    render(<InteractiveTerminal />);

    const input = screen.getByLabelText('Terminal input');
    fireEvent.change(input, { target: { value: 'just' } });
    fireEvent.keyDown(input, { key: 'Tab' });

    expect(input).toHaveValue('justui ');
  });
});
