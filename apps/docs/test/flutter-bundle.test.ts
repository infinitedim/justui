import { describe, expect, it } from 'vitest';
import {
  BUNDLE_KEEP,
  BUNDLE_REQUIRED,
  BUNDLE_STARTUP,
  matchesAny,
  startupBrotli,
} from '../scripts/flutter-bundle';

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
