import { describe, expect, it } from 'vitest';
import { fireEvent, render, screen, within } from '@testing-library/react';
import { KIT_PARTS, KitPart } from '@/components/runner-kit/kit-part';
import { KitButton } from '@/components/runner-kit/kit-actions';
import { kitTranslations } from '@/lib/kit-translations';
import { PART_SLUGS } from '@/lib/parts';

const t = kitTranslations.en;

function renderPart(slug: string) {
  return render(
    <div data-testid="stage" className="preset-default">
      <KitPart slug={slug} t={t} uid={`test-${slug}`} />
    </div>
  );
}

describe('runner kit', () => {
  it('has a demo for exactly the public registry parts', () => {
    expect(Object.keys(KIT_PARTS).toSorted()).toEqual(
      [...PART_SLUGS].toSorted()
    );
  });

  it.each([...PART_SLUGS])('renders %s with visible content', (slug) => {
    renderPart(slug);
    const stage = screen.getByTestId('stage');
    expect(stage.childElementCount).toBeGreaterThan(0);
  });

  it('renders nothing for an unknown slug', () => {
    renderPart('shared');
    expect(screen.getByTestId('stage').childElementCount).toBe(0);
  });

  it('uses a native switch and checkbox the keyboard can toggle', () => {
    renderPart('switch');
    const toggle = screen.getByRole('switch', { name: 'Wi-Fi' });
    expect(toggle).toBeChecked();
    fireEvent.click(toggle);
    expect(toggle).not.toBeChecked();
  });

  it('uses a native range for the slider', () => {
    renderPart('slider');
    const slider = screen.getByRole('slider', { name: 'Volume' });
    fireEvent.change(slider, { target: { value: '30' } });
    expect(slider).toHaveValue('30');
    expect(slider).toHaveAttribute('aria-valuetext', '30%');
  });

  it('moves the selected tab with the arrow keys', () => {
    renderPart('tabs');
    const [first, second] = screen.getAllByRole('tab');
    expect(first).toHaveAttribute('aria-selected', 'true');
    if (!first || !second) throw new Error('missing tabs');
    fireEvent.keyDown(first, { key: 'ArrowRight' });
    expect(second).toHaveAttribute('aria-selected', 'true');
    expect(second).toHaveAttribute('tabindex', '0');
  });

  it('flags an invalid project name with an icon message and aria-invalid', () => {
    renderPart('input');
    const field = screen.getByLabelText('Project name');
    expect(field).toHaveAttribute('aria-invalid', 'false');
    fireEvent.change(field, { target: { value: 'My App' } });
    expect(field).toHaveAttribute('aria-invalid', 'true');
    expect(screen.getByText(t.badProject)).toBeInTheDocument();
  });

  it('toggles aria-pressed on the toggle', () => {
    renderPart('toggle');
    const bold = screen.getByRole('button', { name: 'Bold' });
    expect(bold).toHaveAttribute('aria-pressed', 'true');
    fireEvent.click(bold);
    expect(bold).toHaveAttribute('aria-pressed', 'false');
  });

  it('selects a three-day range in the date range picker', () => {
    renderPart('date-range-picker');
    const group = screen.getByRole('group', { name: t.daysLabel });
    fireEvent.click(within(group).getByRole('button', { name: '14' }));
    const pressed = within(group)
      .getAllByRole('button')
      .filter((day) => day.getAttribute('aria-pressed') === 'true')
      .map((day) => day.textContent);
    expect(pressed).toEqual(['14', '15', '16']);
  });

  it('gives destructive buttons the danger part classes', () => {
    render(<KitButton variant="destructive">Discard</KitButton>);
    expect(screen.getByRole('button', { name: 'Discard' }).className).toMatch(
      /--ip-part-danger-bg/
    );
  });
});
