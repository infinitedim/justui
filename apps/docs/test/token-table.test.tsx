import fs from 'node:fs';
import path from 'node:path';
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { TokenTable } from '@/components/organisms/feature-rows/token-table';

const repoRoot = path.resolve(__dirname, '../../..');
const presetTokens = fs.readFileSync(
  path.join(repoRoot, 'packages/core/lib/src/theme/preset_tokens.dart'),
  'utf8'
);
const radius = fs.readFileSync(
  path.join(repoRoot, 'packages/tokens/lib/src/radius.dart'),
  'utf8'
);

/** Source text of one Dart class, up to the next top-level class. */
function classBody(name: string): string {
  const start = presetTokens.indexOf(`class ${name} `);
  if (start < 0) throw new Error(`${name} not found`);
  const next = presetTokens.indexOf('\nclass ', start + 1);
  return presetTokens.slice(start, next < 0 ? undefined : next);
}

function capture(source: string, pattern: RegExp): string {
  const value = pattern.exec(source)?.[1];
  if (value === undefined) throw new Error(`no match for ${pattern}`);
  return value;
}

const base = classBody('JustPresetTokens');
const preset = {
  default: classBody('DefaultPresetTokens'),
  neobrutalism: classBody('NeobrutalismPresetTokens'),
};
const BORDER = /double get borderWidth => ([\d.]+);/;
const FOCUS =
  /Duration get focusTransitionDuration =>\s*const Duration\(milliseconds: (\d+)\)/;

function focusMs(body: string): string {
  return FOCUS.test(body) ? capture(body, FOCUS) : capture(base, FOCUS);
}

/** Cells of the row whose header names `token`: [Default, Neobrutalism]. */
function row(token: string) {
  const header = screen.getByRole('rowheader', { name: token });
  const cells = header.parentElement?.querySelectorAll('td') ?? [];
  return Array.from(cells, (cell) => cell.textContent ?? '');
}

// shadow.sm is left out on purpose: it follows prd/02-design-spec.md (no
// Default shadow below md), not the Dart preset tokens.
describe('token table', () => {
  it('matches the preset tokens in packages/core', () => {
    render(<TokenTable tokenColumn="Token" />);
    const radiusMd = capture(radius, /Radius md = \.circular\(([\d]+)\.0\)/);

    expect(row('borderWidth')).toEqual([
      capture(preset.default, BORDER),
      capture(preset.neobrutalism, BORDER),
    ]);
    expect(preset.default).toContain('return .all(radius.md);');
    expect(preset.neobrutalism).toMatch(/return \.zero;/);
    expect(row('radius')).toEqual([`md (${radiusMd})`, 'zero']);
    const scale = capture(preset.default, /customScale \?\? ([\d.]+)/);
    const [dx, dy] = capture(
      preset.neobrutalism,
      /customOffset \?\? const Offset\(([\d.]+, [\d.]+)\)/
    ).split(', ');
    expect(row('press')).toEqual([
      `scale ${scale}`,
      `translate ${Number(dx)}, ${Number(dy)}`,
    ]);
    expect(row('focus')).toEqual([
      `${focusMs(preset.default)} ms`,
      `${focusMs(preset.neobrutalism)} ms`,
    ]);
  });
});
