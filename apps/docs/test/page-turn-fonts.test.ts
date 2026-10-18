import { describe, expect, it, vi } from 'vitest';
import {
  coversBasicLatin,
  fontUrl,
  inlineFaces,
  selectFace,
  type FaceRule,
} from '@/lib/page-turn/fonts';
import { commitTheme } from '@/lib/use-theme-switch';

const ORIGIN = 'https://justui.vercel.app';
const SHEET = `${ORIGIN}/_next/static/chunks/main.css`;

function rule(overrides: Partial<FaceRule> = {}): FaceRule {
  const src = 'url("../media/jakarta.woff2") format("woff2")';
  return {
    cssText: `@font-face { font-family: "Plus Jakarta Sans"; src: ${src}; }`,
    family: '"Plus Jakarta Sans"',
    weight: '400',
    style: 'normal',
    range: 'U+0-FF, U+131',
    src,
    ...overrides,
  };
}

describe('page-turn font inlining', () => {
  it('keeps only faces that cover basic Latin', () => {
    expect(coversBasicLatin('U+0-FF, U+131')).toBe(true);
    expect(coversBasicLatin('U+0000-00FF')).toBe(true);
    expect(coversBasicLatin('U+00??')).toBe(true);
    expect(coversBasicLatin('')).toBe(true);
    expect(coversBasicLatin('U+460-52F, U+1C80-1C8A')).toBe(false);
  });

  it('reads the url of a src descriptor', () => {
    expect(fontUrl('url("../media/a.woff2") format("woff2")')).toBe(
      '../media/a.woff2'
    );
    expect(fontUrl('url(/a.woff2)')).toBe('/a.woff2');
    expect(fontUrl('local("Arial")')).toBeNull();
  });

  it('resolves same-origin files and drops the rest', () => {
    const loaded = new Set(['Plus Jakarta Sans|400|normal']);
    expect(selectFace(rule(), SHEET, ORIGIN, loaded)).toEqual({
      cssText: `@font-face { font-family: "Plus Jakarta Sans"; src: url("${ORIGIN}/_next/static/media/jakarta.woff2") format("woff2"); }`,
      url: `${ORIGIN}/_next/static/media/jakarta.woff2`,
    });
    const google = rule({ src: 'url(https://fonts.gstatic.com/x.woff2)' });
    expect(selectFace(google, SHEET, ORIGIN, loaded)).toBeNull();
    expect(
      selectFace(rule({ weight: '700' }), SHEET, ORIGIN, loaded)
    ).toBeNull();
    expect(
      selectFace(rule({ range: 'U+370-3FF' }), SHEET, ORIGIN, new Set())
    ).toBeNull();
  });

  it('inlines each file once as a data URL', async () => {
    const load = vi.fn((url: string) =>
      Promise.resolve(`data:font/woff2;base64,${url.length}`)
    );
    const url = `${ORIGIN}/a.woff2`;
    const css = await inlineFaces(
      [
        { cssText: `@font-face{src:url("${url}")}`, url },
        { cssText: `@font-face{font-weight:700;src:url("${url}")}`, url },
      ],
      load
    );
    expect(load).toHaveBeenCalledTimes(1);
    expect(css).not.toContain(url);
    expect(css.match(/data:font\/woff2/g)).toHaveLength(2);
  });
});

describe('commitTheme', () => {
  it('resolves once the html class shows the new theme', async () => {
    const html = document.documentElement;
    html.classList.remove('dark');
    const apply = vi.fn(() => {
      queueMicrotask(() => html.classList.add('dark'));
    });
    await commitTheme(apply, true);
    expect(apply).toHaveBeenCalledTimes(1);
    expect(html.classList.contains('dark')).toBe(true);
    html.classList.remove('dark');
  });
});
