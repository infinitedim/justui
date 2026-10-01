import { describe, expect, it } from 'vitest';
import * as fs from 'node:fs';
import * as path from 'node:path';

/**
 * Guards against the patterns the UI audit removed, so they do not creep
 * back in one component at a time. Styling must come from --just-* tokens;
 * preset differences come from the token set, never from branching.
 */

const srcDir = path.resolve(__dirname, '..', 'src');

function listFiles(dir: string): string[] {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) return listFiles(full);
    return /\.(ts|tsx)$/.test(entry.name) ? [full] : [];
  });
}

const files = listFiles(srcDir).map((full) => ({
  rel: path.relative(srcDir, full).split(path.sep).join('/'),
  text: fs.readFileSync(full, 'utf8'),
}));

/** Docs demos under components/docs are MDX content, outside the audited UI. */
const uiFiles = files.filter(
  (f) => f.rel.endsWith('.tsx') && !f.rel.startsWith('components/docs/')
);

/**
 * rounded-full is reserved for circles: switch track and thumb, avatar,
 * radio, slider thumb, spinner, color swatch, semantic status dot. The phone
 * chassis in the Studio is pending its own redesign.
 */
const ROUNDED_FULL_ALLOWED = new Set([
  'components/organisms/simulators/preview-mocks/switch-mock.tsx',
  'components/organisms/simulators/preview-mocks/avatar-mock.tsx',
  'components/organisms/simulators/preview-mocks/avatar-group-mock.tsx',
  'components/organisms/simulators/preview-mocks/radio-mock.tsx',
  'components/organisms/simulators/preview-mocks/badge-mock.tsx',
  'components/organisms/simulators/preview-mocks/skeleton-mock.tsx',
  'components/organisms/component-preview-grid/component-preview-grid.tsx',
  'components/organisms/phone-mockup-canvas/phone-mockup-canvas.tsx',
  'components/molecules/state-toggle/state-toggle.tsx',
  'components/molecules/color-swatch-item/color-swatch-item.tsx',
  'components/atoms/slider/slider.tsx',
  'components/atoms/button/button.tsx',
]);

/** Raw Tailwind palette colors bypass the tokens; only the phone chassis keeps them for now. */
const RAW_PALETTE_ALLOWED = new Set([
  'components/organisms/phone-mockup-canvas/phone-mockup-canvas.tsx',
]);

const BANNED: { name: string; pattern: RegExp }[] = [
  { name: 'isNeo branching', pattern: /\bisNeo\b/ },
  { name: 'hard-coded black border', pattern: /\bborder-black\b/ },
  { name: 'hard-coded offset shadow', pattern: /shadow-\[\d/ },
  { name: 'text below 12px', pattern: /text-\[(?:[0-9]|1[01])px\]/ },
  {
    name: 'undefined token text-muted-foreground',
    pattern: /text-muted-foreground/,
  },
  { name: 'undefined token ring-ring', pattern: /\bring-ring\b/ },
  {
    name: 'text color used as background (bg-muted/..)',
    pattern: /\bbg-muted\//,
  },
  { name: 'text dimmed with opacity', pattern: /\btext-muted\/\d+/ },
  { name: 'infinite ping animation', pattern: /\banimate-ping\b/ },
  { name: 'macOS traffic lights', pattern: /#FF5F57|#FEBC2E|#28C840/i },
  { name: 'lime used as text', pattern: /\btext-accent-(?:dark|deep|light)\b/ },
];

describe('style guards (UI audit)', () => {
  it('scans the source tree', () => {
    expect(uiFiles.length).toBeGreaterThan(50);
  });

  it.each(BANNED)('no $name', ({ pattern }) => {
    const offenders = uiFiles
      .filter((f) => pattern.test(f.text))
      .map((f) => f.rel);
    expect(offenders).toEqual([]);
  });

  it('keeps rounded-full to circles', () => {
    const offenders = uiFiles
      .filter(
        (f) =>
          /\brounded-full\b/.test(f.text) && !ROUNDED_FULL_ALLOWED.has(f.rel)
      )
      .map((f) => f.rel);
    expect(offenders).toEqual([]);
  });

  it('uses tokens instead of raw Tailwind palette colors', () => {
    const palette =
      /\b(?:bg|text|border|fill|ring)-(?:emerald|purple|violet|zinc|slate|gray|red|green|blue|amber|rose|cyan)-\d{2,3}\b/;
    const offenders = uiFiles
      .filter((f) => palette.test(f.text) && !RAW_PALETTE_ALLOWED.has(f.rel))
      .map((f) => f.rel);
    expect(offenders).toEqual([]);
  });

  it('keeps preview mocks free of a preset prop', () => {
    const mocks = uiFiles.filter((f) =>
      f.rel.includes('simulators/preview-mocks/')
    );
    expect(mocks).toHaveLength(33);
    for (const mock of mocks) {
      expect(/preset\??:\s*'default'/.test(mock.text), mock.rel).toBe(false);
    }
  });
});
