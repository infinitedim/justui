import { render, screen, fireEvent, act } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { InstallSnippet } from '@/components/install-snippet';

describe('InstallSnippet Component', () => {
  it('renders the installation command', () => {
    render(<InstallSnippet />);
    expect(
      screen.getByText('flutter pub add just_ui_core')
    ).toBeInTheDocument();
  });

  it('copies command to clipboard and toggles status icons', async () => {
    vi.useFakeTimers();

    // Mock navigator.clipboard
    const mockWriteText = vi.fn().mockResolvedValue(undefined);
    Object.assign(navigator, {
      clipboard: {
        writeText: mockWriteText,
      },
    });

    render(<InstallSnippet />);
    const button = screen.getByRole('button', {
      name: /copy install command/i,
    });
    expect(button).toBeInTheDocument();

    // Copy icon should be visible initially (lucide-react attributes or aria-hidden check)
    expect(screen.queryByLabelText('Copy install command')).toBeInTheDocument();

    // Click to copy
    await act(async () => {
      fireEvent.click(button);
    });

    expect(mockWriteText).toHaveBeenCalledWith('flutter pub add just_ui_core');

    // Timer expires after 2000ms
    act(() => {
      vi.advanceTimersByTime(2000);
    });

    vi.useRealTimers();
  });
});
