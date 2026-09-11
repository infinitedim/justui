import { describe, expect, it } from 'vitest';
import * as fs from 'node:fs';
import * as path from 'node:path';

const FILES_TO_VERIFY = [
  'src/lib/stage-bridge.ts',
  'src/components/molecules/install-tabs/install-tabs.types.ts',
  'src/components/molecules/install-tabs/install-tabs.tsx',
  'src/components/molecules/install-tabs/index.ts',
  'src/components/organisms/interactive-terminal/keystroke-engine.ts',
  'src/components/organisms/interactive-terminal/levenshtein.ts',
  'src/components/organisms/interactive-terminal/cli-parser.ts',
  'src/components/organisms/interactive-terminal/interactive-terminal.types.ts',
  'src/components/organisms/interactive-terminal/interactive-terminal.tsx',
  'src/components/organisms/interactive-terminal/index.ts',
  'src/components/organisms/living-stage/living-stage.types.ts',
  'src/components/organisms/living-stage/stage-widget-registry.tsx',
  'src/components/organisms/living-stage/living-stage.tsx',
  'src/components/organisms/living-stage/index.ts',
  'src/components/organisms/hero-interactive/hero-interactive.types.ts',
  'src/components/organisms/hero-interactive/hero-interactive.tsx',
  'src/components/organisms/hero-interactive/index.ts',
  'src/app/globals.css',
  'src/lib/homepage-translations.ts',
  'src/app/[lang]/page.tsx',
  'test/setup.ts',
  'test/homepage.test.tsx',
  'test/keystroke-engine.test.ts',
  'test/levenshtein.test.ts',
  'test/cli-parser.test.ts',
  'test/install-tabs.test.tsx',
  'test/interactive-terminal.test.tsx',
  'test/living-stage.test.tsx',
  'test/stage-bridge.test.ts',
  'test/hero-interactive.test.tsx',
];

describe('Strict ASCII Purity Check', () => {
  it.each(FILES_TO_VERIFY)('file %s contains 100% pure ASCII bytes', (relPath) => {
    const fullPath = path.resolve(__dirname, '..', relPath);
    expect(fs.existsSync(fullPath)).toBe(true);

    const buf = fs.readFileSync(fullPath);
    for (let i = 0; i < buf.length; i++) {
      const byte = buf[i];
      if (byte > 127) {
        throw new Error(
          `Non-ASCII byte ${byte} (0x${byte.toString(16)}) found at index ${i} in ${relPath}`
        );
      }
    }
  });
});
