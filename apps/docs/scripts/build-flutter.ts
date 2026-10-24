// Builds the apps/showcase bridge (Flutter web, Wasm) into public/flutter/.
//
// Local: `bun run flutter:build` uses `fvm flutter` (the .fvmrc release).
// CI and Vercel set FLUTTER_BIN to their SDK. bundle.json records the
// version that built the bundle. Commands run with argument arrays (no
// shell). The output is pruned to BUNDLE_KEEP and described in bundle.json
// (sizes and SHA-256) for the budget check and the Vercel cache.
import { spawnSync } from 'node:child_process';
import { cpSync, existsSync, mkdirSync, rmSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import {
  BUNDLE_KEEP,
  BUNDLE_REQUIRED,
  describeFile,
  listFiles,
  matchesAny,
  startupBrotli,
} from './flutter-bundle';

const repoRoot = path.resolve(import.meta.dirname, '../../..');
const showcaseDir = path.join(repoRoot, 'apps/showcase');
const buildDir = path.join(showcaseDir, 'build/web');
const outDir = path.resolve(import.meta.dirname, '../public/flutter');

function fail(message: string): never {
  console.error(`flutter:build: ${message}`);
  process.exit(1);
}

/** Runs the Flutter tool in apps/showcase; returns its stdout when piped. */
function flutter(args: readonly string[], pipe = false): string {
  const bin = process.env.FLUTTER_BIN;
  const [cmd, prefix] = bin ? [bin, []] : ['fvm', ['flutter']];
  if (!pipe) console.log(`$ ${cmd} ${[...prefix, ...args].join(' ')}`);
  const result = spawnSync(cmd, [...prefix, ...args], {
    cwd: showcaseDir,
    stdio: pipe ? ['ignore', 'pipe', 'inherit'] : 'inherit',
    encoding: 'utf-8',
  });
  if (result.error) fail(`cannot run ${cmd}: ${result.error.message}`);
  if (result.status !== 0) fail(`${cmd} exited with ${result.status}`);
  return result.stdout ?? '';
}

/** The framework version of the SDK that builds the bundle. */
function flutterVersion(): string {
  const parsed: unknown = JSON.parse(flutter(['--version', '--machine'], true));
  const version: unknown =
    typeof parsed === 'object' && parsed !== null
      ? Reflect.get(parsed, 'frameworkVersion')
      : undefined;
  if (typeof version === 'string' && /^\d+\.\d+\.\d+$/.test(version)) {
    return version;
  }
  return fail('cannot read the Flutter version');
}

function build(): void {
  flutter(['pub', 'get', '--enforce-lockfile']);
  flutter([
    'build',
    'web',
    '--wasm',
    '--release',
    '--no-web-resources-cdn',
    '--no-source-maps',
    '--base-href',
    '/flutter/',
  ]);
}

function copyPruned(): string[] {
  const files = listFiles(buildDir);
  const kept = files.filter((file) => matchesAny(file, BUNDLE_KEEP));
  const missing = BUNDLE_REQUIRED.filter((file) => !kept.includes(file));
  if (missing.length > 0) fail(`build is missing ${missing.join(', ')}`);
  rmSync(outDir, { recursive: true, force: true });
  for (const file of kept) {
    mkdirSync(path.dirname(path.join(outDir, file)), { recursive: true });
    cpSync(path.join(buildDir, file), path.join(outDir, file));
  }
  console.log(`Pruned ${files.length - kept.length} of ${files.length} files.`);
  return kept;
}

function main(): void {
  const version = flutterVersion();
  build();
  if (!existsSync(buildDir)) fail(`no build output at ${buildDir}`);
  const files = copyPruned().map((file) => describeFile(outDir, file));
  writeFileSync(
    path.join(outDir, 'bundle.json'),
    `${JSON.stringify({ flutter: version, files }, null, 2)}\n`
  );
  for (const file of files) {
    console.log(
      `${(file.brotli / 1024).toFixed(1).padStart(9)} KB br  ${file.path}`
    );
  }
  console.log(
    `Startup download (brotli): ${(startupBrotli(files) / 1024).toFixed(1)} KB`
  );
}

main();
