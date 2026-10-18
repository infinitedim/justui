/**
 * The raster is an SVG image, which cannot load fonts by URL. This reads
 * the page's own @font-face rules (next/font, self-hosted), keeps the
 * Latin faces the page has actually loaded, and inlines each same-origin
 * woff2 as a data URL. No third-party request is made.
 */

/** True when a unicode-range (or its absence) covers basic Latin. */
export function coversBasicLatin(range: string): boolean {
  if (range.trim() === '') return true;
  return range.split(',').some((part) => {
    const match = /U\+([0-9a-f?]+)(?:-([0-9a-f]+))?/i.exec(part.trim());
    if (!match?.[1]) return false;
    const start = parseInt(match[1].replaceAll('?', '0'), 16);
    const end = parseInt(match[2] ?? match[1].replaceAll('?', 'f'), 16);
    return start <= 0x41 && end >= 0x7a;
  });
}

/** First `url(...)` in a `src` descriptor, unquoted. */
export function fontUrl(src: string): string | null {
  return /url\(\s*["']?([^"')]+)["']?\s*\)/.exec(src)?.[1] ?? null;
}

function unquote(family: string): string {
  return family.replaceAll(/["']/g, '').trim();
}

/** `family|weight|style` for every face the document has loaded. */
function loadedFaces(): Set<string> {
  const keys = new Set<string>();
  if (!('fonts' in document)) return keys;
  document.fonts.forEach((face) => {
    if (face.status === 'loaded') {
      keys.add(`${unquote(face.family)}|${face.weight}|${face.style}`);
    }
  });
  return keys;
}

function toDataUrl(url: string): Promise<string> {
  return fetch(url)
    .then((response) => {
      if (!response.ok) throw new Error(`font ${response.status}`);
      return response.blob();
    })
    .then(
      (blob) =>
        new Promise<string>((resolve, reject) => {
          const reader = new FileReader();
          reader.onload = () =>
            typeof reader.result === 'string'
              ? resolve(reader.result)
              : reject(new Error('font read'));
          reader.onerror = () => reject(new Error('font read'));
          reader.readAsDataURL(blob);
        })
    );
}

export interface FaceRule {
  cssText: string;
  family: string;
  weight: string;
  style: string;
  range: string;
  src: string;
}

export interface Face {
  cssText: string;
  url: string;
}

/**
 * Keeps a face the page has loaded (when that is known), that covers
 * basic Latin and whose file is same-origin; its URL made absolute.
 */
export function selectFace(
  rule: FaceRule,
  base: string,
  origin: string,
  loaded: ReadonlySet<string>
): Face | null {
  const key = `${unquote(rule.family)}|${rule.weight || 'normal'}|${rule.style || 'normal'}`;
  if (loaded.size > 0 && !loaded.has(key)) return null;
  if (!coversBasicLatin(rule.range)) return null;
  const raw = fontUrl(rule.src);
  if (!raw) return null;
  const url = new URL(raw, base);
  if (url.origin !== origin) return null;
  return { cssText: rule.cssText.replace(raw, url.href), url: url.href };
}

/** Inlines each face's file as a data URL; one fetch per distinct file. */
export function inlineFaces(
  faces: readonly Face[],
  load: (url: string) => Promise<string> = toDataUrl
): Promise<string> {
  const files = new Map<string, Promise<string>>();
  return Promise.all(
    faces.map((face) => {
      const data = files.get(face.url) ?? load(face.url);
      files.set(face.url, data);
      return data.then((dataUrl) => face.cssText.replace(face.url, dataUrl));
    })
  ).then((blocks) => blocks.join('\n'));
}

/** The @font-face rules of the page's readable stylesheets. */
function pageFaces(): Face[] {
  const loaded = loadedFaces();
  const faces: Face[] = [];
  for (const sheet of Array.from(document.styleSheets)) {
    let rules: CSSRuleList;
    try {
      rules = sheet.cssRules;
    } catch {
      continue; // Cross-origin sheet: its rules are not readable.
    }
    for (const rule of Array.from(rules)) {
      if (!(rule instanceof CSSFontFaceRule)) continue;
      const read = (name: string) => rule.style.getPropertyValue(name);
      const face = selectFace(
        {
          cssText: rule.cssText,
          family: read('font-family'),
          weight: read('font-weight'),
          style: read('font-style'),
          range: read('unicode-range'),
          src: read('src'),
        },
        sheet.href ?? window.location.href,
        window.location.origin,
        loaded
      );
      if (face) faces.push(face);
    }
  }
  return faces;
}

let cached: Promise<string> | null = null;

/** @font-face CSS with every face inlined; cached after the first call. */
export function inlinedFontCss(): Promise<string> {
  if (cached) return cached;
  cached = inlineFaces(pageFaces()).catch((error: unknown) => {
    cached = null;
    throw error;
  });
  return cached;
}
