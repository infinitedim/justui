import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { getKitDictionary } from '@/lib/kit-translations';
import {
  ViewConfigSchema,
  ViewPatchSchema,
  isSafeText,
  type ViewConfig,
} from '@/lib/flutter-bridge/schema';
import { hasWasmGc, isBlink } from '@/lib/flutter-bridge/support';
import { installFakeFlutter, removeFakeFlutter } from './support/fake-flutter';

const strings = Object.fromEntries(
  Object.entries(getKitDictionary('en')).map(([key, value]) => [
    key,
    typeof value === 'string' ? value : [...value],
  ])
);

const config: ViewConfig = {
  scene: 'button',
  preset: 'default',
  theme: 'light',
  locale: 'en',
  strings,
};

describe('schema', () => {
  it('accepts the kit dictionary as copy', () => {
    expect(ViewConfigSchema.safeParse(config).success).toBe(true);
    const id = { ...config, locale: 'id' };
    expect(ViewConfigSchema.safeParse(id).success).toBe(true);
  });

  it('rejects unknown scenes, presets, themes and locales', () => {
    for (const bad of [
      { scene: 'card' },
      { preset: 'material' },
      { theme: 'sepia' },
      { locale: 'fr' },
    ]) {
      expect(ViewConfigSchema.safeParse({ ...config, ...bad }).success).toBe(
        false
      );
    }
  });

  it('rejects control, bidi and zero-width characters', () => {
    for (const code of [0x0a, 0x7f, 0x200b, 0x202e, 0x2066, 0xfeff]) {
      const text = `a${String.fromCodePoint(code)}b`;
      expect(isSafeText(text)).toBe(false);
      const patch = { strings: { saveChanges: text } };
      expect(ViewPatchSchema.safeParse(patch).success).toBe(false);
    }
    expect(isSafeText('Simpan perubahan')).toBe(true);
  });

  it('limits props to booleans, finite numbers and short printable ASCII', () => {
    const ok = { props: { loading: true, size: 2, label: 'Pay now' } };
    expect(ViewPatchSchema.safeParse(ok).success).toBe(true);
    for (const props of [
      { label: 'x'.repeat(41) },
      { label: `caf${String.fromCodePoint(0xe9)}` },
      { size: Number.NaN },
      { 'bad key': true },
    ]) {
      expect(ViewPatchSchema.safeParse({ props }).success).toBe(false);
    }
  });

  it('never lets a patch change the scene', () => {
    const parsed = ViewPatchSchema.safeParse({ scene: 'card', theme: 'dark' });
    expect(parsed.success && 'scene' in parsed.data).toBe(false);
  });
});

describe('support', () => {
  it('detects Blink like the Flutter loader', () => {
    expect(isBlink('Google Inc.', 'Mozilla/5.0 Chrome/140')).toBe(true);
    expect(isBlink('', 'Mozilla/5.0 Edg/140')).toBe(true);
    expect(isBlink('Apple Computer, Inc.', 'Safari')).toBe(false);
    expect(isBlink('', 'Firefox/140')).toBe(false);
  });

  it('treats a throwing validator as no WasmGC', () => {
    expect(hasWasmGc(() => true)).toBe(true);
    expect(hasWasmGc(() => false)).toBe(false);
    expect(
      hasWasmGc(() => {
        throw new Error('no wasm');
      })
    ).toBe(false);
  });
});

describe('engine and views', () => {
  beforeEach(() => {
    vi.resetModules();
  });

  afterEach(() => {
    removeFakeFlutter();
  });

  it('starts one multi-view skwasm engine with same-origin URLs', async () => {
    const fake = installFakeFlutter();
    const { loadEngine } = await import('@/lib/flutter-bridge/engine');
    const [first, second] = await Promise.all([loadEngine(), loadEngine()]);
    expect(first.ok && second.ok).toBe(true);
    expect(fake.engineConfig).toEqual([
      expect.objectContaining({
        multiViewEnabled: true,
        renderer: 'skwasm',
        assetBase: '/flutter/',
        canvasKitBaseUrl: '/flutter/canvaskit/',
        fontFallbackBaseUrl: '/flutter/fonts/',
      }),
    ]);
  });

  it('fails without a loader and never retries', async () => {
    installFakeFlutter();
    Reflect.deleteProperty(globalThis, '_flutter');
    const { loadEngine } = await import('@/lib/flutter-bridge/engine');
    const result = await loadEngine();
    expect(result.ok).toBe(false);
    expect(await loadEngine()).toBe(result);
  });

  it('skips browsers that are not Blink', async () => {
    installFakeFlutter();
    vi.spyOn(navigator, 'vendor', 'get').mockReturnValue(
      'Apple Computer, Inc.'
    );
    const { loadEngine } = await import('@/lib/flutter-bridge/engine');
    expect((await loadEngine()).ok).toBe(false);
    expect(document.head.append).not.toHaveBeenCalled();
  });

  it('mounts a view and sends only validated patches', async () => {
    const fake = installFakeFlutter();
    const { mountView } = await import('@/lib/flutter-bridge/view');
    const host = document.createElement('div');
    const result = await mountView(host, config);
    expect(result.ok).toBe(true);
    if (!result.ok) return;
    expect(fake.initialData[0]).toMatchObject({ config });
    await result.value.update({ theme: 'dark' });
    expect(fake.controller.update).toHaveBeenCalledWith({ theme: 'dark' });
    await result.value.update({ strings: { saveChanges: 'a\nb' } });
    expect(fake.controller.update).toHaveBeenCalledTimes(1);
    result.value.remove();
    expect(fake.app.removeView).toHaveBeenCalledWith(1);
  });

  it('rejects an invalid config before loading anything', async () => {
    installFakeFlutter();
    const { mountView } = await import('@/lib/flutter-bridge/view');
    const bad = { ...config, locale: 'fr' } as unknown as ViewConfig;
    const result = await mountView(document.createElement('div'), bad);
    expect(result.ok).toBe(false);
    expect(document.head.append).not.toHaveBeenCalled();
  });

  it('removes a view whose controller is not a controller', async () => {
    const fake = installFakeFlutter({ ready: false });
    fake.app.addView.mockImplementation(
      (options: { initialData: { onReady: (c: unknown) => void } }) => {
        setTimeout(() => options.initialData.onReady({}));
        return 7;
      }
    );
    const { mountView } = await import('@/lib/flutter-bridge/view');
    const result = await mountView(document.createElement('div'), config);
    expect(result.ok).toBe(false);
    expect(fake.app.removeView).toHaveBeenCalledWith(7);
  });
});
