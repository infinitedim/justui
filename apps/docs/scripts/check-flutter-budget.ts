// Checks public/flutter/ (built by `bun run flutter:build`): only allowed
// files, every file matches bundle.json, and brotli sizes stay within
// scripts/flutter-budget.json.
import { existsSync, readFileSync } from 'node:fs';
import path from 'node:path';
import {
  BUNDLE_KEEP,
  canonicalBundlePath,
  describeFile,
  listFiles,
  matchesAny,
  missingRequiredFiles,
  startupBrotli,
  type BundleFile,
} from './flutter-bundle';

const outDir = path.resolve(import.meta.dirname, '../public/flutter');
const KB = 1024;

export interface Budget {
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

function checkFileBudgets(
  actual: readonly BundleFile[],
  filesKb: Record<string, number>
): string[] {
  const errors: string[] = [];
  for (const [file, kb] of Object.entries(filesKb)) {
    const matches = actual.filter(
      (entry) => canonicalBundlePath(entry.path) === file
    );
    if (matches.length === 0) {
      errors.push(`${file}: missing from bundle`);
    } else if (matches.length > 1) {
      const names = matches.map((entry) => entry.path).join(', ');
      errors.push(`${file}: multiple matching files (${names})`);
    } else if (matches[0] && matches[0].brotli > kb * KB) {
      errors.push(
        `${file}: ${(matches[0].brotli / KB).toFixed(1)} KB > ${kb} KB`
      );
    }
  }
  return errors;
}

/** Validates manifest checksums, allowlist, required files, and budgets. */
export function validateBudget(
  manifest: unknown,
  budgetData: unknown,
  actual: readonly BundleFile[]
): { errors: string[]; startup: number; budgetKb?: number } {
  const listed =
    typeof manifest === 'object' && manifest !== null && 'files' in manifest
      ? manifest.files
      : undefined;
  if (!isBundleFileList(listed)) {
    return { errors: ['bundle.json has no valid file list'], startup: 0 };
  }
  if (!isBudget(budgetData)) {
    return {
      errors: ['flutter-budget.json has an invalid shape'],
      startup: 0,
    };
  }

  const errors: string[] = [];
  for (const file of actual) {
    if (!matchesAny(file.path, BUNDLE_KEEP)) {
      errors.push(`unexpected file ${file.path} (not in BUNDLE_KEEP)`);
    }
  }
  const actualPaths = new Set(actual.map((file) => file.path));
  for (const file of listed) {
    if (!actualPaths.has(file.path)) {
      errors.push(`${file.path} listed in bundle.json but missing on disk`);
    }
  }
  const expected = new Map(listed.map((file) => [file.path, file.sha256]));
  for (const file of actual) {
    if (expected.get(file.path) !== file.sha256) {
      errors.push(`${file.path} does not match bundle.json`);
    }
  }
  for (const missing of missingRequiredFiles(actual.map((file) => file.path))) {
    errors.push(`missing required file ${missing}`);
  }
  errors.push(...checkFileBudgets(actual, budgetData.filesKb));

  const startup = startupBrotli(actual);
  if (startup > budgetData.startupKb * KB)
    errors.push('startup budget exceeded');
  return { errors, startup, budgetKb: budgetData.startupKb };
}

function check(): { errors: string[]; startup: number; budgetKb?: number } {
  const manifestPath = path.join(outDir, 'bundle.json');
  if (!existsSync(manifestPath)) {
    return {
      errors: [
        'public/flutter/bundle.json not found; run "bun run flutter:build"',
      ],
      startup: 0,
    };
  }
  const manifest: unknown = JSON.parse(readFileSync(manifestPath, 'utf-8'));
  const budget: unknown = JSON.parse(
    readFileSync(path.join(import.meta.dirname, 'flutter-budget.json'), 'utf-8')
  );
  const onDisk = listFiles(outDir).filter((file) => file !== 'bundle.json');
  const actual = onDisk.map((file) => describeFile(outDir, file));
  return validateBudget(manifest, budget, actual);
}

function main(): void {
  const { errors, startup, budgetKb } = check();
  if (budgetKb !== undefined) {
    console.log(
      `Flutter startup download (brotli): ${(startup / KB).toFixed(1)} KB (budget ${budgetKb} KB)`
    );
  }
  if (errors.length > 0) {
    for (const error of errors) console.error(`flutter:budget: ${error}`);
    process.exit(1);
  }
  console.log('Flutter bundle budget check passed.');
}

if (import.meta.main) {
  main();
}
