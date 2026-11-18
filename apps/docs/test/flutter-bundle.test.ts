import { describe, expect, it } from 'vitest';
import {
  BUNDLE_KEEP,
  BUNDLE_REQUIRED,
  BUNDLE_STARTUP,
  canonicalBundlePath,
  matchesAny,
  missingRequiredFiles,
  startupBrotli,
} from '../scripts/flutter-bundle';
import { validateBudget } from '../scripts/check-flutter-budget';

// A file list as `flutter build web --wasm` (3.47.5) writes it.
const BUILD_OUTPUT = [
  '.last_build_id',
  'assets/AssetManifest.bin',
  'assets/AssetManifest.bin.json',
  'assets/FontManifest.json',
  'assets/NOTICES',
  'assets/assets/fonts/PlusJakartaSans-Regular.ttf',
  'assets/fonts/MaterialIcons-Regular.otf',
  'assets/shaders/ink_sparkle.frag',
  'canvaskit/canvaskit.js',
  'canvaskit/canvaskit.wasm',
  'canvaskit/chromium/canvaskit.wasm',
  'canvaskit/skwasm.js',
  'canvaskit/skwasm.js.symbols',
  'canvaskit/skwasm.wasm',
  'canvaskit/skwasm_heavy.js',
  'canvaskit/skwasm_heavy.wasm',
  'canvaskit/webparagraph/canvaskit.wasm',
  'canvaskit/wimp.wasm',
  'favicon.png',
  'flutter.js',
  'flutter_bootstrap.js',
  'flutter_service_worker.js',
  'harness.js',
  'index.html',
  'main.dart.js',
  'main.dart.mjs',
  'main.dart.wasm',
  'version.json',
];

// A file list as `flutter build web --wasm --web-content-hash` (3.50.0) writes it.
const HASHED_BUILD_OUTPUT = [
  '.last_build_id',
  'assets/AssetManifest.bin.4a953295.json',
  'assets/AssetManifest.ef0ff11c.bin',
  'assets/FontManifest.a5521d6c.json',
  'assets/NOTICES.5872c81f',
  'assets/assets/fonts/PlusJakartaSans-Regular.6bcfbb10.ttf',
  'assets/fonts/MaterialIcons-Regular.6ceb7564.otf',
  'assets/packages/material_ui/shaders/ink_sparkle.2dca5ab9.frag',
  'assets/shaders/stretch_effect.ab412f07.frag',
  'canvaskit/canvaskit.js',
  'canvaskit/canvaskit.wasm',
  'canvaskit/skwasm.js',
  'canvaskit/skwasm.js.symbols',
  'canvaskit/skwasm.wasm',
  'canvaskit/skwasm_heavy.js',
  'canvaskit/skwasm_heavy.wasm',
  'flutter.js.map',
  'flutter_bootstrap.js',
  'flutter_service_worker.js',
  'harness.js',
  'index.html',
  'main.dart.19a4ccc8.wasm',
  'main.dart.2c5cde3a.mjs',
  'main.dart.89c78c92.js',
  'precache_manifest.json',
  'version.json',
];

describe('flutter bundle allowlist', () => {
  const kept = BUILD_OUTPUT.filter((file) => matchesAny(file, BUNDLE_KEEP));

  it('keeps the skwasm path, assets and fonts', () => {
    expect(kept).toEqual([
      'assets/AssetManifest.bin',
      'assets/AssetManifest.bin.json',
      'assets/FontManifest.json',
      'assets/NOTICES',
      'assets/assets/fonts/PlusJakartaSans-Regular.ttf',
      'assets/fonts/MaterialIcons-Regular.otf',
      'assets/shaders/ink_sparkle.frag',
      'canvaskit/skwasm.js',
      'canvaskit/skwasm.wasm',
      'canvaskit/skwasm_heavy.js',
      'canvaskit/skwasm_heavy.wasm',
      'flutter_bootstrap.js',
      'main.dart.mjs',
      'main.dart.wasm',
    ]);
  });

  it('drops the JS fallback, CanvasKit, symbols, service worker and harness', () => {
    for (const file of [
      'main.dart.js',
      'canvaskit/canvaskit.wasm',
      'canvaskit/skwasm.js.symbols',
      'flutter_service_worker.js',
      'harness.js',
      'index.html',
    ]) {
      expect(matchesAny(file, BUNDLE_KEEP)).toBe(false);
    }
  });

  it('requires only kept files', () => {
    for (const file of BUNDLE_REQUIRED) {
      expect(matchesAny(file, BUNDLE_KEEP)).toBe(true);
    }
  });

  it('counts only startup files in the startup size', () => {
    const files = kept.map((file) => ({
      path: file,
      bytes: 1,
      brotli: 1,
      sha256: '',
    }));
    const startup = kept.filter((file) => matchesAny(file, BUNDLE_STARTUP));
    expect(startup).not.toContain('canvaskit/skwasm_heavy.wasm');
    expect(startup).not.toContain('assets/NOTICES');
    expect(startupBrotli(files)).toBe(startup.length);
  });
});

describe('flutter 3.50 content-hashed bundle', () => {
  const hashedKept = HASHED_BUILD_OUTPUT.filter((file) =>
    matchesAny(file, BUNDLE_KEEP)
  );

  it('keeps hashed skwasm, manifests, fonts, and root shaders while pruning extras', () => {
    expect(hashedKept).toEqual([
      'assets/AssetManifest.bin.4a953295.json',
      'assets/AssetManifest.ef0ff11c.bin',
      'assets/FontManifest.a5521d6c.json',
      'assets/NOTICES.5872c81f',
      'assets/assets/fonts/PlusJakartaSans-Regular.6bcfbb10.ttf',
      'assets/fonts/MaterialIcons-Regular.6ceb7564.otf',
      'assets/shaders/stretch_effect.ab412f07.frag',
      'canvaskit/skwasm.js',
      'canvaskit/skwasm.wasm',
      'canvaskit/skwasm_heavy.js',
      'canvaskit/skwasm_heavy.wasm',
      'flutter_bootstrap.js',
      'main.dart.19a4ccc8.wasm',
      'main.dart.2c5cde3a.mjs',
    ]);
    for (const dropped of [
      'main.dart.89c78c92.js',
      'precache_manifest.json',
      'assets/packages/material_ui/shaders/ink_sparkle.2dca5ab9.frag',
      'flutter.js.map',
    ]) {
      expect(matchesAny(dropped, BUNDLE_KEEP)).toBe(false);
    }
  });

  it('strips 8-hex content hashes to canonical bundle paths', () => {
    expect(canonicalBundlePath('main.dart.19a4ccc8.wasm')).toBe(
      'main.dart.wasm'
    );
    expect(canonicalBundlePath('main.dart.2c5cde3a.mjs')).toBe('main.dart.mjs');
    expect(canonicalBundlePath('assets/AssetManifest.ef0ff11c.bin')).toBe(
      'assets/AssetManifest.bin'
    );
    expect(canonicalBundlePath('assets/AssetManifest.bin.4a953295.json')).toBe(
      'assets/AssetManifest.bin.json'
    );
    expect(canonicalBundlePath('assets/NOTICES.5872c81f')).toBe(
      'assets/NOTICES'
    );
    expect(
      canonicalBundlePath('assets/fonts/MaterialIcons-Regular.6ceb7564.otf')
    ).toBe('assets/fonts/MaterialIcons-Regular.otf');
    expect(canonicalBundlePath('canvaskit/skwasm.wasm')).toBe(
      'canvaskit/skwasm.wasm'
    );
    expect(canonicalBundlePath('flutter_bootstrap.js')).toBe(
      'flutter_bootstrap.js'
    );
  });

  it('validates required canonical files across hashed outputs', () => {
    expect(missingRequiredFiles(hashedKept)).toEqual([]);
    const withoutNotices = hashedKept.filter(
      (file) => !file.startsWith('assets/NOTICES')
    );
    expect(missingRequiredFiles(withoutNotices)).toEqual(['assets/NOTICES']);
  });
});

describe('flutter budget validation', () => {
  const budget = {
    startupKb: 100,
    filesKb: {
      'canvaskit/skwasm.wasm': 50,
      'main.dart.wasm': 50,
    },
  };

  function makeFiles(entries: Array<[string, number]>) {
    return entries.map(([file, brotli]) => ({
      path: file,
      bytes: brotli,
      brotli,
      sha256: `sha-${file}`,
    }));
  }

  it('checks hashed file sizes against canonical filesKb keys', () => {
    const okFiles = makeFiles([
      ['flutter_bootstrap.js', 1024],
      ['canvaskit/skwasm.js', 1024],
      ['canvaskit/skwasm.wasm', 20 * 1024],
      ['main.dart.2c5cde3a.mjs', 1024],
      ['main.dart.19a4ccc8.wasm', 30 * 1024],
      ['assets/FontManifest.a5521d6c.json', 512],
      ['assets/NOTICES.5872c81f', 1024],
    ]);
    expect(validateBudget({ files: okFiles }, budget, okFiles).errors).toEqual(
      []
    );

    const oversized = makeFiles([
      ['flutter_bootstrap.js', 1024],
      ['canvaskit/skwasm.js', 1024],
      ['canvaskit/skwasm.wasm', 20 * 1024],
      ['main.dart.2c5cde3a.mjs', 1024],
      ['main.dart.19a4ccc8.wasm', 60 * 1024],
      ['assets/FontManifest.a5521d6c.json', 512],
      ['assets/NOTICES.5872c81f', 1024],
    ]);
    expect(
      validateBudget({ files: oversized }, budget, oversized).errors
    ).toEqual(['main.dart.wasm: 60.0 KB > 50 KB']);
  });

  it('fails when any budget.filesKb key has zero matching files or duplicates', () => {
    const missingMainWasm = makeFiles([
      ['flutter_bootstrap.js', 1024],
      ['canvaskit/skwasm.js', 1024],
      ['canvaskit/skwasm.wasm', 20 * 1024],
      ['main.dart.2c5cde3a.mjs', 1024],
      ['assets/FontManifest.a5521d6c.json', 512],
      ['assets/NOTICES.5872c81f', 1024],
    ]);
    expect(
      validateBudget({ files: missingMainWasm }, budget, missingMainWasm).errors
    ).toContain('main.dart.wasm: missing from bundle');

    const duplicated = makeFiles([
      ['flutter_bootstrap.js', 1024],
      ['canvaskit/skwasm.js', 1024],
      ['canvaskit/skwasm.wasm', 20 * 1024],
      ['main.dart.2c5cde3a.mjs', 1024],
      ['main.dart.19a4ccc8.wasm', 20 * 1024],
      ['main.dart.deadbeef.wasm', 20 * 1024],
      ['assets/FontManifest.a5521d6c.json', 512],
      ['assets/NOTICES.5872c81f', 1024],
    ]);
    expect(
      validateBudget({ files: duplicated }, budget, duplicated).errors
    ).toContain(
      'main.dart.wasm: multiple matching files (main.dart.19a4ccc8.wasm, main.dart.deadbeef.wasm)'
    );
  });
});
