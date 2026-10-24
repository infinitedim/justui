// Resolves the Flutter SDK release for the Vercel build from .fvmrc and
// Flutter's official release index, and prints "<version> <url> <sha256>".
//
// .fvmrc holds either an exact version ("3.47.8") or "stable" (the owner
// follows the stable channel). Both resolve through releases_linux.json on
// Google's storage, over HTTPS; vercel-build.sh then checks the downloaded
// archive against the SHA-256 listed there.
import { readFileSync } from 'node:fs';
import path from 'node:path';

const INDEX_BASE =
  'https://storage.googleapis.com/flutter_infra_release/releases';
const INDEX_URL = `${INDEX_BASE}/releases_linux.json`;

interface Release {
  hash: string;
  channel: string;
  version: string;
  archive: string;
  sha256: string;
}

function isRelease(value: unknown): value is Release {
  return (
    typeof value === 'object' &&
    value !== null &&
    ['hash', 'channel', 'version', 'archive', 'sha256'].every(
      (key) => typeof Reflect.get(value, key) === 'string'
    )
  );
}

/** The channel or exact version .fvmrc asks for. */
export function fvmrcFlutter(text: string): string {
  const parsed: unknown = JSON.parse(text);
  const value: unknown =
    typeof parsed === 'object' && parsed !== null
      ? Reflect.get(parsed, 'flutter')
      : undefined;
  if (typeof value === 'string' && /^(stable|\d+\.\d+\.\d+)$/.test(value)) {
    return value;
  }
  throw new Error('.fvmrc must name "stable" or an exact Flutter version');
}

/** Picks the stable release [wanted] names from the parsed release index. */
export function pickRelease(index: unknown, wanted: string): Release {
  if (typeof index !== 'object' || index === null) throw new Error('bad index');
  const releases: unknown = Reflect.get(index, 'releases');
  const current: unknown = Reflect.get(index, 'current_release');
  if (!Array.isArray(releases)) throw new Error('index has no releases');
  const stableHash: unknown =
    typeof current === 'object' && current !== null
      ? Reflect.get(current, 'stable')
      : undefined;
  const release = releases
    .filter(isRelease)
    .find((entry) =>
      wanted === 'stable'
        ? entry.hash === stableHash
        : entry.version === wanted && entry.channel === 'stable'
    );
  if (!release) throw new Error(`no stable Flutter release for "${wanted}"`);
  if (
    !/^[0-9a-f]{64}$/.test(release.sha256) ||
    !/^stable\/linux\/flutter_linux_[0-9.]+-stable\.tar\.xz$/.test(
      release.archive
    )
  ) {
    throw new Error('release entry has an unexpected archive or sha256');
  }
  return release;
}

async function main(): Promise<void> {
  const repoRoot = path.resolve(import.meta.dirname, '../../..');
  const wanted = fvmrcFlutter(
    readFileSync(path.join(repoRoot, '.fvmrc'), 'utf-8')
  );
  const response = await fetch(INDEX_URL);
  if (!response.ok) throw new Error(`release index: HTTP ${response.status}`);
  const release = pickRelease(await response.json(), wanted);
  console.log(
    `${release.version} ${INDEX_BASE}/${release.archive} ${release.sha256}`
  );
}

if (import.meta.main) {
  main().catch((error: unknown) => {
    console.error(`flutter-release: ${String(error)}`);
    process.exit(1);
  });
}
