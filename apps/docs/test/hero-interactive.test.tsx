import { render, screen, fireEvent } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { HeroInteractive } from '@/components/organisms/hero-interactive';

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
    expect(
      screen.getByText(
        'Run a command in the terminal to see components appear here.'
      )
    ).toBeInTheDocument();
  });

  it('renders centerpiece preset spotlight toggle and switches preset', () => {
    render(<HeroInteractive />);

    const cleanRadio = screen.getByRole('radio', { name: 'Clean Precision' });
    const neoRadio = screen.getByRole('radio', { name: 'Neobrutalism' });

    expect(cleanRadio).toBeInTheDocument();
    expect(neoRadio).toBeInTheDocument();
    expect(cleanRadio).toHaveAttribute('aria-checked', 'true');

    fireEvent.click(neoRadio);
    expect(neoRadio).toHaveAttribute('aria-checked', 'true');
  });
});
