// Mobile Web Wasm telemetry runner for apps/docs.
//
// Combines the flutter-expert bundle audit (`analyze_web_bundle.mjs`) and
// Mobile Blink CDP profiler (`profile_mobile_web.mjs`) with argument-array
// execution (no shell), zod validation, and non-blocking frame-timing output
// so shared CI runners do not flake on CPU throttling jitter.
import { spawn, spawnSync } from 'node:child_process';
import { appendFileSync, existsSync, mkdirSync, writeFileSync } from 'node:fs';
import net from 'node:net';
import path from 'node:path';
import { z } from 'zod';

const ByteTotalsSchema = z.object({
  rawBytes: z.number(),
  gzipBytes: z.number(),
  brotliBytes: z.number(),
});

const FindingSchema = z.object({
  severity: z.string(),
  message: z.string(),
});

export const BundleReportSchema = z.object({
  dir: z.string(),
  status: z.enum(['PASS', 'WARN', 'FAIL']),
  wasmReady: z.boolean(),
  hasContentHash: z.boolean(),
  usesLocalRuntime: z.boolean(),
  appCoreTotals: ByteTotalsSchema,
  initialStartupTotals: ByteTotalsSchema,
  bundledRuntimeTotals: ByteTotalsSchema,
  findings: z.array(FindingSchema),
});

export type BundleReport = z.infer<typeof BundleReportSchema>;

export const MobileProfileReportSchema = z.object({
  targetUrl: z.string(),
  device: z.object({
    name: z.string(),
    width: z.number(),
    height: z.number(),
    dpr: z.number(),
  }),
  cpuRate: z.number(),
  networkPreset: z.string(),
  requestCount: z.number(),
  failedRequests: z.array(
    z.object({
      url: z.string().optional(),
      reason: z.string().optional(),
    })
  ),
  consoleErrors: z.array(z.string()),
  totalTransferBytes: z.number(),
  transferBreakdown: z.object({
    appBytes: z.number(),
    runtimeBytes: z.number(),
    fontBytes: z.number(),
    imageBytes: z.number(),
    otherBytes: z.number(),
    fallbackFontRequests: z.number(),
  }),
  snapshot: z.object({
    renderer: z.string(),
    crossOriginIsolated: z.boolean(),
    horizontalOverflowPx: z.number(),
    flutterDetectedAtMs: z.number().nullable(),
    firstSceneAtMs: z.number().nullable(),
    flutterFirstFrameMs: z.number().nullable(),
    rafStats: z.object({
      frameCount: z.number(),
      avgFps: z.number(),
      p50Ms: z.number(),
      p95Ms: z.number(),
      p99Ms: z.number(),
      maxMs: z.number(),
      droppedOver20Ms: z.number(),
      jankOver33Ms: z.number(),
      severeOver50Ms: z.number(),
    }),
    longTasks: z.array(z.object({ durationMs: z.number() })),
  }),
  evaluation: z.object({
    status: z.enum(['PASS', 'WARN', 'FAIL']),
    findings: z.array(FindingSchema),
  }),
});

export type MobileProfileReport = z.infer<typeof MobileProfileReportSchema>;

export interface Verdict {
  ok: boolean;
  errors: string[];
  warnings: string[];
}

export interface CliOptions {
  bundleOnly: boolean;
  baseUrl: string | null;
  route: string;
  outDir: string;
}

const DEFAULT_ROUTE = '/en/docs/components';
const repoRoot = path.resolve(import.meta.dirname, '../../..');
const docsDir = path.resolve(import.meta.dirname, '..');
const skillScriptsDir = path.join(
  repoRoot,
  '.agents/skills/flutter-expert/scripts'
);

function readOptionValue(
  argv: readonly string[],
  index: number,
  flag: string
): string {
  const next = argv[index + 1];
  if (!next || next.startsWith('-')) {
    throw new Error(`Option ${flag} requires a value.`);
  }
  return next;
}

/** Parses script CLI flags with explicit validation. */
export function parseCliArgs(argv: readonly string[]): CliOptions {
  const opts: CliOptions = {
    bundleOnly: false,
    baseUrl: process.env.MOBILE_TELEMETRY_URL ?? null,
    route: DEFAULT_ROUTE,
    outDir: path.join(repoRoot, '.agents/tmp/mobile-web-telemetry'),
  };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === '--bundle-only') {
      opts.bundleOnly = true;
    } else if (arg === '--url') {
      opts.baseUrl = readOptionValue(argv, i, '--url');
      i += 1;
    } else if (arg === '--route') {
      const val = readOptionValue(argv, i, '--route');
      opts.route = val.startsWith('/') ? val : `/${val}`;
      i += 1;
    } else if (arg === '--out-dir') {
      opts.outDir = path.resolve(
        docsDir,
        readOptionValue(argv, i, '--out-dir')
      );
      i += 1;
    } else if (arg) {
      throw new Error(`Unknown or unexpected argument: ${arg}`);
    }
  }
  return opts;
}

/** Evaluates bundle telemetry; pruned `index.html` WARN is allowed. */
export function evaluateBundleReport(report: BundleReport): Verdict {
  const errors: string[] = [];
  const warnings: string[] = [];
  if (!report.wasmReady) errors.push('Flutter Wasm output is not ready.');
  if (!report.usesLocalRuntime) {
    errors.push('Flutter bundle does not use local self-hosted runtime.');
  }
  if (report.status === 'FAIL') {
    errors.push('analyze_web_bundle.mjs reported FAIL status.');
  }
  for (const finding of report.findings) {
    if (finding.severity === 'FAIL') errors.push(finding.message);
    else if (finding.severity === 'WARN') warnings.push(finding.message);
  }
  return { ok: errors.length === 0, errors, warnings };
}

function isExpectedFavicon404(req: { url?: string; reason?: string }): boolean {
  return Boolean(
    req.url &&
    /\/favicon\.ico(?:$|\?)/.test(req.url) &&
    req.reason === 'HTTP 404'
  );
}

/**
 * Evaluates Mobile Blink telemetry; fails only on boot, renderer, console, or
 * failed-request errors while keeping CPU-throttled timing non-blocking.
 */
export function evaluateMobileProfileReport(
  report: MobileProfileReport
): Verdict {
  const errors: string[] = [];
  const warnings: string[] = [];
  const { snapshot, consoleErrors, failedRequests } = report;

  if (snapshot.flutterDetectedAtMs === null) {
    errors.push('Flutter Web root failed to mount on Mobile Blink.');
  }
  if (snapshot.renderer !== 'skwasm-wasm') {
    errors.push(`Expected skwasm-wasm renderer, got "${snapshot.renderer}".`);
  }

  const favicon404Count = failedRequests.filter(isExpectedFavicon404).length;
  const unexpectedFailed = failedRequests.filter(
    (req) => !isExpectedFavicon404(req)
  );
  const resource404Errors = consoleErrors.filter((msg) =>
    msg.includes('status of 404 (Not Found)')
  );
  const otherConsoleErrors = consoleErrors.filter(
    (msg) => !msg.includes('status of 404 (Not Found)')
  );
  const unexpectedConsoleCount =
    otherConsoleErrors.length +
    Math.max(0, resource404Errors.length - favicon404Count);

  if (unexpectedConsoleCount > 0) {
    errors.push(`${unexpectedConsoleCount} runtime/console error(s) detected.`);
  }
  if (unexpectedFailed.length > 0) {
    errors.push(`${unexpectedFailed.length} failed network request(s).`);
  }
  if (snapshot.horizontalOverflowPx > 0) {
    warnings.push(
      `Mobile horizontal overflow: ${snapshot.horizontalOverflowPx}px.`
    );
  }
  for (const finding of report.evaluation.findings) {
    if (finding.severity === 'WARN' || finding.severity === 'FAIL') {
      warnings.push(`[${finding.severity}] ${finding.message}`);
    }
  }
  return { ok: errors.length === 0, errors, warnings };
}

function toKb(bytes: number): string {
  return `${(bytes / 1024).toFixed(1)} KB`;
}

/** Formats a Markdown telemetry summary for stdout and GITHUB_STEP_SUMMARY. */
export function formatTelemetryMarkdown(input: {
  bundle: BundleReport;
  bundleVerdict: Verdict;
  profile?: MobileProfileReport;
  profileVerdict?: Verdict;
}): string {
  const { bundle, bundleVerdict, profile, profileVerdict } = input;
  const lines: string[] = [
    '## Mobile Web Wasm Telemetry',
    '',
    `- **Bundle audit:** \`${bundle.status}\` (startup br: ${toKb(bundle.initialStartupTotals.brotliBytes)}, app core br: ${toKb(bundle.appCoreTotals.brotliBytes)}, runtime br: ${toKb(bundle.bundledRuntimeTotals.brotliBytes)})`,
  ];
  for (const warn of bundleVerdict.warnings) lines.push(`  - Note: ${warn}`);
  for (const err of bundleVerdict.errors) lines.push(`  - Error: ${err}`);

  if (profile && profileVerdict) {
    const s = profile.snapshot;
    lines.push(
      `- **Mobile Blink (${profile.device.name}, ${profile.cpuRate}x CPU, ${profile.networkPreset}):** renderer \`${s.renderer}\` | transfer ${toKb(profile.totalTransferBytes)} | p95 frame ${s.rafStats.p95Ms} ms (${s.rafStats.avgFps} FPS, >50ms jank: ${s.rafStats.severeOver50Ms}) | console errors: ${profile.consoleErrors.length}, failed requests: ${profile.failedRequests.length}`
    );
    for (const warn of profileVerdict.warnings)
      lines.push(`  - Metric: ${warn}`);
    for (const err of profileVerdict.errors) lines.push(`  - Error: ${err}`);
  }
  return `${lines.join('\n')}\n`;
}

function runBundleAudit(): BundleReport {
  const bundleDir = path.join(docsDir, 'public/flutter');
  if (!existsSync(path.join(bundleDir, 'flutter_bootstrap.js'))) {
    throw new Error(
      'public/flutter/flutter_bootstrap.js not found; run "bun run flutter:build" first.'
    );
  }
  const scriptPath = path.join(skillScriptsDir, 'analyze_web_bundle.mjs');
  const res = spawnSync(
    process.execPath,
    [scriptPath, bundleDir, '--fail-on', 'fail', '--json'],
    { cwd: docsDir, encoding: 'utf-8' }
  );
  if (res.error) throw res.error;
  if (res.status !== 0 && !res.stdout.trim()) {
    throw new Error(`analyze_web_bundle.mjs failed: ${res.stderr}`);
  }
  const parsed: unknown = JSON.parse(res.stdout);
  return BundleReportSchema.parse(parsed);
}

async function allocatePort(): Promise<number> {
  return new Promise((resolve, reject) => {
    const server = net.createServer();
    server.unref();
    server.on('error', reject);
    server.listen(0, '127.0.0.1', () => {
      const address = server.address();
      if (!address || typeof address === 'string') {
        server.close();
        reject(new Error('Failed to allocate TCP port.'));
        return;
      }
      const { port } = address;
      server.close((err) => {
        if (err) reject(err);
        else resolve(port);
      });
    });
  });
}

async function waitForServer(
  url: string,
  childExit: Promise<string>,
  timeoutMs = 30_000
): Promise<void> {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    const outcome = await Promise.race([
      childExit.then((reason) => ({ exited: true as const, reason })),
      fetch(url)
        .then((res) => ({ exited: false as const, ok: res.ok }))
        .catch(() => ({ exited: false as const, ok: false })),
    ]);
    if (outcome.exited) {
      throw new Error(`Docs server exited before ready: ${outcome.reason}`);
    }
    if (outcome.ok) return;
    await new Promise((resolve) => setTimeout(resolve, 300));
  }
  throw new Error(`Timed out waiting for docs server at ${url}`);
}

function hasSystemChrome(): boolean {
  const candidates = [
    '/usr/bin/google-chrome',
    '/usr/bin/chromium',
    '/usr/bin/chromium-browser',
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  ];
  if (candidates.some((p) => existsSync(p))) return true;
  const check = spawnSync('which', ['google-chrome', 'chromium'], {
    stdio: 'ignore',
  });
  return check.status === 0;
}

async function resolveChromePath(): Promise<string | null> {
  if (process.env.CHROME_PATH) return process.env.CHROME_PATH;
  if (hasSystemChrome()) return null;
  try {
    const pw = await import('@playwright/test');
    const candidate = pw.chromium.executablePath();
    if (candidate && existsSync(candidate)) return candidate;
  } catch {
    // Fall back to profile_mobile_web.mjs default Chrome discovery.
  }
  return null;
}

async function runMobileProfiler(
  targetUrl: string
): Promise<MobileProfileReport> {
  const scriptPath = path.join(skillScriptsDir, 'profile_mobile_web.mjs');
  const args = [
    scriptPath,
    '--url',
    targetUrl,
    '--device',
    'mid-android',
    '--cpu',
    '4',
    '--network',
    '4g',
    '--scroll-sweeps',
    '3',
    '--wait-ms',
    '8000',
    '--fail-on',
    'none',
    '--json',
  ];
  const chromePath = await resolveChromePath();
  if (chromePath) args.push('--chrome-path', chromePath);
  const res = spawnSync(process.execPath, args, {
    cwd: docsDir,
    encoding: 'utf-8',
  });
  if (res.error) throw res.error;
  if (res.status !== 0 && !res.stdout.trim()) {
    throw new Error(`profile_mobile_web.mjs failed: ${res.stderr}`);
  }
  const parsed: unknown = JSON.parse(res.stdout);
  return MobileProfileReportSchema.parse(parsed);
}

async function withDocsServer<T>(
  baseUrl: string | null,
  route: string,
  task: (targetUrl: string) => Promise<T>
): Promise<T> {
  if (baseUrl) {
    const cleanBase = baseUrl.replace(/\/+$/, '');
    return task(`${cleanBase}${route}`);
  }
  const port = await allocatePort();
  const targetUrl = `http://127.0.0.1:${port}${route}`;
  const child = spawn(
    'bun',
    ['run', 'start', '--', '-H', '127.0.0.1', '-p', String(port)],
    { cwd: docsDir, detached: true, stdio: ['ignore', 'ignore', 'pipe'] }
  );
  let stderrTail = '';
  child.stderr?.on('data', (chunk: Buffer) => {
    stderrTail = (stderrTail + chunk.toString('utf-8')).slice(-1000);
  });
  const childExit = new Promise<string>((resolve) => {
    child.once('error', (err) => resolve(err.message));
    child.once('exit', (code) =>
      resolve(`exit code ${code ?? 'null'} (${stderrTail.trim()})`)
    );
  });
  try {
    await waitForServer(targetUrl, childExit);
    return await task(targetUrl);
  } finally {
    if (child.pid) {
      try {
        process.kill(-child.pid, 'SIGTERM');
      } catch {
        child.kill('SIGTERM');
      }
    }
  }
}

async function main(): Promise<void> {
  const opts = parseCliArgs(process.argv.slice(2));
  mkdirSync(opts.outDir, { recursive: true });

  const bundle = runBundleAudit();
  const bundleVerdict = evaluateBundleReport(bundle);
  writeFileSync(
    path.join(opts.outDir, 'bundle-report.json'),
    JSON.stringify(bundle, null, 2)
  );

  let profile: MobileProfileReport | undefined;
  let profileVerdict: Verdict | undefined;
  if (!opts.bundleOnly) {
    profile = await withDocsServer(opts.baseUrl, opts.route, runMobileProfiler);
    profileVerdict = evaluateMobileProfileReport(profile);
    writeFileSync(
      path.join(opts.outDir, 'mobile-profile.json'),
      JSON.stringify(profile, null, 2)
    );
  }

  const summary = formatTelemetryMarkdown({
    bundle,
    bundleVerdict,
    profile,
    profileVerdict,
  });
  console.log(summary);
  if (process.env.GITHUB_STEP_SUMMARY) {
    appendFileSync(process.env.GITHUB_STEP_SUMMARY, summary);
  }

  const ok = bundleVerdict.ok && (profileVerdict ? profileVerdict.ok : true);
  if (!ok) process.exit(1);
}

if (import.meta.main) {
  void main().catch((err: unknown) => {
    console.error(err instanceof Error ? err.message : String(err));
    process.exit(1);
  });
}
