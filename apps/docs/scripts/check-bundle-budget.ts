import { existsSync, readFileSync, statSync } from 'node:fs';
import path from 'node:path';

interface BuildManifest {
  rootMainFiles: Array<string>;
}

const BUDGETS = {
  sharedMainBundle: 500 * 1024,
  singleChunkMax: 850 * 1024,
};

function isBuildManifest(val: unknown): val is BuildManifest {
  return (
    typeof val === 'object' &&
    val !== null &&
    'rootMainFiles' in val &&
    Array.isArray(val.rootMainFiles)
  );
}

function checkBudgets(): void {
  const dotNext = path.resolve(import.meta.dirname, '../.next');
  const manifestPath = path.join(dotNext, 'build-manifest.json');

  if (!existsSync(manifestPath)) {
    console.error(
      'Error: .next/build-manifest.json not found. Run "bun run build" first.'
    );
    process.exit(1);
  }

  const parsed: unknown = JSON.parse(readFileSync(manifestPath, 'utf-8'));
  if (!isBuildManifest(parsed)) {
    console.error('Error: invalid build-manifest.json shape.');
    process.exit(1);
  }

  const manifest = parsed;
  let rootMainSize = 0;

  for (const file of manifest.rootMainFiles) {
    const filePath = path.join(dotNext, file);
    if (existsSync(filePath)) {
      const size = statSync(filePath).size;
      rootMainSize += size;
      if (size > BUDGETS.singleChunkMax) {
        console.error(
          `Chunk budget exceeded: ${file} is ${(size / 1024).toFixed(1)} KB (budget: ${(BUDGETS.singleChunkMax / 1024).toFixed(1)} KB)`
        );
        process.exit(1);
      }
    }
  }

  console.log(
    `Root main JS size: ${(rootMainSize / 1024).toFixed(1)} KB (budget: ${(BUDGETS.sharedMainBundle / 1024).toFixed(1)} KB)`
  );

  if (rootMainSize > BUDGETS.sharedMainBundle) {
    console.error('Root main JS budget exceeded!');
    process.exit(1);
  }

  console.log('Bundle budget check passed successfully.');
}

checkBudgets();
