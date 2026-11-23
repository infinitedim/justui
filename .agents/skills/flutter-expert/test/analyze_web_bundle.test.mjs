import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

const TEST_DIR = path.dirname(fileURLToPath(import.meta.url));
const SCRIPT_PATH = path.resolve(TEST_DIR, '../scripts/analyze_web_bundle.mjs');
const REPO_ROOT = path.resolve(TEST_DIR, '../..');

function makeTempBuild(files) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'fe-bundle-test-'));
  for (const [rel, content] of Object.entries(files)) {
    const full = path.join(dir, rel);
    fs.mkdirSync(path.dirname(full), { recursive: true });
    fs.writeFileSync(full, content);
  }
  return dir;
}

function runCli(args) {
  return spawnSync(process.execPath, [SCRIPT_PATH, ...args], {
    encoding: 'utf8',
  });
}

test('detects local runtime from flutter_bootstrap.js even without index.html', async (t) => {
  const mod = await import(SCRIPT_PATH);
  const dir = makeTempBuild({
    'flutter_bootstrap.js':
      '_flutter.buildConfig = {"engineRevision":"abc","builds":[{"compileTarget":"dart2wasm","renderer":"skwasm"}],"useLocalCanvasKit":true};',
    'main.dart.2c5cde3a.mjs': 'export default {};',
    'main.dart.ce737cbb.wasm': Buffer.alloc(1024),
    'canvaskit/skwasm.wasm': Buffer.alloc(2048),
  });
  t.after(() => fs.rmSync(dir, { recursive: true, force: true }));

  const report = mod.evaluateBundle(dir, { maxInitialKb: 1500, maxAssetKb: 250 });
  assert.equal(report.usesLocalRuntime, true);
  assert.equal(report.htmlAudit.exists, false);
  assert.equal(report.hasContentHash, true);
});

test('parses _flutter.buildConfig without trailing semicolon and nested objects', async (t) => {
  const mod = await import(SCRIPT_PATH);
  const dir = makeTempBuild({
    'index.html': '<!doctype html><html><head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head><body></body></html>',
    'flutter_bootstrap.js':
      '_flutter.buildConfig = {"nested":{"a":1},"useLocalCanvasKit":true}\n_flutter.loader.load({});',
    'main.dart.wasm': Buffer.alloc(512),
    'canvaskit/skwasm.wasm': Buffer.alloc(512),
  });
  t.after(() => fs.rmSync(dir, { recursive: true, force: true }));

  const report = mod.evaluateBundle(dir, { maxInitialKb: 1500, maxAssetKb: 250 });
  assert.equal(report.usesLocalRuntime, true);
});

test('counts startup fonts and manifests (including AssetManifest.bin.<hash>.json) and does not mask startup FAIL behind core WARN', async (t) => {
  const mod = await import(SCRIPT_PATH);
  const bigFontA = crypto.randomBytes(180 * 1024);
  const bigFontB = crypto.randomBytes(180 * 1024);
  const coreBlob = crypto.randomBytes(140 * 1024);
  const dir = makeTempBuild({
    'index.html':
      '<!doctype html><html><head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head><body></body></html>',
    'flutter_bootstrap.js': '_flutter.buildConfig = {"useLocalCanvasKit":false,"canvasKitBaseUrl":null};',
    'main.dart.wasm': coreBlob,
    'assets/AssetManifest.bin.4a953295.json': Buffer.from('{"a":1}'),
    'assets/FontManifest.json': '[]',
    'assets/fonts/FontA.ttf': bigFontA,
    'assets/fonts/FontB.ttf': bigFontB,
  });
  t.after(() => fs.rmSync(dir, { recursive: true, force: true }));

  // Core ~140 KB (> 120 KB WARN, <= 240 KB FAIL); core+fonts+manifest ~500 KB (> 240 KB FAIL)
  const report = mod.evaluateBundle(dir, { maxInitialKb: 120, maxAssetKb: 250 });
  assert.equal(report.usesLocalRuntime, false);
  assert.ok(report.startupManifestsTotals.rawBytes > 0);
  assert.ok(report.startupFontsTotals.brotliBytes > 250 * 1024);
  assert.ok(report.initialStartupTotals.brotliBytes > report.appCoreTotals.brotliBytes);
  assert.equal(report.status, 'FAIL');
  assert.ok(
    report.findings.some((f) => f.severity === 'FAIL' && /startup payload/i.test(f.message))
  );
});

test('does not treat remote https:// canvasKitBaseUrl as self-hosted local runtime', async (t) => {
  const mod = await import(SCRIPT_PATH);
  const dir = makeTempBuild({
    'index.html':
      '<!doctype html><html><head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head><body></body></html>',
    'flutter_bootstrap.js':
      '_flutter.loader.load({config:{canvasKitBaseUrl:"https://cdn.example.com/canvaskit/"}});',
    'main.dart.wasm': Buffer.alloc(512),
  });
  t.after(() => fs.rmSync(dir, { recursive: true, force: true }));

  const report = mod.evaluateBundle(dir, { maxInitialKb: 1500, maxAssetKb: 250 });
  assert.equal(report.usesLocalRuntime, false);
});

test('detects main.dart.<hash>.mjs as content-hashed build', async (t) => {
  const mod = await import(SCRIPT_PATH);
  const dir = makeTempBuild({
    'index.html':
      '<!doctype html><html><head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head><body></body></html>',
    'flutter_bootstrap.js': '_flutter.buildConfig = {};',
    'main.dart.2c5cde3a.mjs': 'console.log(1);',
  });
  t.after(() => fs.rmSync(dir, { recursive: true, force: true }));

  const report = mod.evaluateBundle(dir, { maxInitialKb: 1500, maxAssetKb: 250 });
  assert.equal(report.hasContentHash, true);
});

test('supports --fail-on none|fail|warn CLI exit codes', (t) => {
  const warnDir = makeTempBuild({
    'index.html': '<!doctype html><html><head></head><body></body></html>',
    'flutter_bootstrap.js': '_flutter.buildConfig = {};',
    'main.dart.wasm': Buffer.alloc(1024),
  });
  t.after(() => fs.rmSync(warnDir, { recursive: true, force: true }));

  const defaultRun = runCli([warnDir, '--json']);
  assert.equal(defaultRun.status, 0);

  const failOnFail = runCli([warnDir, '--fail-on', 'fail', '--json']);
  assert.equal(failOnFail.status, 0);

  const failOnWarn = runCli([warnDir, '--fail-on', 'warn', '--json']);
  assert.equal(failOnWarn.status, 1);
});

test('reports self-hosted runtime on repo apps/docs/public/flutter when present', () => {
  const docsFlutterDir = path.join(REPO_ROOT, 'apps', 'docs', 'public', 'flutter');
  if (!fs.existsSync(docsFlutterDir)) return;
  const res = runCli([docsFlutterDir, '--json']);
  assert.equal(res.status, 0);
  const report = JSON.parse(res.stdout);
  assert.equal(report.usesLocalRuntime, true);
});
