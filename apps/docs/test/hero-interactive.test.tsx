import { render, screen, fireEvent } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { HeroInteractive } from '@/components/organisms/hero-interactive';
import { PresetProvider } from '@/components/providers';

describe('HeroInteractive', () => {
  it('renders the terminal and the stage side by side', () => {
    render(<HeroInteractive />);

    expect(
      screen.getByRole('region', { name: 'CLI simulator' })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('region', { name: 'Component preview' })
    ).toBeInTheDocument();
  });

  it('starts with the button the pre-run command added', () => {
    render(<HeroInteractive />);
    expect(screen.getByTestId('stage-widget-button')).toBeInTheDocument();
  });

  it('mounts components added in the terminal, without duplicates', () => {
    render(<HeroInteractive />);

    const input = screen.getByLabelText('Type a justui command');
    fireEvent.change(input, { target: { value: 'justui add button switch' } });
    fireEvent.keyDown(input, { key: 'Enter' });

    expect(screen.getAllByTestId('stage-widget-button')).toHaveLength(1);
    expect(screen.getByTestId('stage-widget-switch')).toBeInTheDocument();
  });

  it('applies the preset chosen in the terminal to the stage', () => {
    render(
      <PresetProvider>
        <HeroInteractive />
      </PresetProvider>
    );

    const input = screen.getByLabelText('Type a justui command');
    fireEvent.change(input, {
      target: { value: 'justui preset apply neobrutalism' },
    });
    fireEvent.keyDown(input, { key: 'Enter' });

    expect(
      screen.getByRole('region', { name: 'Component preview' })
    ).toHaveAttribute('data-preset', 'neobrutalism');
  });
});
