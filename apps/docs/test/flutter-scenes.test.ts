import * as fs from 'node:fs';
import * as path from 'node:path';
import { describe, expect, it } from 'vitest';
import { FLUTTER_SCENES } from '@/lib/flutter-bridge';
import { PART_SLUGS } from '@/lib/parts';

const scenesDir = path.resolve(__dirname, '../../showcase/lib/scenes');

/** Slugs keyed in the Dart `<group>_scenes.dart` maps. */
function dartScenes(): Array<string> {
  return fs
    .readdirSync(scenesDir, { recursive: true, encoding: 'utf8' })
    .filter((file) => file.endsWith('_scenes.dart'))
    .flatMap((file) =>
      Array.from(
        fs
          .readFileSync(path.join(scenesDir, file), 'utf8')
          .matchAll(/^\s*'([a-z-]+)': \w+,$/gm),
        (match) => match[1] ?? ''
      )
    )
    .sort();
}

describe('flutter scenes', () => {
  it('match the scenes registered in apps/showcase', () => {
    expect([...FLUTTER_SCENES].sort()).toEqual(dartScenes());
  });

  it('are real part slugs', () => {
    for (const scene of FLUTTER_SCENES) expect(PART_SLUGS).toContain(scene);
  });
});
