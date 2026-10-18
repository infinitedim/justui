import { describe, expect, it } from 'vitest';
import { cutFrame } from '@/lib/cut-sequence';
import { expoOut, viewportProgress } from '@/lib/scroll-progress';

const geometry = { dx: 400, dy: 120 };
const scroll = (p: number) =>
  cutFrame(p, { stepped: false, geometry, rows: 4 });
const stepped = (p: number) =>
  cutFrame(p, { stepped: true, geometry, rows: 4 });

describe('expoOut', () => {
  it('starts at 0, ends at 1 and front-loads the motion', () => {
    expect(expoOut(0)).toBe(0);
    expect(expoOut(1)).toBe(1);
    expect(expoOut(0.5)).toBeGreaterThan(0.9);
  });
});

describe('viewportProgress', () => {
  it('runs from 0 to 1 as the element rises through the window', () => {
    expect(viewportProgress(900, 800, 0.9, 0.5)).toBe(0);
    expect(viewportProgress(720, 800, 0.9, 0.5)).toBe(0);
    expect(viewportProgress(520, 800, 0.9, 0.5)).toBeCloseTo(0.5);
    expect(viewportProgress(-100, 800, 0.9, 0.5)).toBe(1);
  });
});

describe('cutFrame while scrolling', () => {
  it('shows the uncut runner and an empty folder at the start', () => {
    const frame = scroll(0);
    expect(frame.label.backgroundColor).toBe('transparent');
    expect(frame.scissors.opacity).toBe('0');
    expect(frame.gate.transform).toBe('scaleY(1)');
    expect(frame.slot.opacity).toBe('1');
    expect(frame.mover.opacity).toBe('0');
    expect(frame.folder.clipPath).toBe('inset(0 100% 0 0)');
    expect(frame.landing.opacity).toBe('0');
    expect(frame.rows.map((row) => row.clipPath)).toEqual(
      Array(4).fill('inset(0 100% 0 0)')
    );
    expect(frame.verify.opacity).toBe('0');
    expect(frame.cutTag.opacity).toBe('0');
  });

  it('flies the part midway and morphs it into a file row', () => {
    const frame = scroll(0.5);
    expect(frame.label.backgroundColor).toBe('var(--ip-inverse)');
    expect(frame.gate.transform).toBe('scaleY(0.45)');
    expect(frame.slot.opacity).toBe('0');
    expect(frame.mover.opacity).toBe('1');
    const flight = expoOut(0.5);
    const [x = NaN, y = NaN] =
      (frame.mover.transform ?? '').match(/-?[\d.]+(?=px)/g)?.map(Number) ?? [];
    expect(x).toBeCloseTo(400 * flight, 3);
    expect(y).toBeCloseTo(120 * flight - 4 * (1 - flight), 3);
    expect(Number(frame.moverRow.opacity)).toBeCloseTo(0.25);
    expect(Number(frame.moverButton.opacity)).toBeCloseTo(0.75);
    expect(frame.landing.opacity).toBe('0');
  });

  it('ends with the part landed, every file revealed and the check shown', () => {
    const frame = scroll(1);
    expect(frame.mover.opacity).toBe('0');
    expect(frame.landing.opacity).toBe('1');
    expect(frame.folder.clipPath).toBe('inset(0 0% 0 0)');
    expect(frame.rows.every((row) => row.clipPath === 'inset(0 0% 0 0)')).toBe(
      true
    );
    expect(frame.shared.clipPath).toBe('inset(0 0% 0 0)');
    expect(frame.verify.opacity).toBe('1');
    expect(frame.cutTag.opacity).toBe('1');
  });

  it('lifts the slot 4px before the flight starts', () => {
    expect(scroll(0.2).lift).toBe(0);
    expect(scroll(0.3).lift).toBe(4);
    expect(scroll(0.3).slot.transform).toBe('translateY(-4px)');
  });
});

describe('cutFrame in steps (reduced motion)', () => {
  it('cross-fades between before and after without moving anything', () => {
    const before = stepped(0);
    const after = stepped(1);
    expect(before.slot.opacity).toBe('1');
    expect(after.slot.opacity).toBe('0');
    expect(after.mover.opacity).toBe('0');
    expect(after.mover.transform).toBe('none');
    expect(after.folder).toEqual({
      opacity: '1',
      clipPath: 'none',
      transition: 'opacity 220ms cubic-bezier(0.16, 1, 0.3, 1)',
    });
    expect(before.verify.opacity).toBe('0');
    expect(after.cutTag.opacity).toBe('1');
    expect(after.lift).toBe(0);
  });
});
