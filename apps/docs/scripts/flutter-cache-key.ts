// Prints the cache key of the Flutter bridge bundle: a SHA-256 over every
// input that can change the build output, plus the resolved Flutter version
// (argument 1; .fvmrc may say "stable"). vercel-build.sh reuses a cached
// bundle only when this key matches (owner decision 61).
import { createHash } from 'node:crypto';
import { existsSync, readFileSync, statSync } from 'node:fs';
import path from 'node:path';
import { listFiles } from './flutter-bundle';

const repoRoot = path.resolve(import.meta.dirname, '../../..');

/** Files and folders (relative to the repo root) the bundle depends on. */
export const CACHE_INPUTS: readonly string[] = [
  '.fvmrc',
  'pubspec.yaml',
  'pubspec.lock',
  'apps/showcase/pubspec.yaml',
  'apps/showcase/analysis_options.yaml',
  'apps/showcase/lib',
  'apps/showcase/web',
  'packages/core/pubspec.yaml',
  'packages/core/lib',
  'packages/tokens/pubspec.yaml',
  'packages/tokens/lib',
  'packages/tokens/assets/fonts',
  'apps/docs/scripts/build-flutter.ts',
  'apps/docs/scripts/flutter-bundle.ts',
];

/** Every input file, as sorted repo-relative paths. */
function inputFiles(): string[] {
  return CACHE_INPUTS.flatMap((input) => {
    const full = path.join(repoRoot, input);
    if (!existsSync(full)) throw new Error(`cache input missing: ${input}`);
    return statSync(full).isDirectory()
      ? listFiles(full).map((file) => `${input}/${file}`)
      : [input];
  }).sort();
}

/** SHA-256 over the Flutter version and each file's path and content. */
export function cacheKey(flutterVersion: string): string {
  const hash = createHash('sha256');
  hash.update(`flutter ${flutterVersion}\0`);
  for (const file of inputFiles()) {
    hash.update(`${file}\0`);
    hash.update(readFileSync(path.join(repoRoot, file)));
    hash.update('\0');
  }
  return hash.digest('hex');
}

if (import.meta.main) {
  const version = process.argv[2] ?? '';
  if (!/^\d+\.\d+\.\d+$/.test(version)) {
    console.error('flutter-cache-key: pass the resolved Flutter version');
    process.exit(1);
  }
  console.log(cacheKey(version));
}
