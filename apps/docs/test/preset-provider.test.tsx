import { useEffect } from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { describe, expect, it, vi, afterEach } from 'vitest';
import { PresetProvider, usePreset } from '@/components/providers';

function Consumer() {
  const { preset, setPreset } = usePreset();
  return (
    <div>
      <span data-testid="preset-val">{preset}</span>
      <button type="button" onClick={() => setPreset('neobrutalism')}>
        switch
      </button>
    </div>
  );
}

describe('PresetProvider localStorage resilience', () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('does not crash when localStorage.getItem throws (e.g. storage-restricted browser)', () => {
    vi.spyOn(Storage.prototype, 'getItem').mockImplementation(() => {
      throw new DOMException('blocked', 'SecurityError');
    });

    expect(() =>
      render(
        <PresetProvider>
          <Consumer />
        </PresetProvider>
      )
    ).not.toThrow();

    // Falls back to the default preset instead of crashing.
    expect(screen.getByTestId('preset-val')).toHaveTextContent('default');
  });

  it('does not crash when localStorage.setItem throws while switching presets', () => {
    vi.spyOn(Storage.prototype, 'setItem').mockImplementation(() => {
      throw new DOMException('blocked', 'SecurityError');
    });

    render(
      <PresetProvider>
        <Consumer />
      </PresetProvider>
    );

    expect(() => fireEvent.click(screen.getByText('switch'))).not.toThrow();
    expect(screen.getByTestId('preset-val')).toHaveTextContent('neobrutalism');
  });

  it('lets a preset chosen on mount (a shared ?preset= link) win over the stored one', () => {
    localStorage.setItem('justui-preset', 'default');

    // Child effects run before the provider's own mount effect, which is
    // exactly how the Studio applies ?preset=neo.
    function ApplyOnMount() {
      const { setPreset } = usePreset();
      useEffect(() => setPreset('neobrutalism'), [setPreset]);
      return null;
    }

    render(
      <PresetProvider>
        <ApplyOnMount />
        <Consumer />
      </PresetProvider>
    );

    expect(screen.getByTestId('preset-val')).toHaveTextContent('neobrutalism');
    expect(localStorage.getItem('justui-preset')).toBe('neobrutalism');
    document.body.classList.remove('theme-neobrutalism');
    document.documentElement.classList.remove('theme-neobrutalism');
    localStorage.clear();
  });
});
