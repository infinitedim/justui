// Lighthouse Performance gates for the pages with live Flutter parts.
//
//   bun run perf:lighthouse                  # gates (exit 1 below a gate)
//   bun run perf:lighthouse --block-flutter  # React-only baseline, no gates
//
// Needs a production server (`bun run build && bun run start`) and Chrome.
// Runs the Lighthouse CLI with argument arrays (no shell); JSON reports go
// to .lighthouse/ (gitignored).
import { spawnSync } from 'node:child_process';
import { mkdirSync, readFileSync } from 'node:fs';
import path from 'node:path';

const DEVICES = ['desktop', 'mobile'] as const;
type Device = (typeof DEVICES)[number];

interface Gates {
  pages: Record<string, Record<Device, number>>;
}

function isGates(value: unknown): value is Gates {
  return (
    typeof value === 'object' &&
    value !== null &&
    'pages' in value &&
    typeof value.pages === 'object' &&
    value.pages !== null &&
    Object.values(value.pages).every(
      (gate: unknown) =>
        typeof gate === 'object' &&
        gate !== null &&
        'desktop' in gate &&
        typeof gate.desktop === 'number' &&
        'mobile' in gate &&
        typeof gate.mobile === 'number'
    )
  );
}

const baseUrl = process.env.LIGHTHOUSE_BASE_URL ?? 'http://localhost:3000';
const blockFlutter = process.argv.includes('--block-flutter');
const outDir = path.resolve(import.meta.dirname, '../.lighthouse');
const bin = path.resolve(
  import.meta.dirname,
  '../node_modules/.bin/lighthouse'
);

/** `categories.performance.score` of a Lighthouse JSON report. */
function performanceScore(report: unknown): unknown {
  if (typeof report !== 'object' || report === null) return null;
  const categories: unknown = Reflect.get(report, 'categories');
  if (typeof categories !== 'object' || categories === null) return null;
  const performance: unknown = Reflect.get(categories, 'performance');
  if (typeof performance !== 'object' || performance === null) return null;
  const score: unknown = Reflect.get(performance, 'score');
  return score;
}

/** Performance score (0-100) of one run, or null when Lighthouse failed. */
function audit(page: string, device: Device): number | null {
  const name = `${page.replace(/\W+/g, '_')}-${device}${blockFlutter ? '-react' : ''}`;
  const output = path.join(outDir, `${name}.json`);
  const args = [
    `${baseUrl}${page}`,
    '--only-categories=performance',
    // The 404 page answers with status 404 on purpose.
    '--ignore-status-code',
    '--output=json',
    `--output-path=${output}`,
    '--chrome-flags=--headless=new',
    '--quiet',
  ];
  if (device === 'desktop') args.push('--preset=desktop');
  if (blockFlutter) args.push('--blocked-url-patterns=*/flutter/*');
  const result = spawnSync(bin, args, { stdio: 'inherit' });
  if (result.status !== 0) return null;
  const report: unknown = JSON.parse(readFileSync(output, 'utf-8'));
  const score = performanceScore(report);
  return typeof score === 'number' ? Math.round(score * 100) : null;
}

function main(): void {
  const gates: unknown = JSON.parse(
    readFileSync(
      path.join(import.meta.dirname, 'lighthouse-gates.json'),
      'utf-8'
    )
  );
  if (!isGates(gates))
    throw new Error('lighthouse-gates.json has an invalid shape');
  mkdirSync(outDir, { recursive: true });
  const failures: string[] = [];
  for (const [page, gate] of Object.entries(gates.pages)) {
    for (const device of DEVICES) {
      const score = audit(page, device);
      const verdict =
        score === null ? 'FAILED TO RUN' : `${score} (gate ${gate[device]})`;
      console.log(`${device.padEnd(7)} ${page}: ${verdict}`);
      if (!blockFlutter && (score === null || score < gate[device])) {
        failures.push(`${device} ${page}`);
      }
    }
  }
  if (failures.length > 0) {
    console.error(`Below the Performance gate: ${failures.join(', ')}`);
    process.exit(1);
  }
}

main();
