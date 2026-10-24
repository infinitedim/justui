// Checks public/flutter/ (built by `bun run flutter:build`): only allowed
// files, every file matches bundle.json, and brotli sizes stay within
// scripts/flutter-budget.json.
import { existsSync, readFileSync } from 'node:fs';
import path from 'node:path';
import {
  BUNDLE_KEEP,
  describeFile,
  listFiles,
  matchesAny,
  startupBrotli,
  type BundleFile,
} from './flutter-bundle';

const outDir = path.resolve(import.meta.dirname, '../public/flutter');
const KB = 1024;

interface Budget {
  startupKb: number;
  filesKb: Record<string, number>;
}

function isBudget(value: unknown): value is Budget {
  return (
    typeof value === 'object' &&
    value !== null &&
    'startupKb' in value &&
    typeof value.startupKb === 'number' &&
    'filesKb' in value &&
    typeof value.filesKb === 'object' &&
    value.filesKb !== null &&
    Object.values(value.filesKb).every((kb) => typeof kb === 'number')
  );
}

function isBundleFileList(value: unknown): value is BundleFile[] {
  return (
    Array.isArray(value) &&
    value.every(
      (file: unknown) =>
        typeof file === 'object' &&
        file !== null &&
        'path' in file &&
        typeof file.path === 'string' &&
        'sha256' in file &&
        typeof file.sha256 === 'string'
    )
  );
}

function check(): string[] {
  const errors: string[] = [];
  const manifestPath = path.join(outDir, 'bundle.json');
  if (!existsSync(manifestPath)) {
    return [
      'public/flutter/bundle.json not found; run "bun run flutter:build"',
    ];
  }
  const manifest: unknown = JSON.parse(readFileSync(manifestPath, 'utf-8'));
  const listed =
    typeof manifest === 'object' && manifest !== null && 'files' in manifest
      ? manifest.files
      : undefined;
  const budget: unknown = JSON.parse(
    readFileSync(path.join(import.meta.dirname, 'flutter-budget.json'), 'utf-8')
  );
  if (!isBundleFileList(listed)) return ['bundle.json has no valid file list'];
  if (!isBudget(budget)) return ['flutter-budget.json has an invalid shape'];

  const onDisk = listFiles(outDir).filter((file) => file !== 'bundle.json');
  for (const file of onDisk.filter((f) => !matchesAny(f, BUNDLE_KEEP))) {
    errors.push(`unexpected file ${file} (not in BUNDLE_KEEP)`);
  }
  const actual = onDisk.map((file) => describeFile(outDir, file));
  const expected = new Map(listed.map((file) => [file.path, file.sha256]));
  for (const file of actual) {
    if (expected.get(file.path) !== file.sha256) {
      errors.push(`${file.path} does not match bundle.json`);
    }
  }
  for (const [file, kb] of Object.entries(budget.filesKb)) {
    const found = actual.find((entry) => entry.path === file);
    if (found && found.brotli > kb * KB) {
      errors.push(`${file}: ${(found.brotli / KB).toFixed(1)} KB > ${kb} KB`);
    }
  }
  const startup = startupBrotli(actual);
  console.log(
    `Flutter startup download (brotli): ${(startup / KB).toFixed(1)} KB (budget ${budget.startupKb} KB)`
  );
  if (startup > budget.startupKb * KB) errors.push('startup budget exceeded');
  return errors;
}

const errors = check();
if (errors.length > 0) {
  for (const error of errors) console.error(`flutter:budget: ${error}`);
  process.exit(1);
}
console.log('Flutter bundle budget check passed.');
