#!/usr/bin/env node
/**
 * Analyzes a compiled Flutter Web directory (`build/web`) for mobile browser
 * bundle budgets, Wasm readiness, deferred loading, font formats, oversized
 * assets, and HTML viewport hygiene.
 *
 * Usage:
 *   node analyze_web_bundle.mjs [buildWebDir] [--json] [--max-initial-kb 1500] [--max-asset-kb 250] [--fail-on none|fail|warn]
 */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import zlib from 'node:zlib';

const FAIL_ON_MODES = new Set(['none', 'fail', 'warn']);

export function parsePositiveNumberFlag(argv, index, flagName) {
  const raw = argv[index + 1];
  if (raw === undefined || raw.startsWith('-')) {
    throw new Error(`${flagName} requires a positive number.`);
  }
  const value = Number(raw);
  if (!Number.isFinite(value) || value <= 0) {
    throw new Error(`${flagName} must be a positive number.`);
  }
  return value;
}

export function parseArgs(argv) {
  const opts = {
    dir: path.resolve(process.cwd(), 'build', 'web'),
    json: false,
    maxInitialKb: 1500,
    maxAssetKb: 250,
    failOn: 'none',
  };
  let positionalSet = false;
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === '--json') {
      opts.json = true;
    } else if (arg === '--max-initial-kb') {
      opts.maxInitialKb = parsePositiveNumberFlag(argv, i, '--max-initial-kb');
      i += 1;
    } else if (arg === '--max-asset-kb') {
      opts.maxAssetKb = parsePositiveNumberFlag(argv, i, '--max-asset-kb');
      i += 1;
    } else if (arg === '--fail-on') {
      const mode = argv[i + 1];
      if (!mode || !FAIL_ON_MODES.has(mode)) {
        throw new Error(`--fail-on must be one of: ${[...FAIL_ON_MODES].join(', ')}.`);
      }
      opts.failOn = mode;
      i += 1;
    } else if (arg === '--help' || arg === '-h') {
      printUsage();
      process.exit(0);
    } else if (arg.startsWith('-')) {
      throw new Error(`Unknown option: ${arg}`);
    } else if (!positionalSet) {
      opts.dir = path.resolve(process.cwd(), arg);
      positionalSet = true;
    } else {
      throw new Error(`Unexpected extra argument: ${arg}`);
    }
  }
  return opts;
}

export function resolveExitCode(status, failOn = 'none') {
  if (failOn === 'fail') return status === 'FAIL' ? 1 : 0;
  if (failOn === 'warn') return status === 'FAIL' || status === 'WARN' ? 1 : 0;
  return 0;
}

function printUsage() {
  console.log(
    'Usage: node analyze_web_bundle.mjs [buildWebDir] [--json] [--max-initial-kb 1500] [--max-asset-kb 250] [--fail-on none|fail|warn]'
  );
}

function walkFiles(rootDir, currentDir = rootDir, out = []) {
  for (const entry of fs.readdirSync(currentDir, { withFileTypes: true })) {
    const fullPath = path.join(currentDir, entry.name);
    if (entry.isDirectory()) {
      walkFiles(rootDir, fullPath, out);
    } else if (entry.isFile()) {
      const relPath = path.relative(rootDir, fullPath).replaceAll('\\', '/');
      out.push({ fullPath, relPath });
    }
  }
  return out;
}

function isRuntimeArtifact(relPath) {
  const lower = relPath.toLowerCase();
  const base = path.basename(lower);
  if (lower.startsWith('canvaskit/')) return true;
  return /^(skwasm(?:_heavy|_st)?|wimp|canvaskit)(?:\.[a-f0-9]+)?\.(wasm|js|mjs)(?:\.symbols)?$/.test(base);
}

function classifyFile(relPath) {
  const lower = relPath.toLowerCase();
  if (lower.endsWith('.map')) return 'sourcemaps';
  if (isRuntimeArtifact(lower)) return 'runtime';
  if (lower.endsWith('.wasm')) return 'wasm';
  if (lower.endsWith('.js') || lower.endsWith('.mjs')) return 'js';
  if (/\.(ttf|otf|woff|woff2)$/.test(lower)) return 'fonts';
  if (/\.(png|jpe?g|webp|avif|gif|svg|ico)$/.test(lower)) return 'images';
  if (lower.endsWith('.frag')) return 'shaders';
  if (/\.(html|json)$/.test(lower)) return 'manifest_html';
  return 'other';
}

function isInitialAppCore(relPath, hasWasmApp) {
  const base = path.basename(relPath).toLowerCase();
  if (base === 'index.html' || base === 'flutter_bootstrap.js') return true;
  if (/^main\.dart(?:\.[a-f0-9]+)?\.(wasm|mjs)$/.test(base)) return true;
  if (!hasWasmApp && /^main\.dart(?:\.[a-f0-9]+)?\.js$/.test(base)) return true;
  return false;
}

function isStartupFont(item) {
  return item.category === 'fonts' && !item.relPath.toLowerCase().startsWith('assets/fonts/fallback/');
}

function isStartupManifest(item) {
  const base = path.basename(item.relPath).toLowerCase();
  return /^assetmanifest(?:\.bin)?(?:\.[a-f0-9]+)?\.(?:bin|json)$/.test(base) ||
    /^fontmanifest(?:\.[a-f0-9]+)?\.json$/.test(base);
}

function isDeferredPart(relPath) {
  const base = path.basename(relPath).toLowerCase();
  return (
    /\.part\.(js|wasm|mjs)$/.test(base) ||
    /_\d+\.part\./.test(base) ||
    /^main\.dart_module\d+(?:\.[a-f0-9]+)?\.wasm(?:\.map)?$/.test(base)
  );
}

function isWasmDeferredChunk(relPath) {
  const base = path.basename(relPath).toLowerCase();
  return /^main\.dart_module\d+(?:\.[a-f0-9]+)?\.wasm$/.test(base);
}

function isJsDeferredChunk(relPath) {
  const base = path.basename(relPath).toLowerCase();
  return /\.part\.js$/.test(base) || /_\d+\.part\.js$/.test(base);
}

function isLazyFlutterLicenseAsset(relPath) {
  const lower = relPath.toLowerCase();
  return lower === 'assets/notices' || lower.startsWith('assets/notices.');
}

function measureFile(file) {
  const buf = fs.readFileSync(file.fullPath);
  const gzipBytes = zlib.gzipSync(buf, { level: 9 }).length;
  const brotliBytes = zlib.brotliCompressSync(buf, {
    params: { [zlib.constants.BROTLI_PARAM_QUALITY]: 6 },
  }).length;
  return {
    relPath: file.relPath,
    category: classifyFile(file.relPath),
    rawBytes: buf.length,
    gzipBytes,
    brotliBytes,
    isDeferred: isDeferredPart(file.relPath),
  };
}

export function extractBalancedObject(source, prefixPattern) {
  const match = prefixPattern.exec(source);
  if (!match) return null;
  const openIdx = source.indexOf('{', match.index);
  if (openIdx === -1) return null;

  let depth = 0;
  let quote = null;
  let escaped = false;
  for (let i = openIdx; i < source.length; i += 1) {
    const ch = source[i];
    if (quote) {
      if (escaped) escaped = false;
      else if (ch === '\\') escaped = true;
      else if (ch === quote) quote = null;
      continue;
    }
    if (ch === '"' || ch === "'") quote = ch;
    else if (ch === '{') depth += 1;
    else if (ch === '}') {
      depth -= 1;
      if (depth === 0) return source.slice(openIdx, i + 1);
    }
  }
  return null;
}

function isLocalCanvasKitBaseUrl(rawUrl) {
  if (typeof rawUrl !== 'string') return false;
  const trimmed = rawUrl.trim();
  if (!trimmed) return false;
  return !/^(?:https?:)?\/\//i.test(trimmed);
}

function stripJsComments(source) {
  let out = '';
  let quote = null;
  let escaped = false;
  for (let i = 0; i < source.length; i += 1) {
    const ch = source[i];
    const next = source[i + 1];
    if (quote) {
      out += ch;
      if (escaped) escaped = false;
      else if (ch === '\\') escaped = true;
      else if (ch === quote) quote = null;
      continue;
    }
    if (ch === '/' && next === '/') {
      while (i < source.length && source[i] !== '\n') i += 1;
      out += '\n';
      continue;
    }
    if (ch === '/' && next === '*') {
      i += 2;
      while (i < source.length && !(source[i] === '*' && source[i + 1] === '/')) i += 1;
      i += 1;
      continue;
    }
    if (ch === '"' || ch === "'") quote = ch;
    out += ch;
  }
  return out;
}

function hasLocalCanvasKitSetting(sourceText) {
  if (!sourceText) return false;
  const clean = stripJsComments(sourceText);
  if (/["']?useLocalCanvasKit["']?\s*:\s*true\b/.test(clean)) return true;
  const baseUrlRe = /["']?canvasKitBaseUrl["']?\s*:\s*(['"])([^'"]*)\1/g;
  for (const match of clean.matchAll(baseUrlRe)) {
    if (isLocalCanvasKitBaseUrl(match[2])) return true;
  }
  return false;
}

export function inspectBootstrapConfig(dir, strippedHtml = '') {
  const inlineScripts = [...strippedHtml.matchAll(/<script\b[^>]*>([\s\S]*?)<\/script>/gi)]
    .map((m) => m[1])
    .join('\n');
  if (hasLocalCanvasKitSetting(inlineScripts)) return true;
  const bootstrapPath = path.join(dir, 'flutter_bootstrap.js');
  if (!fs.existsSync(bootstrapPath)) return false;

  const bootstrap = fs.readFileSync(bootstrapPath, 'utf8');
  const buildConfigText = extractBalancedObject(bootstrap, /_flutter\.buildConfig\s*=\s*\{/);
  if (buildConfigText) {
    try {
      const parsed = JSON.parse(buildConfigText);
      if (parsed?.useLocalCanvasKit === true || isLocalCanvasKitBaseUrl(parsed?.canvasKitBaseUrl)) {
        return true;
      }
    } catch {
      // Fallback to comment-stripped text match when buildConfig is non-JSON JS
      if (hasLocalCanvasKitSetting(buildConfigText)) return true;
    }
  }

  const loaderArgs = extractBalancedObject(bootstrap, /_flutter\.loader\.load\s*\(\s*\{/);
  return hasLocalCanvasKitSetting(loaderArgs);
}

function auditHtml(dir) {
  const indexPath = path.join(dir, 'index.html');
  if (!fs.existsSync(indexPath)) {
    return {
      exists: false,
      usesLocalCanvasKitFlag: inspectBootstrapConfig(dir),
      issues: ['Missing index.html in build output.'],
      infos: [],
    };
  }

  const rawHtml = fs.readFileSync(indexPath, 'utf8');
  const html = rawHtml.replace(/<!--[\s\S]*?-->/g, '');
  const issues = [];
  const infos = [];
  const viewportMatch = html.match(/<meta\s+[^>]*name=["']viewport["'][^>]*>/i);
  const commentedViewport = /<meta\s+[^>]*name=["']viewport["'][^>]*>/i.test(rawHtml);

  if (!viewportMatch) {
    issues.push(
      commentedViewport
        ? 'Viewport <meta name="viewport"> is commented out in index.html (Flutter 3.50 template default); uncomment it with width=device-width, initial-scale=1.0, viewport-fit=cover.'
        : 'Missing active <meta name="viewport"> tag for mobile scaling.'
    );
  } else {
    const tag = viewportMatch[0];
    if (!/width=device-width/i.test(tag)) {
      issues.push('Viewport meta tag lacks width=device-width.');
    }
    if (!/viewport-fit\s*=\s*cover/i.test(tag)) {
      infos.push('index.html: Viewport meta lacks viewport-fit=cover (SafeArea/cutout padding stays browser-cropped).');
    }
  }

  if (/FlutterLoader\.loadEntrypoint/i.test(html)) {
    issues.push('Uses deprecated FlutterLoader.loadEntrypoint; migrate to flutter_bootstrap.js.');
  }

  return {
    exists: true,
    hasViewportMeta: Boolean(viewportMatch),
    hasCommentedViewportMeta: !viewportMatch && commentedViewport,
    hasViewportFitCover: /viewport-fit\s*=\s*cover/i.test(viewportMatch?.[0] ?? ''),
    hasInteractiveWidget: /interactive-widget=/i.test(viewportMatch?.[0] ?? ''),
    usesLocalCanvasKitFlag: inspectBootstrapConfig(dir, html),
    issues,
    infos,
  };
}

function kb(bytes) {
  return Number((bytes / 1024).toFixed(1));
}

function sumTotals(files) {
  return files.reduce(
    (acc, f) => ({
      rawBytes: acc.rawBytes + f.rawBytes,
      gzipBytes: acc.gzipBytes + f.gzipBytes,
      brotliBytes: acc.brotliBytes + f.brotliBytes,
    }),
    { rawBytes: 0, gzipBytes: 0, brotliBytes: 0 }
  );
}

function buildCategoryMap(measured) {
  const byCategory = {};
  for (const item of measured) {
    if (!byCategory[item.category]) {
      byCategory[item.category] = { count: 0, rawBytes: 0, gzipBytes: 0, brotliBytes: 0 };
    }
    byCategory[item.category].count += 1;
    byCategory[item.category].rawBytes += item.rawBytes;
    byCategory[item.category].gzipBytes += item.gzipBytes;
    byCategory[item.category].brotliBytes += item.brotliBytes;
  }
  return byCategory;
}

function collectPayloadAndRuntimeFindings(findings, ctx) {
  const { opts, appCoreTotals, startupFontsTotals, initialStartupTotals, usesLocalRuntime, runtimeVariants } = ctx;
  const initialBrotliKb = kb(appCoreTotals.brotliBytes);
  const startupBrotliKb = kb(initialStartupTotals.brotliBytes);

  if (initialBrotliKb > opts.maxInitialKb * 2) {
    findings.push({
      severity: 'FAIL',
      message: `Initial app core payload is ${initialBrotliKb} KB (brotli), exceeding 2x mobile budget (${opts.maxInitialKb} KB).`,
    });
  } else if (initialBrotliKb > opts.maxInitialKb) {
    findings.push({
      severity: 'WARN',
      message: `Initial app core payload is ${initialBrotliKb} KB (brotli), above target mobile budget (${opts.maxInitialKb} KB).`,
    });
  }

  if (startupBrotliKb > initialBrotliKb) {
    if (startupBrotliKb > opts.maxInitialKb * 2 && initialBrotliKb <= opts.maxInitialKb * 2) {
      findings.push({
        severity: 'FAIL',
        message: `Initial startup payload including fonts/manifests is ${startupBrotliKb} KB (brotli) (app core: ${initialBrotliKb} KB, fonts: ${kb(startupFontsTotals.brotliBytes)} KB), exceeding 2x mobile budget (${opts.maxInitialKb} KB).`,
      });
    } else if (startupBrotliKb > opts.maxInitialKb && initialBrotliKb <= opts.maxInitialKb) {
      findings.push({
        severity: 'WARN',
        message: `Initial startup payload including fonts/manifests is ${startupBrotliKb} KB (brotli) (app core: ${initialBrotliKb} KB, fonts: ${kb(startupFontsTotals.brotliBytes)} KB), above target mobile budget (${opts.maxInitialKb} KB).`,
      });
    }
  }

  if (!usesLocalRuntime) {
    findings.push({
      severity: 'INFO',
      message:
        'Renderer binaries (skwasm.wasm / canvaskit.wasm) are loaded from gstatic.com CDN (--web-resources-cdn default) and excluded from local build/web size; expect ~1.2-2.5 MB extra brotli transfer on cold browser cache.',
    });
    return;
  }
  const skwasmFiles = runtimeVariants.filter((f) =>
    /^skwasm(?:\.[a-f0-9]+)?\.(wasm|js|mjs)$/i.test(path.basename(f.relPath))
  );
  const skwasmBrKb = kb(sumTotals(skwasmFiles).brotliBytes);
  findings.push({
    severity: 'INFO',
    message: `Self-hosted renderer runtime detected (--no-web-resources-cdn): skwasm primary runtime adds ${skwasmBrKb} KB brotli on cold cache (iOS Safari fallback loads canvaskit.wasm).`,
  });
}

function collectBudgetFindings(ctx) {
  const {
    opts,
    hasWasmApp,
    jsDeferredChunks,
    wasmDeferredChunks,
    oversizedAssets,
    uncompressedLargeFonts,
    lazyLicenseAssets,
    sourceMaps,
    byCategory,
    hasContentHash,
    deferredFiles,
    htmlAudit,
  } = ctx;
  const findings = [];

  if (!hasWasmApp) {
    findings.push({
      severity: 'WARN',
      message: 'No main.dart*.wasm artifact detected; app runs on dart2js instead of Skwasm (--wasm).',
    });
  }
  if (hasWasmApp && jsDeferredChunks.length > 0 && wasmDeferredChunks.length === 0) {
    findings.push({
      severity: 'WARN',
      message: `Found ${jsDeferredChunks.length} dart2js deferred chunk(s) (*.part.js) without Wasm deferred modules (main.dart_module*.wasm). Pass "--enable-wasm-deferred-loading" (when not using "--web-content-hash") to split main.dart.wasm.`,
    });
  }

  collectPayloadAndRuntimeFindings(findings, ctx);

  for (const asset of oversizedAssets) {
    const severity = kb(asset.rawBytes) > opts.maxAssetKb * 2 ? 'FAIL' : 'WARN';
    findings.push({
      severity,
      message: `Oversized ${asset.category} asset "${asset.relPath}" (${kb(asset.rawBytes)} KB raw / ${kb(asset.brotliBytes)} KB br).`,
    });
  }
  for (const font of uncompressedLargeFonts) {
    findings.push({
      severity: 'INFO',
      message: `Font "${font.relPath}" (${kb(font.rawBytes)} KB raw) uses TTF/OTF; convert custom web fonts to subsetted .woff2 (and verify --tree-shake-icons for icon fonts) to cut mobile 4G download time.`,
    });
  }
  for (const notice of lazyLicenseAssets) {
    if (kb(notice.rawBytes) > opts.maxAssetKb) {
      findings.push({
        severity: 'INFO',
        message: `Lazy Flutter license bundle "${notice.relPath}" is ${kb(notice.rawBytes)} KB raw (${kb(notice.brotliBytes)} KB br); excluded from initial asset budget (loaded only on showLicensePage).`,
      });
    }
  }
  if (sourceMaps.length > 0) {
    findings.push({
      severity: 'INFO',
      message: `Found ${sourceMaps.length} sourcemap file(s) (${kb(byCategory.sourcemaps.rawBytes)} KB raw); verify they are excluded from public prod CDN if unwanted.`,
    });
  }
  if (!hasContentHash && deferredFiles.length === 0) {
    findings.push({
      severity: 'INFO',
      message:
        'No --web-content-hash manifest or deferred chunks detected; ensure CDN sets Cache-Control revalidation on unhashed main.dart.* or build with --web-content-hash.',
    });
  }
  for (const issue of htmlAudit.issues) {
    findings.push({ severity: 'WARN', message: `index.html: ${issue}` });
  }
  for (const info of htmlAudit.infos || []) {
    findings.push({ severity: 'INFO', message: info });
  }
  return findings;
}

export function evaluateBundle(dir, opts) {
  if (!fs.existsSync(dir)) {
    throw new Error(`Build directory not found: ${dir}`);
  }
  const rawFiles = walkFiles(dir).filter((f) => !f.relPath.startsWith('.last_build_id'));
  const measured = rawFiles.map(measureFile);
  const byCategory = buildCategoryMap(measured);

  const hasWasmApp = measured.some(
    (f) => f.category === 'wasm' && /^main\.dart(?:\.[a-f0-9]+)?\.wasm$/i.test(path.basename(f.relPath))
  );
  const hasJsFallback = measured.some(
    (f) => f.category === 'js' && /^main\.dart(?:\.[a-f0-9]+)?\.js$/i.test(path.basename(f.relPath))
  );
  const hasContentHash = measured.some(
    (f) =>
      path.basename(f.relPath) === 'precache_manifest.json' ||
      /^main\.dart\.[a-f0-9]+\.(wasm|js|mjs)$/i.test(path.basename(f.relPath))
  );

  const deferredFiles = measured.filter((f) => f.isDeferred);
  const wasmDeferredChunks = measured.filter((f) => isWasmDeferredChunk(f.relPath));
  const jsDeferredChunks = measured.filter((f) => isJsDeferredChunk(f.relPath));
  const sourceMaps = measured.filter((f) => f.category === 'sourcemaps');

  const appCoreFiles = measured.filter(
    (f) => f.category !== 'sourcemaps' && !f.isDeferred && isInitialAppCore(f.relPath, hasWasmApp)
  );
  const startupFontFiles = measured.filter((f) => !f.isDeferred && isStartupFont(f));
  const startupManifestFiles = measured.filter((f) => !f.isDeferred && isStartupManifest(f));

  const appCoreTotals = sumTotals(appCoreFiles);
  const startupFontsTotals = sumTotals(startupFontFiles);
  const startupManifestsTotals = sumTotals(startupManifestFiles);
  const initialStartupTotals = sumTotals([
    ...appCoreFiles,
    ...startupFontFiles,
    ...startupManifestFiles,
  ]);
  const initialCoreTotals = appCoreTotals;

  const runtimeVariants = measured
    .filter((f) => f.category === 'runtime' && /\.(wasm|js|mjs)$/i.test(f.relPath))
    .sort((a, b) => b.brotliBytes - a.brotliBytes);
  const bundledRuntimeTotals = sumTotals(runtimeVariants);
  const lazyLicenseAssets = measured.filter((f) => isLazyFlutterLicenseAsset(f.relPath));

  const oversizedAssets = measured
    .filter((f) => ['images', 'fonts', 'other', 'shaders'].includes(f.category))
    .filter((f) => !isLazyFlutterLicenseAsset(f.relPath))
    .filter((f) => kb(f.rawBytes) > opts.maxAssetKb)
    .sort((a, b) => b.rawBytes - a.rawBytes);
  const uncompressedLargeFonts = measured
    .filter((f) => f.category === 'fonts' && /\.(ttf|otf)$/i.test(f.relPath))
    .filter((f) => !f.relPath.toLowerCase().startsWith('assets/fonts/fallback/'))
    .filter((f) => kb(f.rawBytes) > 100)
    .sort((a, b) => b.rawBytes - a.rawBytes);
  const largestFiles = [...measured]
    .filter((f) => f.category !== 'sourcemaps')
    .sort((a, b) => b.brotliBytes - a.brotliBytes)
    .slice(0, 10);

  const htmlAudit = auditHtml(dir);
  const usesLocalRuntime = htmlAudit.usesLocalCanvasKitFlag === true;
  const findings = collectBudgetFindings({
    opts,
    hasWasmApp,
    jsDeferredChunks,
    wasmDeferredChunks,
    appCoreTotals,
    startupFontsTotals,
    initialStartupTotals,
    usesLocalRuntime,
    runtimeVariants,
    oversizedAssets,
    uncompressedLargeFonts,
    lazyLicenseAssets,
    sourceMaps,
    byCategory,
    hasContentHash,
    deferredFiles,
    htmlAudit,
  });

  const status = findings.some((f) => f.severity === 'FAIL')
    ? 'FAIL'
    : findings.some((f) => f.severity === 'WARN')
      ? 'WARN'
      : 'PASS';

  return {
    dir,
    status,
    wasmReady: hasWasmApp,
    hasJsFallback,
    hasContentHash,
    usesLocalRuntime,
    deferredChunkCount: deferredFiles.length,
    wasmDeferredChunkCount: wasmDeferredChunks.length,
    jsDeferredChunkCount: jsDeferredChunks.length,
    appCoreTotals,
    initialCoreTotals,
    startupFontsTotals,
    startupManifestsTotals,
    initialStartupTotals,
    bundledRuntimeTotals,
    runtimeVariants,
    byCategory,
    htmlAudit,
    largestFiles,
    findings,
  };
}

export function formatMarkdown(report) {
  const lines = [
    `# Mobile Web Bundle Analysis (${report.status})`,
    '',
    `- **Build Directory:** \`${report.dir}\``,
    `- **Wasm Target (\`--wasm\`):** ${report.wasmReady ? 'Yes (`main.dart*.wasm`)' : 'No (JS only)'} | **JS Fallback:** ${report.hasJsFallback ? 'Yes' : 'No'} | **Content Hash:** ${report.hasContentHash ? 'Yes' : 'No'}`,
    `- **Deferred Chunks:** ${report.deferredChunkCount} total (Wasm modules: ${report.wasmDeferredChunkCount}, JS parts: ${report.jsDeferredChunkCount})`,
    `- **Initial App Core Payload:** ${kb(report.appCoreTotals.rawBytes)} KB raw | ${kb(report.appCoreTotals.gzipBytes)} KB gzip | **${kb(report.appCoreTotals.brotliBytes)} KB brotli**`,
    `- **Initial Startup Payload (Core + Fonts + Manifests):** ${kb(report.initialStartupTotals.rawBytes)} KB raw | ${kb(report.initialStartupTotals.gzipBytes)} KB gzip | **${kb(report.initialStartupTotals.brotliBytes)} KB brotli** (fonts: ${kb(report.startupFontsTotals.brotliBytes)} KB br)`,
    `- **Renderer Runtime Delivery:** ${report.usesLocalRuntime ? `Self-hosted (${kb(report.bundledRuntimeTotals.brotliBytes)} KB brotli across all variants)` : 'CDN (`gstatic.com`, not inside `build/web`)'}`,
    '',
    '## Size Breakdown by Category',
    '| Category | Files | Raw (KB) | Gzip (KB) | Brotli (KB) |',
    '| :--- | ---: | ---: | ---: | ---: |',
  ];

  for (const [cat, stats] of Object.entries(report.byCategory)) {
    lines.push(
      `| ${cat} | ${stats.count} | ${kb(stats.rawBytes)} | ${kb(stats.gzipBytes)} | ${kb(stats.brotliBytes)} |`
    );
  }

  lines.push('', '## Largest Non-Sourcemap Artifacts', '| File | Category | Raw (KB) | Brotli (KB) |', '| :--- | :--- | ---: | ---: |');
  for (const f of report.largestFiles) {
    lines.push(`| \`${f.relPath}\` | ${f.category} | ${kb(f.rawBytes)} | ${kb(f.brotliBytes)} |`);
  }

  lines.push('', '## Findings');
  if (report.findings.length === 0) {
    lines.push('- No mobile bundle budget issues detected.');
  } else {
    for (const f of report.findings) {
      lines.push(`- **[${f.severity}]** ${f.message}`);
    }
  }
  return lines.join('\n');
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
    const report = evaluateBundle(opts.dir, opts);
    console.log(opts.json ? JSON.stringify(report, null, 2) : formatMarkdown(report));
    process.exit(resolveExitCode(report.status, opts.failOn));
  } catch (err) {
    console.error(`Error: ${err.message}`);
    process.exit(1);
  }
}
