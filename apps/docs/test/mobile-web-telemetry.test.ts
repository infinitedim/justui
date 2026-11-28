import { describe, expect, it } from 'vitest';
import {
  BundleReportSchema,
  MobileProfileReportSchema,
  evaluateBundleReport,
  evaluateMobileProfileReport,
  formatTelemetryMarkdown,
  parseCliArgs,
  type BundleReport,
  type MobileProfileReport,
} from '../scripts/mobile-web-telemetry';

function makeBundleReport(overrides: Partial<BundleReport> = {}): BundleReport {
  return {
    dir: '/tmp/public/flutter',
    status: 'WARN',
    wasmReady: true,
    hasContentHash: true,
    usesLocalRuntime: true,
    appCoreTotals: {
      rawBytes: 2048000,
      gzipBytes: 760000,
      brotliBytes: 690000,
    },
    initialStartupTotals: {
      rawBytes: 2900000,
      gzipBytes: 1150000,
      brotliBytes: 1040000,
    },
    bundledRuntimeTotals: {
      rawBytes: 8900000,
      gzipBytes: 3900000,
      brotliBytes: 3550000,
    },
    findings: [
      {
        severity: 'WARN',
        message: 'index.html: Missing index.html in build output.',
      },
    ],
    ...overrides,
  };
}

function makeMobileReport(
  overrides: Partial<MobileProfileReport> = {}
): MobileProfileReport {
  return {
    targetUrl: 'http://127.0.0.1:3000/en/docs/components',
    device: { name: 'mid-android', width: 390, height: 844, dpr: 3 },
    cpuRate: 4,
    networkPreset: '4g',
    requestCount: 18,
    failedRequests: [],
    consoleErrors: [],
    totalTransferBytes: 1200000,
    transferBreakdown: {
      appBytes: 700000,
      runtimeBytes: 350000,
      fontBytes: 120000,
      imageBytes: 0,
      otherBytes: 30000,
      fallbackFontRequests: 0,
    },
    snapshot: {
      renderer: 'skwasm-wasm',
      crossOriginIsolated: true,
      horizontalOverflowPx: 0,
      flutterDetectedAtMs: 850.5,
      firstSceneAtMs: 1120.0,
      flutterFirstFrameMs: null,
      rafStats: {
        frameCount: 120,
        avgFps: 56.2,
        p50Ms: 16.7,
        p95Ms: 28.4,
        p99Ms: 36.0,
        maxMs: 42.1,
        droppedOver20Ms: 6,
        jankOver33Ms: 2,
        severeOver50Ms: 0,
      },
      longTasks: [{ durationMs: 180 }],
    },
    evaluation: {
      status: 'WARN',
      findings: [
        {
          severity: 'WARN',
          message:
            'p95 frame time is 28.4 ms (> 24 ms target under mobile CPU throttling).',
        },
      ],
    },
    ...overrides,
  };
}

describe('mobile-web-telemetry schemas and CLI flags', () => {
  it('parses CLI flags cleanly and rejects unknown flags', () => {
    const parsed = parseCliArgs([
      '--bundle-only',
      '--url',
      'http://127.0.0.1:4100',
      '--route',
      'id/docs/components',
    ]);
    expect(parsed.bundleOnly).toBe(true);
    expect(parsed.baseUrl).toBe('http://127.0.0.1:4100');
    expect(parsed.route).toBe('/id/docs/components');
    expect(() => parseCliArgs(['--unknown'])).toThrow(/Unknown or incomplete/);
  });

  it('validates bundle and profile reports with zod', () => {
    expect(() => BundleReportSchema.parse(makeBundleReport())).not.toThrow();
    expect(() =>
      MobileProfileReportSchema.parse(makeMobileReport())
    ).not.toThrow();
    expect(() => BundleReportSchema.parse({ status: 'PASS' })).toThrow();
  });
});

describe('mobile-web-telemetry verdicts and formatting', () => {
  it('allows expected pruned index.html WARN in bundle audit and rejects FAIL', () => {
    const warnVerdict = evaluateBundleReport(makeBundleReport());
    expect(warnVerdict.ok).toBe(true);
    expect(warnVerdict.warnings).toHaveLength(1);

    const failVerdict = evaluateBundleReport(
      makeBundleReport({
        status: 'FAIL',
        wasmReady: false,
        findings: [{ severity: 'FAIL', message: 'Missing wasm output.' }],
      })
    );
    expect(failVerdict.ok).toBe(false);
    expect(failVerdict.errors.length).toBeGreaterThanOrEqual(2);
  });

  it('keeps CPU frame timing non-blocking while failing on boot, renderer, or console errors', () => {
    const slowPass = evaluateMobileProfileReport(makeMobileReport());
    expect(slowPass.ok).toBe(true);
    expect(slowPass.warnings).toHaveLength(1);

    const badBoot = evaluateMobileProfileReport(
      makeMobileReport({
        consoleErrors: ['Uncaught RuntimeError'],
        failedRequests: [
          { url: '/flutter/main.dart.wasm', reason: 'net::ERR_FAILED' },
        ],
        snapshot: {
          ...makeMobileReport().snapshot,
          renderer: 'canvaskit-js',
          flutterDetectedAtMs: null,
        },
      })
    );
    expect(badBoot.ok).toBe(false);
    expect(badBoot.errors).toHaveLength(4);
  });

  it('formats concise Markdown telemetry summary', () => {
    const bundle = makeBundleReport();
    const profile = makeMobileReport();
    const md = formatTelemetryMarkdown({
      bundle,
      bundleVerdict: evaluateBundleReport(bundle),
      profile,
      profileVerdict: evaluateMobileProfileReport(profile),
    });
    expect(md).toContain('## Mobile Web Wasm Telemetry');
    expect(md).toContain('skwasm-wasm');
    expect(md).toContain('p95 frame 28.4 ms');
  });
});
