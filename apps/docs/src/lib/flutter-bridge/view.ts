import { err, ok, type Result } from '@/lib/result';
import { callMethod, loadEngine } from './engine';
import { keepEmptyViewOutOfTabOrder } from './tab-stop';
import {
  ViewConfigSchema,
  ViewPatchSchema,
  type ViewConfig,
  type ViewPatch,
} from './schema';

const READY_TIMEOUT_MS = 15_000;

/** One mounted Flutter view. */
export interface LiveView {
  /** Sends a validated patch; resolves once Flutter painted it. */
  update: (patch: ViewPatch) => Promise<void>;
  /** Removes the view from its host element. */
  remove: () => void;
}

function hasUpdate(value: unknown): boolean {
  return (
    typeof value === 'object' &&
    value !== null &&
    typeof Reflect.get(value, 'update') === 'function'
  );
}

/** Wraps the Dart controller (`@JSExport` with one `update` method). */
function liveView(controller: unknown, remove: () => void): LiveView {
  return {
    update: async (patch) => {
      const parsed = ViewPatchSchema.safeParse(patch);
      if (!parsed.success) return;
      await callMethod(controller, 'update', [parsed.data]);
    },
    remove,
  };
}

/**
 * Adds a Flutter view to [host] for [config]. Resolves once Dart has
 * painted the first frame and handed over its controller, so the caller
 * can swap the fallback for the live view without a blank frame.
 */
export async function mountView(
  host: HTMLElement,
  config: ViewConfig
): Promise<Result<LiveView>> {
  const parsed = ViewConfigSchema.safeParse(config);
  if (!parsed.success) return err('invalid view config');
  const engine = await loadEngine();
  if (!engine.ok) return engine;
  const app = engine.value;
  return new Promise((resolve) => {
    let viewId: number | null = null;
    let unwatch = () => {};
    const remove = () => {
      unwatch();
      if (viewId !== null) app.removeView(viewId);
      viewId = null;
    };
    const timer = window.setTimeout(() => {
      remove();
      resolve(err('the view did not report ready'));
    }, READY_TIMEOUT_MS);
    viewId = app.addView({
      hostElement: host,
      initialData: {
        config: parsed.data,
        onReady: (controller: unknown) => {
          window.clearTimeout(timer);
          if (hasUpdate(controller)) {
            unwatch = keepEmptyViewOutOfTabOrder(host);
            resolve(ok(liveView(controller, remove)));
          } else {
            remove();
            resolve(err('the view sent no controller'));
          }
        },
      },
    });
  });
}
