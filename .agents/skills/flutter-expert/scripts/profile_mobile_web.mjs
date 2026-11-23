#!/usr/bin/env node
/**
 * Profiles a running (or locally built) Flutter Web application under realistic
 * mobile browser emulation (viewport, touch, DPR, CPU throttling, network shaping)
 * via Chrome DevTools Protocol (CDP), using zero external npm dependencies.
 *
 * Usage:
 *   node profile_mobile_web.mjs --serve ./build/web [options]
 *   node profile_mobile_web.mjs --url http://127.0.0.1:8080 [options]
 */

import fs from 'node:fs';
import http from 'node:http';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import zlib from 'node:zlib';
import { execFileSync, spawn } from 'node:child_process';

const DEVICE_PRESETS = {
  'mid-android': {
    width: 390,
    height: 844,
    dpr: 3,
    userAgent:
      'Mozilla/5.0 (Linux; Android 14; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Mobile Safari/537.36',
  },
  'compact-android': {
    width: 360,
    height: 800,
    dpr: 2,
    userAgent:
      'Mozilla/5.0 (Linux; Android 13; SM-A536B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Mobile Safari/537.36',
  },
  'ios-safari': {
    width: 390,
    height: 844,
    dpr: 3,
    userAgent:
      'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1',
  },
};

const NETWORK_PRESETS = {
  none: null,
  '4g': {
    offline: false,
    latency: 60,
    downloadThroughput: Math.round((9 * 1024 * 1024) / 8),
    uploadThroughput: Math.round((1.5 * 1024 * 1024) / 8),
  },
  'slow-4g': {
    offline: false,
    latency: 150,
    downloadThroughput: Math.round((1.6 * 1024 * 1024) / 8),
    uploadThroughput: Math.round((750 * 1024) / 8),
  },
};

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.wasm': 'application/wasm',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.webp': 'image/webp',
  '.avif': 'image/avif',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.webmanifest': 'application/manifest+json; charset=utf-8',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.frag': 'text/plain; charset=utf-8',
  '.map': 'application/json; charset=utf-8',
  '.bin': 'application/octet-stream',
};

const STATIC_ASSET_EXTS = new Set(Object.keys(MIME_TYPES).filter((ext) => ext !== '.html'));
const COMPRESSIBLE_EXTS = new Set(['.html', '.js', '.mjs', '.wasm', '.css', '.json', '.svg', '.frag', '.map']);
const FAIL_ON_MODES = new Set(['none', 'fail', 'warn']);

function readFlagValue(argv, index, flagName) {
  const val = argv[index + 1];
  if (val === undefined || val.startsWith('--')) {
    throw new Error(`${flagName} requires a value.`);
  }
  return val;
}

function readNumberFlag(argv, index, flagName, { min = -Infinity, exclusiveMin = false, integer = false } = {}) {
  const raw = readFlagValue(argv, index, flagName);
  const val = Number(raw);
  const belowMin = exclusiveMin ? val <= min : val < min;
  if (!Number.isFinite(val) || belowMin || (integer && !Number.isInteger(val))) {
    const bound = `${exclusiveMin ? '>' : '>='} ${min}`;
    throw new Error(`${flagName} must be a finite ${integer ? 'integer' : 'number'} ${bound}. Received "${raw}".`);
  }
  return val;
}

function printUsage() {
  console.log(
    'Usage: node profile_mobile_web.mjs (--serve <dir> | --url <url>) [--device mid-android] [--viewport WxH@DPR] [--cpu 4] [--network 4g] [--scroll-sweeps 3] [--wait-ms 2500] [--load-timeout-ms 30000] [--coop-coep] [--coep-mode require-corp|credentialless] [--simulate-webkit-fallback] [--uncompressed] [--cdn-runtime] [--screenshot out.png] [--chrome-path <path>] [--headful] [--fail-on none|fail|warn] [--json]'
  );
}

export function parseArgs(argv) {
  const opts = {
    url: null,
    serveDir: null,
    device: 'mid-android',
    viewport: null,
    cpu: 4,
    network: '4g',
    scrollSweeps: 3,
    waitMs: 2500,
    loadTimeoutMs: 30000,
    coopCoep: false,
    coepMode: 'require-corp',
    simulateWebkitFallback: false,
    uncompressed: false,
    cdnRuntime: false,
    screenshot: null,
    chromePath: process.env.CHROME_PATH || null,
    headful: false,
    failOn: 'none',
    json: false,
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === '--url') opts.url = readFlagValue(argv, i++, '--url');
    else if (arg === '--serve') opts.serveDir = path.resolve(process.cwd(), readFlagValue(argv, i++, '--serve'));
    else if (arg === '--device') opts.device = readFlagValue(argv, i++, '--device');
    else if (arg === '--viewport') opts.viewport = readFlagValue(argv, i++, '--viewport');
    else if (arg === '--cpu') opts.cpu = readNumberFlag(argv, i++, '--cpu', { min: 1 });
    else if (arg === '--network') opts.network = readFlagValue(argv, i++, '--network');
    else if (arg === '--scroll-sweeps') opts.scrollSweeps = readNumberFlag(argv, i++, '--scroll-sweeps', { min: 0, integer: true });
    else if (arg === '--wait-ms') opts.waitMs = readNumberFlag(argv, i++, '--wait-ms', { min: 0, integer: true });
    else if (arg === '--load-timeout-ms') opts.loadTimeoutMs = readNumberFlag(argv, i++, '--load-timeout-ms', { min: 0, exclusiveMin: true, integer: true });
    else if (arg === '--coop-coep') opts.coopCoep = true;
    else if (arg === '--coep-mode') opts.coepMode = readFlagValue(argv, i++, '--coep-mode');
    else if (arg === '--simulate-webkit-fallback') opts.simulateWebkitFallback = true;
    else if (arg === '--uncompressed') opts.uncompressed = true;
    else if (arg === '--cdn-runtime') opts.cdnRuntime = true;
    else if (arg === '--screenshot') opts.screenshot = path.resolve(process.cwd(), readFlagValue(argv, i++, '--screenshot'));
    else if (arg === '--chrome-path') opts.chromePath = readFlagValue(argv, i++, '--chrome-path');
    else if (arg === '--headful') opts.headful = true;
    else if (arg === '--fail-on') opts.failOn = readFlagValue(argv, i++, '--fail-on');
    else if (arg === '--json') opts.json = true;
    else if (arg === '--help' || arg === '-h') {
      printUsage();
      process.exit(0);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }

  validateArgs(opts);
  return opts;
}

function validateArgs(opts) {
  if (!opts.url && !opts.serveDir) {
    throw new Error('Provide either --serve <buildWebDir> or --url <http://...>.');
  }
  if (!DEVICE_PRESETS[opts.device]) {
    throw new Error(`Unknown --device "${opts.device}". Choose: ${Object.keys(DEVICE_PRESETS).join(', ')}`);
  }
  if (!(opts.network in NETWORK_PRESETS)) {
    throw new Error(`Unknown --network "${opts.network}". Choose: ${Object.keys(NETWORK_PRESETS).join(', ')}`);
  }
  if (!['require-corp', 'credentialless'].includes(opts.coepMode)) {
    throw new Error(`Unknown --coep-mode "${opts.coepMode}". Choose: require-corp, credentialless`);
  }
  if (!FAIL_ON_MODES.has(opts.failOn)) {
    throw new Error(`Unknown --fail-on "${opts.failOn}". Choose: ${[...FAIL_ON_MODES].join(', ')}`);
  }
}

export function resolveExitCode(status, failOn = 'none') {
  if (failOn === 'fail') return status === 'FAIL' ? 1 : 0;
  if (failOn === 'warn') return status === 'FAIL' || status === 'WARN' ? 1 : 0;
  return 0;
}

function resolveDeviceConfig(opts) {
  const base = { ...DEVICE_PRESETS[opts.device] };
  if (opts.viewport) {
    const match = opts.viewport.match(/^(\d+)x(\d+)(?:@([\d.]+))?$/i);
    if (!match) throw new Error(`Invalid --viewport "${opts.viewport}". Expected WxH[@DPR].`);
    base.width = Number(match[1]);
    base.height = Number(match[2]);
    if (match[3]) base.dpr = Number(match[3]);
  }
  return base;
}

function findChromeBinary(explicitPath) {
  if (explicitPath) {
    if (!fs.existsSync(explicitPath)) throw new Error(`Chrome binary not found: ${explicitPath}`);
    return explicitPath;
  }

  const localAppData = process.env.LOCALAPPDATA || '';
  const candidates = process.platform === 'win32'
    ? [
        'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
        'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe',
        path.join(localAppData, 'Google', 'Chrome', 'Application', 'chrome.exe'),
        'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe',
        'C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe',
      ]
    : process.platform === 'darwin'
      ? [
          '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
          '/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge',
        ]
      : [
          '/usr/bin/google-chrome',
          '/usr/bin/chromium',
          '/usr/bin/chromium-browser',
          '/snap/bin/chromium',
        ];

  for (const candidate of candidates) {
    if (candidate && fs.existsSync(candidate)) return candidate;
  }

  const pathNames = process.platform === 'win32'
    ? ['chrome', 'msedge']
    : ['google-chrome', 'chromium', 'chromium-browser', 'microsoft-edge'];
  const locator = process.platform === 'win32' ? 'where' : 'which';
  for (const binName of pathNames) {
    try {
      const found = execFileSync(locator, [binName], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] })
        .split(/\r?\n/)
        .map((s) => s.trim())
        .find((s) => s && fs.existsSync(s));
      if (found) return found;
    } catch {
      // Binary not found on PATH; continue checking candidates
    }
  }

  throw new Error('Could not find Chrome/Edge binary. Pass --chrome-path <path> or set CHROME_PATH.');
}

export function patchLocalCanvasKit(rawText) {
  if (!/_flutter\.buildConfig\s*=\s*\{/.test(rawText)) return null;
  if (/["']?useLocalCanvasKit["']?\s*:\s*true\b/.test(rawText)) return null;
  if (/["']?useLocalCanvasKit["']?\s*:\s*false\b/.test(rawText)) {
    return rawText.replace(
      /(["']?useLocalCanvasKit["']?\s*:\s*)false\b/g,
      '$1true'
    );
  }
  return rawText.replace(
    /_flutter\.buildConfig\s*=\s*\{/,
    '_flutter.buildConfig = {"useLocalCanvasKit":true,'
  );
}

export function detectBaseHrefPrefix(resolvedRoot) {
  const indexPath = path.join(resolvedRoot, 'index.html');
  if (!fs.existsSync(indexPath)) return '/';
  const rawHtml = fs.readFileSync(indexPath, 'utf8').replace(/<!--[\s\S]*?-->/g, '');
  const match = rawHtml.match(/<base\s+[^>]*href=["']([^"']+)["'][^>]*>/i);
  if (!match) return '/';
  const href = match[1].trim();
  if (!href || href === '/' || href.includes('$FLUTTER_BASE_HREF') || /^[a-z]+:|^\/\//i.test(href)) {
    return '/';
  }
  const normalized = path.posix.normalize(`/${href.replace(/^\/+/, '')}`);
  if (normalized === '/' || normalized.includes('..')) return '/';
  return normalized.endsWith('/') ? normalized : `${normalized}/`;
}

function resolveStaticTarget(resolvedRoot, rawUrl, baseHrefPrefix = '/') {
  const cleanUrl = (rawUrl || '/').split('?')[0];
  let relPath;
  try {
    relPath = decodeURIComponent(cleanUrl);
  } catch {
    return { status: 400, message: 'Bad Request' };
  }
  if (baseHrefPrefix !== '/') {
    const baseNoTrailing = baseHrefPrefix.slice(0, -1);
    if (relPath === baseNoTrailing || relPath === baseHrefPrefix) {
      relPath = '/index.html';
    } else if (relPath.startsWith(baseHrefPrefix)) {
      relPath = relPath.slice(baseNoTrailing.length);
    }
  }
  if (relPath === '/') relPath = '/index.html';

  const resolved = path.resolve(resolvedRoot, `.${relPath}`);
  const relCheck = path.relative(resolvedRoot, resolved);
  if (relCheck.startsWith('..') || path.isAbsolute(relCheck)) {
    return { status: 403, message: 'Forbidden' };
  }

  if (fs.existsSync(resolved) && !fs.statSync(resolved).isDirectory()) {
    return { status: 200, targetFile: resolved };
  }
  const reqExt = path.extname(relPath).toLowerCase();
  if (STATIC_ASSET_EXTS.has(reqExt)) {
    return { status: 404, message: 'Not found' };
  }
  const fallback = path.join(resolvedRoot, 'index.html');
  if (fs.existsSync(fallback)) {
    return { status: 200, targetFile: fallback };
  }
  return { status: 404, message: 'Not found' };
}

function writeStaticResponse({ req, res, targetFile, headers, uncompressed, injectLocalRuntime, compressedCache }) {
  const ext = path.extname(targetFile).toLowerCase();
  const acceptEncoding = String(req.headers['accept-encoding'] || '').toLowerCase();
  let encoding = null;
  if (!uncompressed && COMPRESSIBLE_EXTS.has(ext)) {
    if (/\bbr\b/.test(acceptEncoding)) encoding = 'br';
    else if (/\bgzip\b/.test(acceptEncoding)) encoding = 'gzip';
  }

  const baseName = path.basename(targetFile).toLowerCase();
  let fileBuffer = null;
  if (injectLocalRuntime && (baseName === 'flutter_bootstrap.js' || baseName === 'index.html')) {
    const patched = patchLocalCanvasKit(fs.readFileSync(targetFile, 'utf8'));
    if (patched !== null) fileBuffer = Buffer.from(patched, 'utf8');
  }

  if (encoding) {
    const cacheKey = `${encoding}:${targetFile}`;
    let payload = compressedCache.get(cacheKey);
    if (!payload) {
      const raw = fileBuffer ?? fs.readFileSync(targetFile);
      payload = encoding === 'br'
        ? zlib.brotliCompressSync(raw, { params: { [zlib.constants.BROTLI_PARAM_QUALITY]: 5 } })
        : zlib.gzipSync(raw, { level: 6 });
      compressedCache.set(cacheKey, payload);
    }
    headers['Content-Encoding'] = encoding;
    headers['Vary'] = 'Accept-Encoding';
    headers['Content-Length'] = String(payload.length);
    res.writeHead(200, headers);
    res.end(payload);
    return;
  }

  if (fileBuffer) {
    headers['Content-Length'] = String(fileBuffer.length);
    res.writeHead(200, headers);
    res.end(fileBuffer);
    return;
  }

  const stat = fs.statSync(targetFile);
  headers['Content-Length'] = String(stat.size);
  res.writeHead(200, headers);
  fs.createReadStream(targetFile).pipe(res);
}

export function startStaticServer(rootDir, coopCoep, coepMode = 'require-corp', uncompressed = false, cdnRuntime = false) {
  if (!fs.existsSync(rootDir)) {
    throw new Error(`Serve directory not found: ${rootDir}`);
  }
  const resolvedRoot = path.resolve(rootDir);
  const baseHrefPrefix = detectBaseHrefPrefix(resolvedRoot);
  const injectLocalRuntime = !cdnRuntime && fs.existsSync(path.join(resolvedRoot, 'canvaskit'));
  const compressedCache = new Map();

  const server = http.createServer((req, res) => {
    const resolution = resolveStaticTarget(resolvedRoot, req.url, baseHrefPrefix);
    if (resolution.status !== 200) {
      res.writeHead(resolution.status);
      res.end(resolution.message);
      return;
    }

    const ext = path.extname(resolution.targetFile).toLowerCase();
    const headers = {
      'Content-Type': MIME_TYPES[ext] || 'application/octet-stream',
      'Cache-Control': 'no-cache',
    };
    if (coopCoep) {
      headers['Cross-Origin-Opener-Policy'] = 'same-origin';
      headers['Cross-Origin-Embedder-Policy'] = coepMode;
    }

    writeStaticResponse({
      req,
      res,
      targetFile: resolution.targetFile,
      headers,
      uncompressed,
      injectLocalRuntime,
      compressedCache,
    });
  });

  return new Promise((resolve, reject) => {
    server.on('error', reject);
    server.listen(0, '127.0.0.1', () => {
      const addr = server.address();
      resolve({ server, url: `http://127.0.0.1:${addr.port}${baseHrefPrefix}`, baseHref: baseHrefPrefix });
    });
  });
}

function safeReadText(filePath) {
  try {
    return fs.readFileSync(filePath, 'utf8');
  } catch {
    // Chrome on Windows may briefly hold an exclusive lock while writing
    return null;
  }
}

function killBrowserProcess(proc) {
  if (!proc || proc.exitCode !== null || !proc.pid) return;
  if (process.platform === 'win32') {
    try {
      execFileSync('taskkill', ['/PID', String(proc.pid), '/T', '/F'], { stdio: 'ignore' });
    } catch {
      // Process already exited
    }
  } else {
    try {
      proc.kill('SIGKILL');
    } catch {
      // Process already exited
    }
  }
}

function removeDirQuiet(dirPath) {
  if (!dirPath) return;
  try {
    fs.rmSync(dirPath, { recursive: true, force: true });
  } catch {
    // Chrome on Windows may release temp locks asynchronously after exit
  }
}

function launchChrome(chromeBin, headful) {
  const userDataDir = fs.mkdtempSync(path.join(os.tmpdir(), 'agy-mobile-web-'));
  const args = [
    '--remote-debugging-port=0',
    `--user-data-dir=${userDataDir}`,
    '--no-first-run',
    '--no-default-browser-check',
    '--disable-background-networking',
    '--disable-default-apps',
    '--disable-extensions',
    '--enable-webgl',
    '--ignore-gpu-blocklist',
    ...(headful ? [] : ['--headless=new']),
    'about:blank',
  ];

  const logPath = path.join(userDataDir, 'chrome.log');
  const logFd = fs.openSync(logPath, 'w');
  const proc = spawn(chromeBin, args, {
    stdio: ['ignore', 'ignore', logFd],
    detached: process.platform !== 'win32',
    windowsHide: true,
  });
  fs.closeSync(logFd);

  return new Promise((resolve, reject) => {
    let settled = false;
    const activePortPath = path.join(userDataDir, 'DevToolsActivePort');

    const fail = (err) => {
      if (settled) return;
      settled = true;
      clearInterval(poller);
      clearTimeout(timer);
      killBrowserProcess(proc);
      removeDirQuiet(userDataDir);
      reject(err);
    };

    const timer = setTimeout(() => {
      const logText = safeReadText(logPath) ?? '';
      fail(new Error(`Timed out waiting for Chrome DevTools endpoint.\n${logText}`));
    }, 15000);

    proc.on('error', fail);

    const poller = setInterval(() => {
      if (settled) return;
      const activePortText = safeReadText(activePortPath);
      if (activePortText) {
        const port = Number(activePortText.trim().split(/\r?\n/)[0]);
        if (Number.isInteger(port) && port > 0) {
          settled = true;
          clearInterval(poller);
          clearTimeout(timer);
          resolve({ proc, userDataDir, httpBase: `http://127.0.0.1:${port}` });
          return;
        }
      }
      const logText = safeReadText(logPath);
      const match = logText?.match(/DevTools listening on (ws:\/\/[^\s]+)/);
      if (match) {
        settled = true;
        clearInterval(poller);
        clearTimeout(timer);
        const wsUrl = new URL(match[1]);
        resolve({ proc, userDataDir, httpBase: `http://${wsUrl.hostname}:${wsUrl.port}` });
      }
    }, 50);
  });
}

export class CdpClient {
  constructor(wsUrl) {
    this.ws = new WebSocket(wsUrl);
    this.nextId = 1;
    this.pending = new Map();
    this.listeners = new Map();
    this.closed = false;
  }

  rejectAllPending(reason) {
    this.closed = true;
    const err = reason instanceof Error ? reason : new Error(String(reason));
    for (const { reject } of this.pending.values()) {
      reject(err);
    }
    this.pending.clear();
  }

  connect() {
    return new Promise((resolve, reject) => {
      let opened = false;
      this.ws.addEventListener('open', () => {
        opened = true;
        resolve();
      });
      this.ws.addEventListener('error', (e) => {
        const err = new Error(`CDP WebSocket error: ${e.message || 'unknown'}`);
        this.rejectAllPending(err);
        if (!opened) reject(err);
      });
      this.ws.addEventListener('close', (e) => {
        const err = new Error(`CDP WebSocket closed (${e?.code ?? 'unknown'})`);
        this.rejectAllPending(err);
        if (!opened) reject(err);
      });
      this.ws.addEventListener('message', (event) => {
        const msg = JSON.parse(event.data);
        if (msg.id && this.pending.has(msg.id)) {
          const { resolve: res, reject: rej } = this.pending.get(msg.id);
          this.pending.delete(msg.id);
          if (msg.error) rej(new Error(`CDP ${msg.error.message} (${msg.error.code})`));
          else res(msg.result);
        } else if (msg.method) {
          const handlers = this.listeners.get(msg.method) || [];
          for (const fn of handlers) fn(msg.params || {});
        }
      });
    });
  }

  on(method, handler) {
    if (!this.listeners.has(method)) this.listeners.set(method, []);
    this.listeners.get(method).push(handler);
  }

  send(method, params = {}) {
    if (this.closed) {
      return Promise.reject(new Error(`CDP WebSocket is closed before calling ${method}.`));
    }
    const id = this.nextId++;
    return new Promise((resolve, reject) => {
      this.pending.set(id, { resolve, reject });
      try {
        this.ws.send(JSON.stringify({ id, method, params }));
      } catch (err) {
        this.pending.delete(id);
        reject(err);
      }
    });
  }

  close() {
    this.rejectAllPending('CDP client closed.');
    try {
      this.ws.close();
    } catch {
      // Ignore close errors during teardown
    }
  }
}

export function buildInjectedProbeScript(simulateWebkitFallback) {
  const vendorPatch = simulateWebkitFallback
    ? `try { Object.defineProperty(navigator, 'vendor', { get: () => 'Apple Computer, Inc.', configurable: true }); } catch { /* Ignore non-configurable navigator.vendor */ }`
    : '';

  return `(() => {
  ${vendorPatch}
  try { performance.setResourceTimingBufferSize?.(1000); } catch { /* Ignore if resource buffer API is restricted */ }
  const perfData = {
    fpMs: null,
    fcpMs: null,
    lcpMs: null,
    cls: 0,
    longTasks: [],
    samplingStartedAtMs: null,
    rafDeltasMs: [],
    flutterDetectedAtMs: null,
    firstSceneAtMs: null,
    runningRaf: false,
    lastRafTs: 0,
    initialScrollY: 0,
  };

  try {
    new PerformanceObserver((list) => {
      for (const entry of list.getEntries()) {
        if (entry.name === 'first-paint') perfData.fpMs = entry.startTime;
        if (entry.name === 'first-contentful-paint') perfData.fcpMs = entry.startTime;
      }
    }).observe({ type: 'paint', buffered: true });
  } catch { /* Paint observer unavailable in stripped browser context */ }

  try {
    new PerformanceObserver((list) => {
      const entries = list.getEntries();
      if (entries.length > 0) perfData.lcpMs = entries[entries.length - 1].startTime;
    }).observe({ type: 'largest-contentful-paint', buffered: true });
  } catch { /* LCP observer unsupported */ }

  try {
    new PerformanceObserver((list) => {
      for (const entry of list.getEntries()) {
        if (!entry.hadRecentInput) perfData.cls += entry.value;
      }
    }).observe({ type: 'layout-shift', buffered: true });
  } catch { /* Layout-shift observer unsupported */ }

  try {
    new PerformanceObserver((list) => {
      for (const entry of list.getEntries()) {
        perfData.longTasks.push({
          startMs: Math.round(entry.startTime),
          durationMs: Number(entry.duration.toFixed(1)),
        });
      }
    }).observe({ type: 'longtask', buffered: true });
  } catch { /* Longtask observer unsupported */ }

  function rafLoop(ts) {
    if (!perfData.runningRaf) return;
    if (perfData.lastRafTs > 0) {
      perfData.rafDeltasMs.push(ts - perfData.lastRafTs);
    }
    perfData.lastRafTs = ts;
    requestAnimationFrame(rafLoop);
  }

  function queryDeep(root, selector) {
    if (!root) return null;
    const direct = root.querySelector?.(selector);
    if (direct) return direct;
    const all = root.querySelectorAll?.('*') || [];
    for (const el of all) {
      if (el.shadowRoot) {
        const hit = queryDeep(el.shadowRoot, selector);
        if (hit) return hit;
      }
    }
    return null;
  }

  let rootObserver = null;

  function detectFlutterRoot() {
    const view = document.querySelector('flutter-view, flt-glass-pane, canvas');
    if (view && perfData.flutterDetectedAtMs === null) {
      perfData.flutterDetectedAtMs = performance.now();
    }
    const scene = queryDeep(document, 'flt-scene');
    if ((scene || typeof window.__flutterFirstFrameMs === 'number') && perfData.firstSceneAtMs === null) {
      perfData.firstSceneAtMs = typeof window.__flutterFirstFrameMs === 'number'
        ? window.__flutterFirstFrameMs
        : performance.now();
      if (perfData.flutterDetectedAtMs === null) {
        perfData.flutterDetectedAtMs = perfData.firstSceneAtMs;
      }
    }
    if (perfData.flutterDetectedAtMs !== null && perfData.firstSceneAtMs !== null && rootObserver) {
      rootObserver.disconnect();
      rootObserver = null;
    }
    return Boolean(view);
  }

  try {
    rootObserver = new MutationObserver(() => detectFlutterRoot());
    rootObserver.observe(document, { childList: true, subtree: true });
  } catch { /* MutationObserver fallback handled by polling detectFlutterRoot */ }

  function isFirstSceneReady() {
    detectFlutterRoot();
    return perfData.firstSceneAtMs !== null;
  }

  function detectRenderer(resources) {
    const paths = resources.map((u) => {
      try { return new URL(u, window.location.href).pathname; } catch { /* Fall back to raw path on malformed resource URL */ return String(u).split('?')[0]; }
    });
    const hasWimp = paths.some((p) => /(?:^|\\/)wimp(?:\\.[a-f0-9]+)?\\.(?:wasm|js|mjs)$/i.test(p));
    const hasSkwasm = paths.some((p) => /(?:^|\\/)skwasm(?:_heavy|_st)?(?:\\.[a-f0-9]+)?\\.(?:wasm|js|mjs)$/i.test(p));
    const hasCanvasKit = paths.some((p) => /(?:^|\\/)canvaskit(?:\\.[a-f0-9]+)?\\.(?:wasm|js|mjs)$/i.test(p));
    const hasMainWasm = paths.some((p) => /(?:^|\\/)main\\.dart(?:\\.[a-f0-9]+)?\\.wasm$/i.test(p));
    const hasMainJs = paths.some((p) => /(?:^|\\/)main\\.dart(?:\\.[a-f0-9]+)?\\.js$/i.test(p));

    if (hasWimp) return 'wimp-wasm';
    if (hasSkwasm) return 'skwasm-wasm';
    if (hasCanvasKit) return hasMainWasm && !hasMainJs ? 'canvaskit-wasm' : 'canvaskit-js';
    if (document.querySelector('flutter-view, flt-glass-pane')) return 'flutter-web';
    return 'non-flutter-or-unknown';
  }

  window.__mobilePerfProbe = {
    detectFlutterRoot,
    isFirstSceneReady,
    startSampling() {
      perfData.rafDeltasMs = [];
      perfData.lastRafTs = 0;
      perfData.runningRaf = true;
      perfData.samplingStartedAtMs = performance.now();
      perfData.initialScrollY = window.scrollY || 0;
      if (Array.isArray(window.__flutterFrameTimings)) {
        window.__flutterFrameTimings.length = 0;
      }
      requestAnimationFrame(rafLoop);
    },
    stopSampling() {
      perfData.runningRaf = false;
    },
    snapshot() {
      detectFlutterRoot();
      const nav = performance.getEntriesByType('navigation')[0];
      const resources = performance.getEntriesByType('resource').map((r) => r.name);
      const renderer = detectRenderer(resources);

      const deltas = [...perfData.rafDeltasMs].sort((a, b) => a - b);
      const sum = deltas.reduce((a, b) => a + b, 0);
      const pct = (p) => (deltas.length ? deltas[Math.min(deltas.length - 1, Math.floor((deltas.length - 1) * p))] : 0);

      const flutterTimings = Array.isArray(window.__flutterFrameTimings)
        ? window.__flutterFrameTimings
        : null;

      return {
        navigatorVendor: navigator.vendor,
        crossOriginIsolated: Boolean(window.crossOriginIsolated),
        dpr: window.devicePixelRatio,
        viewport: { width: window.innerWidth, height: window.innerHeight },
        horizontalOverflowPx: Math.max(0, document.documentElement.scrollWidth - window.innerWidth),
        domScrollDeltaPx: Math.abs((window.scrollY || 0) - perfData.initialScrollY),
        renderer,
        flutterDetectedAtMs: perfData.flutterDetectedAtMs ? Number(perfData.flutterDetectedAtMs.toFixed(1)) : null,
        firstSceneAtMs: perfData.firstSceneAtMs ? Number(perfData.firstSceneAtMs.toFixed(1)) : null,
        flutterFirstFrameMs: typeof window.__flutterFirstFrameMs === 'number'
          ? Number(window.__flutterFirstFrameMs.toFixed(1))
          : null,
        navigation: nav
          ? {
              ttfbMs: Number((nav.responseStart - nav.requestStart).toFixed(1)),
              domContentLoadedMs: Number(nav.domContentLoadedEventEnd.toFixed(1)),
              loadMs: Number(nav.loadEventEnd.toFixed(1)),
            }
          : null,
        fpMs: perfData.fpMs ? Number(perfData.fpMs.toFixed(1)) : null,
        fcpMs: perfData.fcpMs ? Number(perfData.fcpMs.toFixed(1)) : null,
        lcpMs: perfData.lcpMs ? Number(perfData.lcpMs.toFixed(1)) : null,
        cls: Number(perfData.cls.toFixed(4)),
        longTasks: perfData.longTasks,
        bootLongTasks:
          perfData.samplingStartedAtMs !== null
            ? perfData.longTasks.filter((t) => t.startMs < perfData.samplingStartedAtMs)
            : perfData.longTasks,
        interactiveLongTasks:
          perfData.samplingStartedAtMs !== null
            ? perfData.longTasks.filter((t) => t.startMs >= perfData.samplingStartedAtMs)
            : [],
        rafStats: {
          frameCount: deltas.length,
          avgFps: sum > 0 ? Number(((deltas.length * 1000) / sum).toFixed(1)) : 0,
          p50Ms: Number(pct(0.5).toFixed(2)),
          p95Ms: Number(pct(0.95).toFixed(2)),
          p99Ms: Number(pct(0.99).toFixed(2)),
          maxMs: Number((deltas[deltas.length - 1] || 0).toFixed(2)),
          droppedOver20Ms: deltas.filter((d) => d > 20.0).length,
          jankOver33Ms: deltas.filter((d) => d > 33.3).length,
          severeOver50Ms: deltas.filter((d) => d > 50.0).length,
        },
        flutterEngineTimings: flutterTimings,
      };
    },
  };
})();`;
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function performTouchScrollSweep(cdp, width, height, sweepIndex = 0) {
  const x = Math.round(width * 0.5);
  const swipeUpFinger = sweepIndex % 2 === 0;
  const startY = Math.round(height * (swipeUpFinger ? 0.74 : 0.28));
  const endY = Math.round(height * (swipeUpFinger ? 0.22 : 0.78));
  const steps = 12;

  await cdp.send('Input.dispatchTouchEvent', {
    type: 'touchStart',
    touchPoints: [{ x, y: startY, radiusX: 12, radiusY: 12, force: 1, id: 1 }],
  });
  for (let s = 1; s <= steps; s += 1) {
    const t = s / steps;
    const eased = 0.7 * t + 0.3 * t * t;
    const y = Math.round(startY + (endY - startY) * eased);
    await cdp.send('Input.dispatchTouchEvent', {
      type: 'touchMove',
      touchPoints: [{ x, y, radiusX: 12, radiusY: 12, force: 1, id: 1 }],
    });
    await sleep(12);
  }
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
  await sleep(450);
}

export function summarizeFlutterTimings(timings) {
  if (!Array.isArray(timings) || timings.length === 0) return null;
  const statsFor = (key) => {
    const vals = timings.map((t) => Number(t[key]) / 1000).sort((a, b) => a - b);
    const sum = vals.reduce((a, b) => a + b, 0);
    const p95 = vals[Math.min(vals.length - 1, Math.floor((vals.length - 1) * 0.95))];
    return {
      avgMs: Number((sum / vals.length).toFixed(2)),
      p95Ms: Number(p95.toFixed(2)),
      maxMs: Number(vals[vals.length - 1].toFixed(2)),
    };
  };
  return {
    sampleCount: timings.length,
    build: statsFor('buildUs'),
    raster: statsFor('rasterUs'),
    totalSpan: statsFor('totalUs'),
  };
}

export function categorizeTransfer(requests) {
  const breakdown = {
    appBytes: 0,
    runtimeBytes: 0,
    fontBytes: 0,
    imageBytes: 0,
    otherBytes: 0,
    fallbackFontRequests: 0,
  };
  for (const r of requests.values()) {
    const bytes = r.bytes || 0;
    const url = r.url || '';
    const pathname = url.split('?')[0];
    if (/fonts\.gstatic\.com/i.test(url)) breakdown.fallbackFontRequests += 1;
    if (/(?:^|\/)(?:skwasm(?:_heavy|_st)?|canvaskit|wimp)(?:\.[a-f0-9]+)?\.(?:wasm|js|mjs)$/i.test(pathname)) {
      breakdown.runtimeBytes += bytes;
    } else if (r.type === 'Font' || /\.(ttf|otf|woff|woff2)$/i.test(pathname)) {
      breakdown.fontBytes += bytes;
    } else if (r.type === 'Image' || /\.(png|jpe?g|webp|avif|gif|svg|ico)$/i.test(pathname)) {
      breakdown.imageBytes += bytes;
    } else if (/(\/index\.html|\/flutter_bootstrap\.js|\/main\.dart)/i.test(pathname) || r.type === 'Document') {
      breakdown.appBytes += bytes;
    } else {
      breakdown.otherBytes += bytes;
    }
  }
  return breakdown;
}

function appendEngineTimingFindings(findings, flutterEngineSummary, snapshot, opts) {
  if (flutterEngineSummary) {
    if (flutterEngineSummary.build.p95Ms > 16.7) {
      findings.push({ severity: 'FAIL', message: `Flutter UI build p95 is ${flutterEngineSummary.build.p95Ms} ms (> 16.7 ms budget).` });
    } else if (flutterEngineSummary.build.p95Ms > 12.0) {
      findings.push({ severity: 'WARN', message: `Flutter UI build p95 is ${flutterEngineSummary.build.p95Ms} ms (> 12.0 ms mobile target).` });
    }
    if (flutterEngineSummary.raster.p95Ms > 16.7) {
      findings.push({ severity: 'FAIL', message: `Flutter raster p95 is ${flutterEngineSummary.raster.p95Ms} ms (> 16.7 ms budget).` });
    } else if (flutterEngineSummary.raster.p95Ms > 12.0) {
      findings.push({ severity: 'WARN', message: `Flutter raster p95 is ${flutterEngineSummary.raster.p95Ms} ms (> 12.0 ms mobile target).` });
    }
    return;
  }
  if (Array.isArray(snapshot.flutterEngineTimings) && opts.scrollSweeps > 0) {
    findings.push({
      severity: 'INFO',
      message: '0 Flutter engine frames recorded during touch scroll sweeps (initial route may be non-scrollable - verify on a scrollable list/feed route).',
    });
  } else if (opts.scrollSweeps > 0 && snapshot.domScrollDeltaPx === 0) {
    findings.push({
      severity: 'INFO',
      message: 'No Flutter FrameTiming bridge (web_perf_probe.dart) active; cannot confirm whether touch sweeps scrolled a canvas widget or stayed on a static landing screen.',
    });
  }
}

function appendTransferFindings(findings, totalTransferBytes, transferBreakdown, snapshot, opts) {
  const transferKb = Number((totalTransferBytes / 1024).toFixed(1));
  const runtimeKb = Number(((transferBreakdown.runtimeBytes || 0) / 1024).toFixed(1));
  const appAndAssetsKb = Number((transferKb - runtimeKb).toFixed(1));
  const isWebkitFallbackRun = opts.simulateWebkitFallback && snapshot.renderer === 'canvaskit-js';
  const warnTransferKb = isWebkitFallbackRun ? 4200 : 2500;
  const failTransferKb = isWebkitFallbackRun ? 6000 : 5000;

  if (transferKb > failTransferKb || (isWebkitFallbackRun && appAndAssetsKb > 3000)) {
    findings.push({
      severity: 'FAIL',
      message: `Total mobile page transfer is ${transferKb} KB (app+assets: ${appAndAssetsKb} KB, runtime: ${runtimeKb} KB), exceeding mobile budget.`,
    });
  } else if (transferKb > warnTransferKb || (isWebkitFallbackRun && appAndAssetsKb > 1500)) {
    findings.push({
      severity: 'WARN',
      message: `Total mobile page transfer is ${transferKb} KB (app+assets: ${appAndAssetsKb} KB, runtime: ${runtimeKb} KB), above target budget.`,
    });
  } else if (isWebkitFallbackRun && transferKb > 2500) {
    findings.push({
      severity: 'INFO',
      message: `Total transfer is ${transferKb} KB due to ${runtimeKb} KB CanvasKit fallback runtime; app+assets transfer is ${appAndAssetsKb} KB (within <= 1500 KB budget).`,
    });
  }
  if (transferBreakdown.fallbackFontRequests > 0) {
    findings.push({
      severity: 'INFO',
      message: `Detected ${transferBreakdown.fallbackFontRequests} runtime Noto fallback font request(s) from fonts.gstatic.com; bundle subsetted WOFF2 fonts if text pop-in affects initial paint.`,
    });
  }
}

function appendRendererAndViewportFindings(findings, snapshot, opts) {
  if (snapshot.horizontalOverflowPx > 0) {
    findings.push({
      severity: 'WARN',
      message: `HTML document overflows mobile viewport horizontally by ${snapshot.horizontalOverflowPx} px.`,
    });
  }
  if (Math.abs(snapshot.viewport.width - opts.expectedViewportWidth) > 2) {
    findings.push({
      severity: 'WARN',
      message: `Mobile layout viewport mismatch: rendered at ${snapshot.viewport.width}x${snapshot.viewport.height} instead of ${opts.expectedViewportWidth}px wide (check active <meta name="viewport" content="width=device-width, initial-scale=1.0"> in index.html).`,
    });
  }
  if (snapshot.renderer === 'canvaskit-js') {
    findings.push({
      severity: opts.simulateWebkitFallback ? 'INFO' : 'WARN',
      message: opts.simulateWebkitFallback
        ? 'Simulated iOS WebKit fallback active: running dart2js + CanvasKit (note: host engine remains Chromium V8/ANGLE, not Apple JSC/Metal).'
        : 'App initialized CanvasKit JS fallback instead of Skwasm (--wasm).',
    });
  } else if (snapshot.renderer === 'canvaskit-wasm') {
    findings.push({
      severity: 'INFO',
      message: 'App initialized dart2wasm with CanvasKit renderer (Skwasm not selected or unavailable).',
    });
  } else if (opts.device === 'ios-safari' && !opts.simulateWebkitFallback) {
    findings.push({
      severity: 'INFO',
      message: 'Preset "ios-safari" without --simulate-webkit-fallback runs Chromium Blink (Skwasm); real iOS Safari defaults to dart2js + CanvasKit in Flutter 3.50 (re-run with --simulate-webkit-fallback to measure fallback payload/JS path).',
    });
  }
}

function resolveBootLongTasks(snapshot) {
  if (Array.isArray(snapshot.bootLongTasks)) return snapshot.bootLongTasks;
  const interactive = Array.isArray(snapshot.interactiveLongTasks) ? snapshot.interactiveLongTasks : [];
  if (interactive.length === 0) return snapshot.longTasks;
  const minInteractiveStart = interactive.reduce((min, t) => Math.min(min, t.startMs), Infinity);
  return snapshot.longTasks.filter((t) => t.startMs < minInteractiveStart);
}

export function evaluateReport(data, flutterEngineSummary, opts) {
  const findings = [];
  const { consoleErrors, failedRequests, snapshot, totalTransferBytes, transferBreakdown } = data;

  if (consoleErrors.length > 0) {
    findings.push({ severity: 'FAIL', message: `${consoleErrors.length} runtime/console error(s) detected.` });
  }
  if (failedRequests.length > 0) {
    const coepBlocked = failedRequests.some((r) => /ERR_BLOCKED_BY_RESPONSE/i.test(r.reason));
    findings.push({
      severity: 'FAIL',
      message: `${failedRequests.length} failed network request(s)${coepBlocked ? ' (includes ERR_BLOCKED_BY_RESPONSE - check Cross-Origin-Resource-Policy or --coep-mode credentialless)' : ''}.`,
    });
  }
  if (snapshot.flutterDetectedAtMs === null) {
    findings.push({ severity: 'FAIL', message: 'Flutter Web root (<flutter-view>/<canvas>) failed to mount within timeout.' });
  }

  const startupMs = snapshot.flutterFirstFrameMs ?? snapshot.firstSceneAtMs ?? snapshot.flutterDetectedAtMs;
  if (startupMs !== null) {
    if (startupMs > 8000) {
      findings.push({
        severity: 'FAIL',
        message: `First scene / startup took ${startupMs} ms (> 8000 ms budget under ${opts.network} + ${opts.cpu}x CPU throttle).`,
      });
    } else if (startupMs > 4000) {
      findings.push({
        severity: 'WARN',
        message: `First scene / startup took ${startupMs} ms (> 4000 ms mobile target).`,
      });
    }
  }

  const bootTasks = resolveBootLongTasks(snapshot);
  const maxBootLongTask = bootTasks.reduce((m, t) => Math.max(m, t.durationMs), 0);
  const maxInteractiveLongTask = (snapshot.interactiveLongTasks || []).reduce((m, t) => Math.max(m, t.durationMs), 0);
  if (maxInteractiveLongTask > 200) {
    findings.push({
      severity: 'WARN',
      message: `Interactive Long Task peaked at ${maxInteractiveLongTask} ms during scroll/interaction (> 200 ms target).`,
    });
  }
  if (maxBootLongTask > 600) {
    findings.push({
      severity: 'WARN',
      message: `Cold-boot Long Task peaked at ${maxBootLongTask} ms during Wasm/engine initialization (> 600 ms target under ${opts.cpu}x CPU throttle).`,
    });
  }

  if (snapshot.rafStats.p95Ms > 33.3) {
    findings.push({
      severity: 'FAIL',
      message: `p95 frame time is ${snapshot.rafStats.p95Ms} ms (> 33.3 ms threshold under throttled mobile emulation).`,
    });
  } else if (snapshot.rafStats.p95Ms > 24.0) {
    findings.push({
      severity: 'WARN',
      message: `p95 frame time is ${snapshot.rafStats.p95Ms} ms (> 24 ms target under mobile CPU throttling).`,
    });
  }
  if (snapshot.rafStats.severeOver50Ms > 3) {
    findings.push({
      severity: 'FAIL',
      message: `${snapshot.rafStats.severeOver50Ms} severe jank frames (> 50 ms) observed during sampling.`,
    });
  } else if (snapshot.rafStats.severeOver50Ms > 0) {
    findings.push({
      severity: 'WARN',
      message: `${snapshot.rafStats.severeOver50Ms} frame(s) exceeded 50 ms during sampling.`,
    });
  }

  appendEngineTimingFindings(findings, flutterEngineSummary, snapshot, opts);
  appendTransferFindings(findings, totalTransferBytes, transferBreakdown, snapshot, opts);
  appendRendererAndViewportFindings(findings, snapshot, opts);

  const status = findings.some((f) => f.severity === 'FAIL')
    ? 'FAIL'
    : findings.some((f) => f.severity === 'WARN')
      ? 'WARN'
      : 'PASS';

  return { status, findings };
}

export function formatMarkdown(report) {
  const s = report.snapshot;
  const tb = report.transferBreakdown;
  const transferKb = (report.totalTransferBytes / 1024).toFixed(1);
  const heapMb = report.cdpMetrics.JSHeapUsedSize
    ? (report.cdpMetrics.JSHeapUsedSize / (1024 * 1024)).toFixed(1)
    : 'n/a';
  const kbStr = (b) => `${(b / 1024).toFixed(1)} KB`;

  const lines = [
    `# Mobile Web Runtime Evaluation (${report.evaluation.status})`,
    '',
    `- **Target URL:** \`${report.targetUrl}\``,
    `- **Emulation:** \`${report.device.name}\` (${s.viewport.width}x${s.viewport.height} @${s.dpr}x DPR), CPU ${report.cpuRate}x throttle, Network \`${report.networkPreset}\`${report.simulateWebkitFallback ? ', WebKit fallback simulated' : ''}`,
    `- **Detected Renderer:** \`${s.renderer}\` | \`crossOriginIsolated\`: \`${s.crossOriginIsolated}\``,
    `- **Root / First Scene / Dart Frame #1:** ${s.flutterDetectedAtMs ?? 'n/a'} ms / ${s.firstSceneAtMs ?? 'n/a'} ms / ${s.flutterFirstFrameMs ?? 'n/a'} ms`,
    '',
    '## Load & Transfer',
    `- **Total Encoded Transfer:** ${transferKb} KB across ${report.requestCount} requests (${report.failedRequests.length} failed)`,
    `- **Breakdown:** App: ${kbStr(tb.appBytes)} | Runtime: ${kbStr(tb.runtimeBytes)} | Fonts: ${kbStr(tb.fontBytes)} | Images: ${kbStr(tb.imageBytes)} | Other: ${kbStr(tb.otherBytes)}`,
    `- **TTFB / DOMContentLoaded / Load:** ${s.navigation?.ttfbMs ?? 'n/a'} ms / ${s.navigation?.domContentLoadedMs ?? 'n/a'} ms / ${s.navigation?.loadMs ?? 'n/a'} ms`,
    `- **FCP / LCP / CLS:** ${s.fpMs ?? 'n/a'} ms / ${s.lcpMs ?? 'n/a'} ms / ${s.cls}`,
    '',
    '## Runtime Smoothness & Memory',
    `- **Sampled Frames (${s.rafStats.frameCount}):** Avg **${s.rafStats.avgFps} FPS** | p50: ${s.rafStats.p50Ms} ms | p95: **${s.rafStats.p95Ms} ms** | Max: ${s.rafStats.maxMs} ms`,
    `- **Jank Counts:** >20ms: ${s.rafStats.droppedOver20Ms} | >33.3ms: ${s.rafStats.jankOver33Ms} | >50ms: ${s.rafStats.severeOver50Ms}`,
    `- **Long Tasks (>50ms):** ${s.longTasks.length} total (max ${s.longTasks.reduce((m, t) => Math.max(m, t.durationMs), 0)} ms)`,
    `- **JS Heap Used:** ${heapMb} MB (JS glue heap only; excludes WasmGC & Skwasm linear Wasm/WebGL memory)`,
  ];

  if (report.flutterEngineSummary) {
    const f = report.flutterEngineSummary;
    lines.push(
      '',
      `## Flutter Engine Timings (${f.sampleCount} frames)`,
      `- **UI Build:** avg ${f.build.avgMs} ms | p95 ${f.build.p95Ms} ms | max ${f.build.maxMs} ms`,
      `- **Raster:** avg ${f.raster.avgMs} ms | p95 ${f.raster.p95Ms} ms | max ${f.raster.maxMs} ms`,
      `- **Total Span:** avg ${f.totalSpan.avgMs} ms | p95 ${f.totalSpan.p95Ms} ms | max ${f.totalSpan.maxMs} ms`
    );
  }
  if (report.screenshotPath) {
    lines.push('', `- **Mobile Screenshot Saved:** \`${report.screenshotPath}\``);
  }
  lines.push('', '## Evaluation Findings');
  if (report.evaluation.findings.length === 0) {
    lines.push('- All mobile web checks passed within target thresholds.');
  } else {
    for (const f of report.evaluation.findings) {
      lines.push(`- **[${f.severity}]** ${f.message}`);
    }
  }
  if (report.consoleErrors.length > 0) {
    lines.push('', '## Console / Runtime Errors');
    for (const err of report.consoleErrors.slice(0, 10)) {
      lines.push(`- \`${err}\``);
    }
  }
  return lines.join('\n');
}

async function runProfile(opts) {
  if (typeof WebSocket !== 'function') {
    throw new Error(
      `Global WebSocket is unavailable in Node ${process.versions.node}. Use Node 22+ (or pass --experimental-websocket on Node 20/21).`
    );
  }
  const device = resolveDeviceConfig(opts);
  const chromeBin = findChromeBinary(opts.chromePath);
  let serverHandle = null;
  let browser = null;
  let cdp = null;

  try {
    serverHandle = opts.serveDir
      ? await startStaticServer(opts.serveDir, opts.coopCoep, opts.coepMode, opts.uncompressed, opts.cdnRuntime)
      : null;
    const targetUrl = serverHandle ? serverHandle.url : opts.url;
    browser = await launchChrome(chromeBin, opts.headful);
    const targetsRes = await fetch(`${browser.httpBase}/json/list`);
    const targets = await targetsRes.json();
    const pageTarget = targets.find((t) => t.type === 'page') || targets[0];
    if (!pageTarget?.webSocketDebuggerUrl) {
      throw new Error('Failed to locate Chrome page target WebSocket URL.');
    }

    cdp = new CdpClient(pageTarget.webSocketDebuggerUrl);
    await cdp.connect();

    await Promise.all([
      cdp.send('Page.enable'),
      cdp.send('Network.enable'),
      cdp.send('Runtime.enable'),
      cdp.send('Log.enable'),
      cdp.send('Performance.enable'),
    ]);

    await cdp.send('Emulation.setDeviceMetricsOverride', {
      width: device.width,
      height: device.height,
      deviceScaleFactor: device.dpr,
      mobile: true,
    });
    await cdp.send('Emulation.setTouchEmulationEnabled', { enabled: true, maxTouchPoints: 5 });
    await cdp.send('Network.setUserAgentOverride', { userAgent: device.userAgent });
    if (opts.cpu > 1) {
      await cdp.send('Emulation.setCPUThrottlingRate', { rate: opts.cpu });
    }
    if (NETWORK_PRESETS[opts.network]) {
      await cdp.send('Network.emulateNetworkConditions', NETWORK_PRESETS[opts.network]);
    }
    await cdp.send('Page.addScriptToEvaluateOnNewDocument', {
      source: buildInjectedProbeScript(opts.simulateWebkitFallback),
    });

    const requests = new Map();
    const failedRequests = [];
    const consoleErrors = [];
    let totalTransferBytes = 0;

    cdp.on('Network.requestWillBeSent', (p) => {
      requests.set(p.requestId, { url: p.request.url, type: p.type, status: null, bytes: 0 });
    });
    cdp.on('Network.responseReceived', (p) => {
      const entry = requests.get(p.requestId);
      if (entry) entry.status = p.response.status;
      if (p.response.status >= 400) {
        failedRequests.push({ url: p.response.url, reason: `HTTP ${p.response.status}` });
      }
    });
    cdp.on('Network.loadingFinished', (p) => {
      totalTransferBytes += p.encodedDataLength || 0;
      const entry = requests.get(p.requestId);
      if (entry) entry.bytes = p.encodedDataLength || 0;
    });
    cdp.on('Network.loadingFailed', (p) => {
      if (!p.canceled) {
        const entry = requests.get(p.requestId);
        failedRequests.push({ url: entry?.url || p.requestId, reason: p.errorText || 'failed' });
      }
    });
    cdp.on('Runtime.exceptionThrown', (p) => {
      const text = p.exceptionDetails?.exception?.description || p.exceptionDetails?.text || 'Uncaught exception';
      consoleErrors.push(text.split('\n')[0]);
    });
    cdp.on('Runtime.consoleAPICalled', (p) => {
      if (p.type === 'error') {
        consoleErrors.push(p.args.map((a) => a.value ?? a.description ?? '').join(' ').trim());
      }
    });
    cdp.on('Log.entryAdded', (p) => {
      if (p.entry?.level === 'error') consoleErrors.push(p.entry.text);
    });

    const loadDone = new Promise((resolve) => cdp.on('Page.loadEventFired', resolve));
    await cdp.send('Page.navigate', { url: targetUrl });
    await Promise.race([loadDone, sleep(opts.loadTimeoutMs)]);

    const { result: hasFlutterScripts } = await cdp.send('Runtime.evaluate', {
      expression:
        'Boolean(document.querySelector("script[src*=flutter], script[src*=\\"main.dart\\"], flutter-view, flt-glass-pane") || window._flutter?.buildConfig || window._flutter?.loader || typeof window.__flutterFirstFrameMs === "number")',
      returnByValue: true,
    });
    const waitLimit = hasFlutterScripts?.value ? opts.loadTimeoutMs : Math.min(opts.loadTimeoutMs, 1500);
    const deadline = Date.now() + waitLimit;
    while (Date.now() < deadline) {
      const { result } = await cdp.send('Runtime.evaluate', {
        expression: 'window.__mobilePerfProbe?.isFirstSceneReady() ?? false',
        returnByValue: true,
      });
      if (result?.value) break;
      await sleep(100);
    }

    await sleep(opts.waitMs);

    await cdp.send('Runtime.evaluate', { expression: 'window.__mobilePerfProbe.startSampling()' });
    await sleep(500);
    for (let s = 0; s < opts.scrollSweeps; s += 1) {
      await performTouchScrollSweep(cdp, device.width, device.height, s);
    }
    await sleep(400);
    await cdp.send('Runtime.evaluate', { expression: 'window.__mobilePerfProbe.stopSampling()' });

    const [evalReply, { metrics: rawMetrics }] = await Promise.all([
      cdp.send('Runtime.evaluate', {
        expression: 'window.__mobilePerfProbe?.snapshot() ?? null',
        returnByValue: true,
      }),
      cdp.send('Performance.getMetrics'),
    ]);
    if (evalReply?.exceptionDetails || !evalReply?.result?.value) {
      const detail = evalReply?.exceptionDetails?.text || 'probe snapshot missing';
      throw new Error(`Failed to collect mobile perf snapshot: ${detail}`);
    }

    const cdpMetrics = {};
    for (const m of rawMetrics) cdpMetrics[m.name] = m.value;

    let screenshotPath = null;
    if (opts.screenshot) {
      fs.mkdirSync(path.dirname(opts.screenshot), { recursive: true });
      const shot = await cdp.send('Page.captureScreenshot', { format: 'png' });
      fs.writeFileSync(opts.screenshot, Buffer.from(shot.data, 'base64'));
      screenshotPath = opts.screenshot;
    }

    const snapshot = evalReply.result.value;
    const transferBreakdown = categorizeTransfer(requests);
    const flutterEngineSummary = summarizeFlutterTimings(snapshot.flutterEngineTimings);
    const evaluation = evaluateReport(
      { consoleErrors, failedRequests, snapshot, totalTransferBytes, transferBreakdown },
      flutterEngineSummary,
      { ...opts, expectedViewportWidth: device.width }
    );

    return {
      targetUrl,
      device: { name: opts.device, ...device },
      cpuRate: opts.cpu,
      networkPreset: opts.network,
      simulateWebkitFallback: opts.simulateWebkitFallback,
      requestCount: requests.size,
      totalTransferBytes,
      transferBreakdown,
      failedRequests,
      consoleErrors,
      cdpMetrics,
      snapshot,
      flutterEngineSummary,
      screenshotPath,
      evaluation,
    };
  } finally {
    if (cdp) {
      await Promise.race([
        cdp.send('Browser.close').catch(() => {
          // Best-effort browser close before explicit process/socket teardown
        }),
        sleep(600),
      ]);
      cdp.close();
    }
    if (browser?.proc && browser.proc.exitCode === null && !browser.proc.killed) {
      await Promise.race([
        new Promise((resolve) => browser.proc.once('exit', resolve)),
        sleep(600),
      ]);
    }
    killBrowserProcess(browser?.proc);
    if (serverHandle) {
      serverHandle.server.closeAllConnections?.();
      serverHandle.server.close();
    }
    removeDirQuiet(browser?.userDataDir);
  }
}

function isMainModule() {
  if (!process.argv[1]) return false;
  try {
    return fs.realpathSync(process.argv[1]) === fs.realpathSync(fileURLToPath(import.meta.url));
  } catch {
    // Missing or virtual argv[1] during non-CLI execution
    return false;
  }
}

if (isMainModule()) {
  try {
    const opts = parseArgs(process.argv.slice(2));
    const report = await runProfile(opts);
    console.log(opts.json ? JSON.stringify(report, null, 2) : formatMarkdown(report));
    process.exit(resolveExitCode(report.evaluation.status, opts.failOn));
  } catch (err) {
    console.error(`Error: ${err.message}`);
    process.exit(1);
  }
}
