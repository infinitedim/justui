import { createRef } from 'react';
import { render, screen, fireEvent, act } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import {
  InteractiveTerminal,
  type InteractiveTerminalHandle,
} from '@/components/organisms/interactive-terminal';

describe('InteractiveTerminal', () => {
  it('renders a plain header with the title and no cosmetic window chrome', () => {
    const { container } = render(<InteractiveTerminal />);

    expect(container.querySelector('.bg-\\[\\#FF5F57\\]')).toBeNull();
    expect(container.querySelector('.bg-\\[\\#FEBC2E\\]')).toBeNull();
    expect(container.querySelector('.bg-\\[\\#28C840\\]')).toBeNull();
    expect(
      screen.getByText('justui@v0.14.0 ~ /my-flutter-app')
    ).toBeInTheDocument();
    expect(screen.queryByText('CLI Simulator')).toBeNull();
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

  it('renders a static (non-blinking) cursor on empty terminal', () => {
    render(<InteractiveTerminal />);
    const cursor = screen.getByTestId('terminal-cursor');
    expect(cursor).toBeInTheDocument();
    expect(cursor).not.toHaveClass('animate-pulse');
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
      screen.getByText('Done. Run `justui add <component>` next.')
    ).toBeInTheDocument();
    expect(handleClear).toHaveBeenCalled();

    vi.useRealTimers();
  });

  it('supports direct keyboard typing and Enter submission', async () => {
    const handleMount = vi.fn();
    render(<InteractiveTerminal onMount={handleMount} />);

    const input = screen.getByLabelText('Command');
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

    const input = screen.getByLabelText('Command');
    fireEvent.keyDown(input, { key: 'ArrowUp' });

    expect(input).toHaveValue('justui add button');
    vi.useRealTimers();
  });

  it('supports multi-token component Tab autocomplete', () => {
    render(<InteractiveTerminal />);

    const input = screen.getByLabelText('Command');
    fireEvent.change(input, { target: { value: 'justui add button ca' } });
    fireEvent.keyDown(input, { key: 'Tab' });

    expect(input).toHaveValue('justui add button card');
  });

  it('supports justui prefix Tab autocomplete', () => {
    render(<InteractiveTerminal />);

    const input = screen.getByLabelText('Command');
    fireEvent.change(input, { target: { value: 'just' } });
    fireEvent.keyDown(input, { key: 'Tab' });

    expect(input).toHaveValue('justui ');
  });

  it('orders action chips with high-reward add button first and init last', () => {
    render(<InteractiveTerminal />);

    const buttons = screen.getAllByRole('button');
    expect(buttons[0]).toHaveTextContent('justui add button');
    expect(buttons[1]).toHaveTextContent('justui add switch card');
    expect(buttons[2]).toHaveTextContent('justui preset apply neobrutalism');
    expect(buttons[3]).toHaveTextContent('justui init');
  });

  it('renders keyboard shortcuts footer hints', () => {
    render(<InteractiveTerminal />);
    expect(
      screen.getByText('[Tab] Autocomplete | [Up/Down] History | [Enter] Run')
    ).toBeInTheDocument();
  });

  it('exposes runCommand via ref to trigger automated typing and ignores rapid duplicate triggers', async () => {
    vi.useFakeTimers();
    const ref = createRef<InteractiveTerminalHandle>();
    const handleMount = vi.fn();
    render(<InteractiveTerminal ref={ref} onMount={handleMount} />);

    act(() => {
      ref.current?.runCommand('justui add button');
      ref.current?.runCommand('justui add button');
    });

    await act(async () => {
      await vi.advanceTimersByTimeAsync(3000);
    });

    expect(handleMount).toHaveBeenCalledTimes(1);
    expect(handleMount).toHaveBeenCalledWith(['button']);
    vi.useRealTimers();
  });

  it('preserves text selection on container click without focusing input', () => {
    render(<InteractiveTerminal />);
    const region = screen.getByRole('region', { name: 'CLI simulator' });
    const input = screen.getByLabelText('Command');
    const focusSpy = vi.spyOn(input, 'focus');

    const getSelectionSpy = vi.spyOn(window, 'getSelection').mockReturnValue({
      toString: () => 'highlighted text',
    } as unknown as Selection);

    fireEvent.click(region);

    expect(focusSpy).not.toHaveBeenCalled();
    getSelectionSpy.mockRestore();
  });

  it('focuses input on container click when matchMedia is unavailable', () => {
    const originalMatchMedia = window.matchMedia;
    // @ts-expect-error simulating legacy/unsupported environment
    delete window.matchMedia;

    render(<InteractiveTerminal />);
    const region = screen.getByRole('region', { name: 'CLI simulator' });
    const input = screen.getByLabelText('Command');
    const focusSpy = vi.spyOn(input, 'focus');

    fireEvent.click(region);

    expect(focusSpy).toHaveBeenCalled();
    window.matchMedia = originalMatchMedia;
  });
});
