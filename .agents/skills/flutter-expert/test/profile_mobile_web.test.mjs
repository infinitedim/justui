import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';
import vm from 'node:vm';

const TEST_DIR = path.dirname(fileURLToPath(import.meta.url));
const SCRIPT_PATH = path.resolve(TEST_DIR, '../scripts/profile_mobile_web.mjs');

function makeTempDir(files) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'fe-profile-test-'));
  for (const [rel, content] of Object.entries(files)) {
    const full = path.join(dir, rel);
    fs.mkdirSync(path.dirname(full), { recursive: true });
    fs.writeFileSync(full, content);
  }
  return dir;
}

test('static server handles malformed URI (400), traversal (403), missing asset (404), and useLocalCanvasKit:false patch', async (t) => {
  const mod = await import(SCRIPT_PATH);
  const dir = makeTempDir({
    'index.html': '<html><body>ok</body></html>',
    'flutter_bootstrap.js':
      '_flutter.buildConfig = {"engineRevision":"123","useLocalCanvasKit":false};',
    'canvaskit/skwasm.wasm': Buffer.from([0, 97, 115, 109]),
  });
  const handle = await mod.startStaticServer(dir, false, 'require-corp', true, false);
  t.after(() => {
    handle.server.closeAllConnections?.();
    handle.server.close();
    fs.rmSync(dir, { recursive: true, force: true });
  });

  const malformed = await fetch(`${handle.url}%E0%A4%A`);
  assert.equal(malformed.status, 400);

  const missingWasm = await fetch(`${handle.url}assets/missing.wasm`);
  assert.equal(missingWasm.status, 404);

  const missingGif = await fetch(`${handle.url}assets/missing.gif`);
  assert.equal(missingGif.status, 404);

  const missingManifest = await fetch(`${handle.url}manifest.webmanifest`);
  assert.equal(missingManifest.status, 404);

  const spaRoute = await fetch(`${handle.url}settings/profile`);
  assert.equal(spaRoute.status, 200);
  assert.match(await spaRoute.text(), /<body>ok<\/body>/);

  const bootstrapRes = await fetch(`${handle.url}flutter_bootstrap.js`);
  assert.equal(bootstrapRes.status, 200);
  const bootstrapJs = await bootstrapRes.text();
  const sandbox = { _flutter: {} };
  vm.runInNewContext(bootstrapJs, sandbox);
  assert.equal(sandbox._flutter.buildConfig.useLocalCanvasKit, true);
});

test('injected probe avoids URL false positives and distinguishes canvaskit-wasm vs canvaskit-js', async () => {
  const mod = await import(SCRIPT_PATH);
  const runProbe = (resourceUrls) => {
    let bufferLimit = 0;
    const windowObj = {
      innerWidth: 390,
      innerHeight: 844,
      devicePixelRatio: 3,
      crossOriginIsolated: false,
      scrollY: 0,
    };
    const sandbox = {
      window: windowObj,
      navigator: { vendor: 'Google Inc.' },
      document: {
        documentElement: { scrollWidth: 390 },
        querySelector: () => null,
        querySelectorAll: () => [],
      },
      performance: {
        now: () => 10,
        setResourceTimingBufferSize: (n) => {
          bufferLimit = n;
        },
        getEntriesByType: (kind) =>
          kind === 'resource' ? resourceUrls.map((name) => ({ name })) : [],
      },
      requestAnimationFrame: () => 1,
      PerformanceObserver: class {
        observe() {}
      },
      MutationObserver: class {
        observe() {}
        disconnect() {}
      },
    };
    vm.runInNewContext(mod.buildInjectedProbeScript(false), sandbox);
    return {
      snapshot: windowObj.__mobilePerfProbe.snapshot(),
      bufferLimit,
    };
  };

  const jsRun = runProbe([
    'https://example.test/my-wimp-demo/canvaskit/canvaskit.wasm',
    'https://example.test/my-wimp-demo/main.dart.js',
  ]);
  assert.equal(jsRun.snapshot.renderer, 'canvaskit-js');
  assert.ok(jsRun.bufferLimit >= 1000);

  const wasmCanvasRun = runProbe([
    'https://example.test/app/canvaskit/canvaskit.wasm',
    'https://example.test/app/main.dart.wasm',
  ]);
  assert.equal(wasmCanvasRun.snapshot.renderer, 'canvaskit-wasm');
  assert.ok(Array.isArray(wasmCanvasRun.snapshot.bootLongTasks));
});

test('evaluateReport emits both interactive and boot long-task warnings independently', async () => {
  const mod = await import(SCRIPT_PATH);
  const result = mod.evaluateReport(
    {
      consoleErrors: [],
      failedRequests: [],
      totalTransferBytes: 500 * 1024,
      transferBreakdown: { runtimeBytes: 0, fallbackFontRequests: 0 },
      snapshot: {
        flutterDetectedAtMs: 500,
        firstSceneAtMs: 600,
        flutterFirstFrameMs: 600,
        renderer: 'skwasm-wasm',
        viewport: { width: 390, height: 844 },
        horizontalOverflowPx: 0,
        domScrollDeltaPx: 0,
        longTasks: [
          { startMs: 100, durationMs: 750 },
          { startMs: 3000, durationMs: 260 },
        ],
        interactiveLongTasks: [{ startMs: 3000, durationMs: 260 }],
        rafStats: { p95Ms: 16.0, severeOver50Ms: 0 },
        flutterEngineTimings: null,
      },
    },
    null,
    {
      cpu: 4,
      network: '4g',
      scrollSweeps: 0,
      simulateWebkitFallback: false,
      device: 'mid-android',
      expectedViewportWidth: 390,
    }
  );

  assert.ok(result.findings.some((f) => /Interactive Long Task/i.test(f.message)));
  assert.ok(result.findings.some((f) => /Cold-boot Long Task/i.test(f.message)));

  const interactiveOnly = mod.evaluateReport(
    {
      consoleErrors: [],
      failedRequests: [],
      totalTransferBytes: 500 * 1024,
      transferBreakdown: { runtimeBytes: 0, fallbackFontRequests: 0 },
      snapshot: {
        flutterDetectedAtMs: 500,
        firstSceneAtMs: 600,
        flutterFirstFrameMs: 600,
        renderer: 'skwasm-wasm',
        viewport: { width: 390, height: 844 },
        horizontalOverflowPx: 0,
        domScrollDeltaPx: 0,
        longTasks: [
          { startMs: 100, durationMs: 250 },
          { startMs: 3000, durationMs: 720 },
        ],
        bootLongTasks: [{ startMs: 100, durationMs: 250 }],
        interactiveLongTasks: [{ startMs: 3000, durationMs: 720 }],
        rafStats: { p95Ms: 16.0, severeOver50Ms: 0 },
        flutterEngineTimings: null,
      },
    },
    null,
    {
      cpu: 4,
      network: '4g',
      scrollSweeps: 0,
      simulateWebkitFallback: false,
      device: 'mid-android',
      expectedViewportWidth: 390,
    }
  );
  assert.ok(interactiveOnly.findings.some((f) => /Interactive Long Task/i.test(f.message)));
  assert.equal(
    interactiveOnly.findings.some((f) => /Cold-boot Long Task/i.test(f.message)),
    false
  );
});

test('CdpClient rejects pending send() promises on close and error', async () => {
  const mod = await import(SCRIPT_PATH);
  const listeners = new Map();
  class FakeWebSocket {
    addEventListener(type, fn) {
      if (!listeners.has(type)) listeners.set(type, []);
      listeners.get(type).push(fn);
    }
    send() {}
    close() {}
  }
  const origWs = globalThis.WebSocket;
  globalThis.WebSocket = FakeWebSocket;
  try {
    const client = new mod.CdpClient('ws://127.0.0.1:1/test');
    const connectPromise = client.connect();
    for (const fn of listeners.get('open') || []) fn();
    await connectPromise;

    const pending = client.send('Runtime.evaluate', { expression: '1' });
    for (const fn of listeners.get('close') || []) fn({ code: 1006, reason: 'lost' });
    await assert.rejects(pending, /closed|disconnected|error/i);
  } finally {
    globalThis.WebSocket = origWs;
  }
});

test('supports --fail-on parsing and exit code resolution', async () => {
  const mod = await import(SCRIPT_PATH);
  const parsedDefault = mod.parseArgs(['--url', 'http://127.0.0.1:8080']);
  assert.equal(parsedDefault.failOn, 'none');

  const parsedWarn = mod.parseArgs(['--url', 'http://127.0.0.1:8080', '--fail-on', 'warn']);
  assert.equal(parsedWarn.failOn, 'warn');

  assert.throws(() => mod.parseArgs(['--url', 'http://127.0.0.1:8080', '--fail-on', 'bogus']));
  assert.equal(mod.resolveExitCode('FAIL', 'none'), 0);
  assert.equal(mod.resolveExitCode('FAIL', 'fail'), 1);
  assert.equal(mod.resolveExitCode('WARN', 'fail'), 0);
  assert.equal(mod.resolveExitCode('WARN', 'warn'), 1);
});

test('static server mounts <base href="/subpath/"> builds and keeps 403 traversal + 404 asset guards', async (t) => {
  const mod = await import(SCRIPT_PATH);
  const dir = makeTempDir({
    'index.html': '<!doctype html><html><head><base href="/flutter/"></head><body>sub</body></html>',
    'flutter_bootstrap.js': '_flutter.buildConfig = {"useLocalCanvasKit":true};',
    'canvaskit/skwasm.wasm': Buffer.from([0, 97, 115, 109]),
  });
  const handle = await mod.startStaticServer(dir, false, 'require-corp', true, false);
  t.after(() => {
    handle.server.closeAllConnections?.();
    handle.server.close();
    fs.rmSync(dir, { recursive: true, force: true });
  });

  assert.match(handle.url, /\/flutter\/$/);
  const rootPage = await fetch(handle.url);
  assert.equal(rootPage.status, 200);
  assert.match(await rootPage.text(), /<body>sub<\/body>/);

  const assetRes = await fetch(`${handle.url}flutter_bootstrap.js`);
  assert.equal(assetRes.status, 200);

  const missingAsset = await fetch(`${handle.url}missing.wasm`);
  assert.equal(missingAsset.status, 404);

  const traversal = await fetch(`${handle.url}..%2f..%2fetc/passwd`);
  assert.equal(traversal.status, 403);
});

test('CLI help mentions --fail-on and exits 0', () => {
  const res = spawnSync(process.execPath, [SCRIPT_PATH, '--help'], { encoding: 'utf8' });
  assert.equal(res.status, 0);
  assert.match(res.stdout, /--fail-on/);
});
