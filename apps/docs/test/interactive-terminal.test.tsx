import { createRef } from 'react';
import { render, screen, fireEvent, act } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import {
  InteractiveTerminal,
  type InteractiveTerminalHandle,
} from '@/components/organisms/interactive-terminal';

const inputLabel = 'Type a justui command';

describe('InteractiveTerminal', () => {
  it('shows a plain path header with no fake window chrome or badge', () => {
    const { container } = render(<InteractiveTerminal />);

    expect(screen.getByText('~/my-flutter-app')).toBeInTheDocument();
    expect(
      screen.getByText('simulated, nothing is written to disk')
    ).toBeInTheDocument();
    expect(container.querySelector('[class*="#FF5F57"]')).toBeNull();
    expect(screen.queryByText('CLI Simulator')).not.toBeInTheDocument();
  });

  it('starts with `justui add button` already run, using the real CLI output', () => {
    render(<InteractiveTerminal />);

    expect(screen.getByText('justui add button')).toBeInTheDocument();
    expect(
      screen.getByText(/Copied just_button.dart to lib\/widgets\/button\//)
    ).toBeInTheDocument();
  });

  it('renders the try-commands without the justui prefix', () => {
    render(<InteractiveTerminal />);

    expect(
      screen.getByRole('button', { name: 'add switch card' })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('button', { name: 'preset apply neobrutalism' })
    ).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'list' })).toBeInTheDocument();
  });

  it('has no infinitely animating cursor (WCAG 2.2.2)', () => {
    const { container } = render(<InteractiveTerminal />);
    expect(container.querySelector('.animate-pulse')).toBeNull();
    expect(container.querySelector('.animate-ping')).toBeNull();
  });

  it('uses a visible, tappable input instead of an sr-only one', () => {
    render(<InteractiveTerminal />);
    const input = screen.getByLabelText(inputLabel);
    expect(input).not.toHaveClass('sr-only');
    expect(input).toHaveAttribute('enterkeyhint', 'go');
  });

  it('types and runs a chip command', async () => {
    vi.useFakeTimers();
    const handleMount = vi.fn();
    render(<InteractiveTerminal onMount={handleMount} />);

    fireEvent.click(screen.getByRole('button', { name: 'add switch card' }));
    await act(async () => {
      await vi.advanceTimersByTimeAsync(3000);
    });

    expect(handleMount).toHaveBeenCalledWith(['switch', 'card']);
    expect(
      screen.getByText(/Registered JustSwitchTheme.defaults/)
    ).toBeInTheDocument();
    vi.useRealTimers();
  });

  it('runs typed commands on Enter', () => {
    const handlePreset = vi.fn();
    render(<InteractiveTerminal onPresetChange={handlePreset} />);

    const input = screen.getByLabelText(inputLabel);
    fireEvent.change(input, {
      target: { value: 'justui preset apply neobrutalism' },
    });
    fireEvent.keyDown(input, { key: 'Enter' });

    expect(handlePreset).toHaveBeenCalledWith('neobrutalism');
  });

  it('says that machine-specific commands only run locally', () => {
    render(<InteractiveTerminal />);

    const input = screen.getByLabelText(inputLabel);
    fireEvent.change(input, { target: { value: 'justui doctor' } });
    fireEvent.keyDown(input, { key: 'Enter' });

    expect(
      screen.getByText(/can't run in this browser simulation/)
    ).toBeInTheDocument();
  });

  it('recalls history with ArrowUp, starting from the pre-run command', () => {
    render(<InteractiveTerminal />);

    const input = screen.getByLabelText(inputLabel);
    fireEvent.keyDown(input, { key: 'ArrowUp' });
    expect(input).toHaveValue('justui add button');
  });

  it('completes component names with Tab', () => {
    render(<InteractiveTerminal />);

    const input = screen.getByLabelText(inputLabel);
    fireEvent.change(input, { target: { value: 'justui add button ca' } });
    fireEvent.keyDown(input, { key: 'Tab' });

    expect(input).toHaveValue('justui add button card');
  });

  it('completes the justui prefix with Tab', () => {
    render(<InteractiveTerminal />);

    const input = screen.getByLabelText(inputLabel);
    fireEvent.change(input, { target: { value: 'just' } });
    fireEvent.keyDown(input, { key: 'Tab' });

    expect(input).toHaveValue('justui ');
  });

  it('hides keyboard hints on touch screens', () => {
    render(<InteractiveTerminal />);
    expect(screen.getByText('Tab completes, Up/Down for history')).toHaveClass(
      'hidden',
      'pointer-fine:inline'
    );
  });

  it('exposes runCommand via ref and ignores a duplicate trigger while typing', async () => {
    vi.useFakeTimers();
    const ref = createRef<InteractiveTerminalHandle>();
    const handleMount = vi.fn();
    render(<InteractiveTerminal ref={ref} onMount={handleMount} />);

    act(() => {
      ref.current?.runCommand('justui add card');
      ref.current?.runCommand('justui add card');
    });
    await act(async () => {
      await vi.advanceTimersByTimeAsync(3000);
    });

    expect(handleMount).toHaveBeenCalledTimes(1);
    expect(handleMount).toHaveBeenCalledWith(['card']);
    vi.useRealTimers();
  });

  it('keeps a text selection instead of focusing the input on click', () => {
    render(<InteractiveTerminal />);
    const region = screen.getByRole('region', { name: 'CLI simulator' });
    const input = screen.getByLabelText(inputLabel);
    const focusSpy = vi.spyOn(input, 'focus');
    const getSelectionSpy = vi.spyOn(window, 'getSelection').mockReturnValue({
      toString: () => 'highlighted text',
    } as unknown as Selection);

    fireEvent.click(region);

    expect(focusSpy).not.toHaveBeenCalled();
    getSelectionSpy.mockRestore();
  });

  it('focuses the input on click when matchMedia is unavailable', () => {
    const originalMatchMedia = window.matchMedia;
    // @ts-expect-error simulating legacy/unsupported environment
    delete window.matchMedia;

    render(<InteractiveTerminal />);
    const region = screen.getByRole('region', { name: 'CLI simulator' });
    const input = screen.getByLabelText(inputLabel);
    const focusSpy = vi.spyOn(input, 'focus');

    fireEvent.click(region);

    expect(focusSpy).toHaveBeenCalled();
    window.matchMedia = originalMatchMedia;
  });
});

describe('InteractiveTerminal display', () => {
  it('shows summary boxes without their box-drawing frame', () => {
    render(<InteractiveTerminal />);
    const corner = String.fromCharCode(0x256d);
    expect(screen.queryByText((text) => text.includes(corner))).toBeNull();
    expect(
      screen.getByText(/1 component\(s\) added successfully/)
    ).toBeInTheDocument();
  });
});
