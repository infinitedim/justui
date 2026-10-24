import { err, ok, type Result } from '@/lib/result';
import { canRunFlutter } from './support';

/** Where `bun run flutter:build` puts the bridge bundle. */
export const FLUTTER_BASE = '/flutter/';

const START_TIMEOUT_MS = 30_000;

/**
 * Loader config. Every URL is absolute so the bundle resolves the same on
 * any docs page; no Google CDN (the CSP allows only same-origin scripts and
 * fonts). Skwasm runs multi-threaded when the page is cross-origin isolated
 * (production COOP/COEP) and single-threaded otherwise.
 */
const CONFIG = {
  renderer: 'skwasm',
  assetBase: FLUTTER_BASE,
  entrypointBaseUrl: FLUTTER_BASE,
  canvasKitBaseUrl: `${FLUTTER_BASE}canvaskit/`,
  fontFallbackBaseUrl: `${FLUTTER_BASE}fonts/`,
  suppressMultithreadingWarning: true,
} as const;

/** The running multi-view app, as `engine.runApp()` returns it. */
export interface FlutterApp {
  addView: (options: {
    hostElement: HTMLElement;
    initialData: unknown;
  }) => number;
  removeView: (viewId: number) => unknown;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null;
}

/** Calls `target[name](...args)` when it is a function; else undefined. */
export function callMethod(
  target: unknown,
  name: string,
  args: unknown[]
): unknown {
  if (!isRecord(target)) return undefined;
  const method: unknown = target[name];
  return typeof method === 'function'
    ? Reflect.apply(method, target, args)
    : undefined;
}

function isFlutterApp(value: unknown): value is FlutterApp {
  return (
    isRecord(value) &&
    typeof value.addView === 'function' &&
    typeof value.removeView === 'function'
  );
}

function injectBootstrap(): Promise<Result<void>> {
  return new Promise((resolve) => {
    const script = document.createElement('script');
    script.src = `${FLUTTER_BASE}flutter_bootstrap.js`;
    script.async = true;
    script.addEventListener('load', () => resolve(ok(undefined)));
    script.addEventListener('error', () =>
      resolve(err('flutter_bootstrap.js failed to load'))
    );
    document.head.append(script);
  });
}

/** Starts the engine through Flutter's loader; resolves with the app. */
function runLoader(): Promise<Result<FlutterApp>> {
  return new Promise((resolve) => {
    const timer = window.setTimeout(
      () => resolve(err('Flutter did not start in time')),
      START_TIMEOUT_MS
    );
    const settle = (result: Result<FlutterApp>) => {
      window.clearTimeout(timer);
      resolve(result);
    };
    // flutter_bootstrap.js defines `_flutter` (Flutter's own global).
    const flutterGlobal: unknown = Reflect.get(globalThis, '_flutter');
    const loader = isRecord(flutterGlobal) ? flutterGlobal.loader : undefined;
    const started = callMethod(loader, 'load', [
      {
        config: CONFIG,
        onEntrypointLoaded: async (initializer: unknown) => {
          try {
            const engine: unknown = await callMethod(
              initializer,
              'initializeEngine',
              [{ ...CONFIG, multiViewEnabled: true }]
            );
            const app: unknown = await callMethod(engine, 'runApp', []);
            settle(isFlutterApp(app) ? ok(app) : err('no multi-view app'));
          } catch {
            // Engine start failures (wasm, workers, CSP) keep the fallbacks.
            settle(err('the Flutter engine failed to start'));
          }
        },
      },
    ]);
    if (!(started instanceof Promise)) settle(err('no Flutter loader'));
    else started.catch(() => settle(err('the Flutter loader failed')));
  });
}

let engine: Promise<Result<FlutterApp>> | null = null;

/**
 * The bridge engine, started once per page load. A failure is kept: the
 * page stays on its React fallbacks instead of retrying.
 */
export function loadEngine(): Promise<Result<FlutterApp>> {
  engine ??= (async () => {
    if (!canRunFlutter()) return err('this browser cannot run the bundle');
    const script = await injectBootstrap();
    return script.ok ? runLoader() : script;
  })();
  return engine;
}
