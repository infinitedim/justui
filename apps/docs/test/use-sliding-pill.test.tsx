import { useRef } from 'react';
import { act, render, screen } from '@testing-library/react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { useSlidingPill } from '@/lib/use-sliding-pill';

function Harness({ value }: { value: string }) {
  const group = useRef<HTMLDivElement | null>(null);
  const pill = useSlidingPill(group, value, 'x', 300);
  return (
    <div ref={group}>
      <span ref={pill} data-testid="pill" />
      <button type="button" aria-pressed={value === 'a'}>
        a
      </button>
      <button type="button" aria-pressed={value === 'b'}>
        b
      </button>
    </div>
  );
}

afterEach(() => {
  vi.unstubAllGlobals();
});

describe('useSlidingPill', () => {
  it('places the pill under the selected item', () => {
    render(<Harness value="a" />);
    expect(screen.getByTestId('pill').style.opacity).toBe('1');
    expect(screen.getByTestId('pill').parentElement).toHaveAttribute(
      'data-ready',
      'true'
    );
  });

  it('re-measures the selected item when the group resizes', () => {
    const callbacks: Array<() => void> = [];
    vi.stubGlobal(
      'ResizeObserver',
      class {
        constructor(callback: () => void) {
          callbacks.push(callback);
        }
        observe() {}
        disconnect() {}
      }
    );
    render(<Harness value="a" />);
    const pill = screen.getByTestId('pill');
    expect(pill.style.width).toBe('0px');
    Object.defineProperty(
      screen.getByRole('button', { name: 'a' }),
      'offsetWidth',
      {
        configurable: true,
        value: 120,
      }
    );
    act(() => {
      for (const callback of callbacks) callback();
    });
    expect(pill.style.width).toBe('120px');
  });

  it('jumps on a change before the first paint and slides after it', async () => {
    const animate = vi.fn();
    Object.defineProperty(HTMLElement.prototype, 'animate', {
      configurable: true,
      value: animate,
    });
    vi.stubGlobal(
      'matchMedia',
      vi.fn().mockReturnValue({
        matches: false,
        addEventListener: vi.fn(),
        removeEventListener: vi.fn(),
      })
    );
    try {
      const { rerender } = render(<Harness value="a" />);
      Object.defineProperty(
        screen.getByRole('button', { name: 'b' }),
        'offsetLeft',
        {
          configurable: true,
          value: 100,
        }
      );
      // The stored preset is read right after hydration: no slide.
      rerender(<Harness value="b" />);
      expect(animate).not.toHaveBeenCalled();
      await act(
        () =>
          new Promise<void>((resolve) => requestAnimationFrame(() => resolve()))
      );
      rerender(<Harness value="a" />);
      expect(animate).toHaveBeenCalledTimes(1);
    } finally {
      Reflect.deleteProperty(HTMLElement.prototype, 'animate');
    }
  });
});
