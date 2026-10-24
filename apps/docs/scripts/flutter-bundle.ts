import { createHash } from 'node:crypto';
import { readFileSync, readdirSync, statSync } from 'node:fs';
import path from 'node:path';
import { brotliCompressSync, constants } from 'node:zlib';

/**
 * Files of `flutter build web --wasm` that the docs serve from `/flutter/`.
 *
 * The docs load Flutter only on Blink with WasmGC, with `renderer: 'skwasm'`
 * (see `src/lib/flutter-bridge`), so the dart2js and CanvasKit outputs, debug
 * symbols, the service worker and the standalone harness are never fetched
 * and are pruned. `skwasm_heavy` stays: the loader picks it when the browser
 * lacks image codecs or Chromium break iterators.
 */
export const BUNDLE_KEEP: readonly RegExp[] = [
  /^flutter_bootstrap\.js$/,
  /^main\.dart\.(mjs|wasm)$/,
  /^canvaskit\/skwasm(_heavy)?\.(js|wasm)$/,
  /^assets\/(AssetManifest\.bin|AssetManifest\.bin\.json|FontManifest\.json|NOTICES)$/,
  /^assets\/fonts\/MaterialIcons-Regular\.otf$/,
  /^assets\/assets\/fonts\/[A-Za-z]+-[A-Za-z]+\.ttf$/,
  /^assets\/shaders\/[a-z_]+\.frag$/,
];

/**
 * What a Blink browser fetches to start the bridge: the budget applies to
 * these (fonts are fetched at engine start, so they count too).
 */
export const BUNDLE_STARTUP: readonly RegExp[] = [
  /^flutter_bootstrap\.js$/,
  /^main\.dart\.(mjs|wasm)$/,
  /^canvaskit\/skwasm\.(js|wasm)$/,
  /^assets\/(AssetManifest\.bin\.json|FontManifest\.json)$/,
  /^assets\/fonts\/MaterialIcons-Regular\.otf$/,
  /^assets\/assets\/fonts\/[A-Za-z]+-[A-Za-z]+\.ttf$/,
];

/** Files every working bundle must contain. */
export const BUNDLE_REQUIRED: readonly string[] = [
  'flutter_bootstrap.js',
  'main.dart.mjs',
  'main.dart.wasm',
  'canvaskit/skwasm.js',
  'canvaskit/skwasm.wasm',
  'assets/FontManifest.json',
  'assets/NOTICES',
];

/** One file of the bundle, as written to `bundle.json`. */
export interface BundleFile {
  path: string;
  bytes: number;
  brotli: number;
  sha256: string;
}

/** True when [file] (a `/`-separated path) matches one of [patterns]. */
export function matchesAny(file: string, patterns: readonly RegExp[]): boolean {
  return patterns.some((pattern) => pattern.test(file));
}

/** Every file under [dir], as sorted `/`-separated relative paths. */
export function listFiles(dir: string): string[] {
  const out: string[] = [];
  const walk = (current: string): void => {
    for (const name of readdirSync(current)) {
      const full = path.join(current, name);
      if (statSync(full).isDirectory()) walk(full);
      else out.push(path.relative(dir, full).split(path.sep).join('/'));
    }
  };
  walk(dir);
  return out.sort();
}

/** Size, brotli size (quality 11, what a CDN serves) and SHA-256 of a file. */
export function describeFile(dir: string, file: string): BundleFile {
  const data = readFileSync(path.join(dir, file));
  const brotli = brotliCompressSync(data, {
    params: { [constants.BROTLI_PARAM_QUALITY]: 11 },
  }).length;
  const sha256 = createHash('sha256').update(data).digest('hex');
  return { path: file, bytes: data.length, brotli, sha256 };
}

/** Sum of the brotli sizes of the startup files in [files]. */
export function startupBrotli(files: readonly BundleFile[]): number {
  return files
    .filter((file) => matchesAny(file.path, BUNDLE_STARTUP))
    .reduce((sum, file) => sum + file.brotli, 0);
}
