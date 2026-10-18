import { describe, expect, it } from 'vitest';
import * as fs from 'node:fs';
import * as path from 'node:path';

/**
 * Guards against the patterns the UI audit removed, so they do not creep
 * back in one component at a time. Styling must come from --just-* tokens;
 * preset differences come from the token set, never from branching.
 */

const srcDir = path.resolve(__dirname, '..', 'src');

function listFiles(dir: string): Array<string> {
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
 * radio, slider thumb, spinner, color swatch, semantic status dot.
 */
const ROUNDED_FULL_ALLOWED = new Set([
  'components/runner-kit/kit-data/kit-data.tsx',
  'components/runner-kit/kit-disclosure/kit-disclosure.tsx',
  'components/runner-kit/kit-disclosure/kit-panes.tsx',
  'components/runner-kit/kit-display/kit-display.tsx',
  'components/runner-kit/kit-navigation/kit-navigation.tsx',
  'components/runner-kit/kit-range/kit-range.tsx',
  'components/runner-kit/kit-selection/kit-selection.tsx',
  'components/runner-kit/kit-surfaces/kit-surfaces.tsx',
]);

/** Raw Tailwind palette colors bypass the tokens. */
const RAW_PALETTE_ALLOWED = new Set<string>();

const BANNED: Array<{ name: string; pattern: RegExp }> = [
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
    expect(uiFiles.length).toBeGreaterThan(40);
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

  it('never overrides a fumadocs display class with our own media variant', () => {
    // fumadocs-ui/style.css is precompiled Tailwind. Its rules land later in
    // the same utilities layer, and the minifier keeps only the last copy of
    // a duplicate rule. A base class it ships (.flex, .hidden, .sr-only)
    // therefore beats a media, container or dark variant that only we use.
    const fumadocsCss = fs.readFileSync(
      path.resolve(__dirname, '..', 'node_modules/fumadocs-ui/dist/style.css'),
      'utf8'
    );
    const shipsClass = (token: string) =>
      fumadocsCss.includes(
        `.${token.replace(/[^a-zA-Z0-9_-]/g, (char) => `\\${char}`)} {`
      );
    const display =
      /^(?:flex|inline-flex|block|inline-block|inline|grid|inline-grid|hidden|contents|table|sr-only|not-sr-only)$/;
    const mediaVariant =
      /^(?:sm|md|lg|xl|2xl|(?:max|min)-[^:]+|@[^:]*|dark|motion-safe|motion-reduce|pointer-[a-z]+|print|portrait|landscape):/;
    const offenders: Array<string> = [];
    for (const f of uiFiles) {
      for (const [, , literal = ''] of f.text.matchAll(
        /(['"`])([^'"`\n]*)\1/g
      )) {
        const tokens = literal.split(/\s+/);
        const base = tokens.some(
          (token) => display.test(token) && shipsClass(token)
        );
        const variant = tokens.some(
          (token) =>
            mediaVariant.test(token) &&
            display.test(token.slice(token.lastIndexOf(':') + 1)) &&
            !shipsClass(token)
        );
        if (base && variant) offenders.push(`${f.rel}: ${literal}`);
      }
    }
    expect(offenders).toEqual([]);
  });

  it('keeps the runner kit free of preset props and preset reads', () => {
    // Preset differences come from the stage's scope class (neo: variant),
    // so a kit part never takes or reads a preset.
    const kit = uiFiles.filter((f) =>
      f.rel.startsWith('components/runner-kit/')
    );
    expect(kit.length).toBeGreaterThanOrEqual(10);
    for (const part of kit) {
      expect(
        /\bpreset\??:\s*(?:[A-Z]\w*|['"])|\bpreset=\{|\busePreset\b/.test(
          part.text
        ),
        part.rel
      ).toBe(false);
    }
  });
});
