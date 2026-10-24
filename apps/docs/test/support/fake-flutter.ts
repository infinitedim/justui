import { vi } from 'vitest';

/** A stand-in for Flutter's loader, engine and multi-view app. */
export interface FakeFlutter {
  app: {
    addView: ReturnType<typeof vi.fn>;
    removeView: ReturnType<typeof vi.fn>;
  };
  controller: { update: ReturnType<typeof vi.fn> };
  engineConfig: Array<unknown>;
  initialData: Array<unknown>;
}

/**
 * Installs `globalThis._flutter`, makes the bootstrap <script> "load", and
 * makes this browser look like Blink. Views report ready on the next tick
 * unless [ready] is false.
 */
export function installFakeFlutter({ ready = true } = {}): FakeFlutter {
  const fake: FakeFlutter = {
    app: { addView: vi.fn(), removeView: vi.fn() },
    controller: { update: vi.fn(() => Promise.resolve()) },
    engineConfig: [],
    initialData: [],
  };
  let nextId = 1;
  fake.app.addView.mockImplementation(
    (options: { initialData: { onReady: (c: unknown) => void } }) => {
      fake.initialData.push(options.initialData);
      if (ready) setTimeout(() => options.initialData.onReady(fake.controller));
      return nextId++;
    }
  );
  Reflect.set(globalThis, '_flutter', {
    loader: {
      load: vi.fn(
        async (options: {
          onEntrypointLoaded: (initializer: unknown) => Promise<void>;
        }) => {
          await options.onEntrypointLoaded({
            initializeEngine: (config: unknown) => {
              fake.engineConfig.push(config);
              return Promise.resolve({
                runApp: () => Promise.resolve(fake.app),
              });
            },
          });
        }
      ),
    },
  });
  vi.spyOn(navigator, 'vendor', 'get').mockReturnValue('Google Inc.');
  vi.spyOn(document.head, 'append').mockImplementation((...nodes) => {
    for (const node of nodes) {
      if (node instanceof HTMLScriptElement) {
        setTimeout(() => node.dispatchEvent(new Event('load')));
      }
    }
  });
  return fake;
}

/** Removes what [installFakeFlutter] installed. */
export function removeFakeFlutter(): void {
  Reflect.deleteProperty(globalThis, '_flutter');
  vi.restoreAllMocks();
}
