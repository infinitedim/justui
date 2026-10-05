/**
 * Pure TypeScript OKLCH conversion engine and gamut mapping.
 * Matches packages/tokens/lib/src/colors/oklch_engine.dart.
 * Strictly 100% ASCII.
 */

function sRgbToLinear(c: number): number {
  return c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
}

function linearToSRgb(c: number): number {
  return c <= 0.0031308 ? 12.92 * c : 1.055 * Math.pow(c, 1.0 / 2.4) - 0.055;
}

function findMinPositiveCubicRoot(
  a: number,
  b: number,
  c: number,
  d: number,
  currentMin: number
): number {
  let minC = currentMin;

  if (Math.abs(a) < 1e-12) {
    if (Math.abs(b) < 1e-12) {
      if (Math.abs(c) > 1e-12) {
        const r = -d / c;
        if (r > 1e-6 && r < minC) minC = r;
      }
    } else {
      const disc = c * c - 4.0 * b * d;
      if (disc >= 0.0) {
        const s = Math.sqrt(disc);
        const r1 = (-c + s) / (2.0 * b);
        const r2 = (-c - s) / (2.0 * b);
        if (r1 > 1e-6 && r1 < minC) minC = r1;
        if (r2 > 1e-6 && r2 < minC) minC = r2;
      }
    }
    return minC;
  }

  const pa = b / a;
  const qa = c / a;
  const ra = d / a;

  const p = qa - (pa * pa) / 3.0;
  const q = (2.0 * pa * pa * pa) / 27.0 - (pa * qa) / 3.0 + ra;
  const p3 = p / 3.0;
  const q2 = q / 2.0;
  const delta = q2 * q2 + p3 * p3 * p3;
  const shift = pa / 3.0;

  if (delta > 1e-14) {
    const sDelta = Math.sqrt(delta);
    const u = Math.cbrt(-q2 + sDelta);
    const v = Math.cbrt(-q2 - sDelta);
    const r = u + v - shift;
    if (r > 1e-6 && r < minC) minC = r;
  } else {
    const phi = -p3 <= 0.0 ? 0.0 : Math.sqrt(-p3);
    if (phi > 1e-14) {
      const ratio = Math.max(-1.0, Math.min(1.0, -q2 / (phi * phi * phi)));
      const theta = Math.acos(ratio) / 3.0;
      const r1 = 2.0 * phi * Math.cos(theta) - shift;
      const r2 = 2.0 * phi * Math.cos(theta - (2.0 * Math.PI) / 3.0) - shift;
      const r3 = 2.0 * phi * Math.cos(theta - (4.0 * Math.PI) / 3.0) - shift;
      if (r1 > 1e-6 && r1 < minC) minC = r1;
      if (r2 > 1e-6 && r2 < minC) minC = r2;
      if (r3 > 1e-6 && r3 < minC) minC = r3;
    } else {
      const r = -shift;
      if (r > 1e-6 && r < minC) minC = r;
    }
  }
  return minC;
}

export function maxChromaForLH(lightness: number, hue: number): number {
  if (lightness <= 1e-6 || lightness >= 1.0 - 1e-6) return 0.0;

  const hRad = hue * (Math.PI / 180.0);
  const a = Math.cos(hRad);
  const b = Math.sin(hRad);

  const kl = 0.3963377774 * a + 0.2158037573 * b;
  const km = -0.1055613458 * a - 0.0638541728 * b;
  const ks = -0.0894841775 * a - 1.291485548 * b;

  const lVal = lightness;
  const l2 = lVal * lVal;
  const l3 = l2 * lVal;

  let minC = 0.4;

  const channels = [
    { wl: 4.0767416621, wm: -3.3077115913, ws: 0.2309699292 },
    { wl: -1.2684380046, wm: 2.6097574011, ws: -0.3413193965 },
    { wl: -0.0041960863, wm: -0.7034186147, ws: 1.707614701 },
  ];

  for (const { wl, wm, ws } of channels) {
    const c3 = wl * kl * kl * kl + wm * km * km * km + ws * ks * ks * ks;
    const c2 =
      3.0 * (wl * kl * kl * lVal + wm * km * km * lVal + ws * ks * ks * lVal);
    const c1 = 3.0 * (wl * kl * l2 + wm * km * l2 + ws * ks * l2);
    const c0 = (wl + wm + ws) * l3;

    minC = findMinPositiveCubicRoot(c3, c2, c1, c0, minC);
    minC = findMinPositiveCubicRoot(c3, c2, c1, c0 - 1.0, minC);
  }

  return Math.max(0.0, minC);
}

export function rgbToOklch(
  r: number,
  g: number,
  b: number
): { l: number; c: number; h: number } {
  const rL = sRgbToLinear(r);
  const gL = sRgbToLinear(g);
  const bL = sRgbToLinear(b);

  const l = 0.4122214708 * rL + 0.5363325363 * gL + 0.0514459529 * bL;
  const m = 0.2119034982 * rL + 0.6806995451 * gL + 0.1073969566 * bL;
  const s = 0.0883024619 * rL + 0.2817188376 * gL + 0.6299787005 * bL;

  const lCap = Math.cbrt(l);
  const mCap = Math.cbrt(m);
  const sCap = Math.cbrt(s);

  const L = 0.2104542553 * lCap + 0.793617785 * mCap - 0.0040720468 * sCap;
  const labA = 1.9779984951 * lCap - 2.428592205 * mCap + 0.4505937099 * sCap;
  const labB = 0.0259040371 * lCap + 0.7827717662 * mCap - 0.8086757973 * sCap;

  const C = Math.sqrt(labA * labA + labB * labB);
  let H = 0.0;
  if (C >= 1e-6) {
    H = Math.atan2(labB, labA) * (180.0 / Math.PI);
    if (H < 0) H += 360.0;
  }

  return {
    l: Math.max(0.0, Math.min(1.0, L)),
    c: C < 1e-6 ? 0.0 : C,
    h: H,
  };
}

export function oklchToLinearRgb(
  L: number,
  C: number,
  H: number
): [number, number, number] {
  const hRad = H * (Math.PI / 180.0);
  const labA = C * Math.cos(hRad);
  const labB = C * Math.sin(hRad);

  const lCap = L + 0.3963377774 * labA + 0.2158037573 * labB;
  const mCap = L - 0.1055613458 * labA - 0.0638541728 * labB;
  const sCap = L - 0.0894841775 * labA - 1.291485548 * labB;

  const l = lCap * lCap * lCap;
  const m = mCap * mCap * mCap;
  const s = sCap * sCap * sCap;

  return [
    4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
    -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
    -0.0041960863 * l - 0.7034186147 * m + 1.707614701 * s,
  ];
}

export function oklchToRgb(
  L: number,
  C: number,
  H: number
): [number, number, number] {
  if (C < 1e-6) {
    const [rL, gL, bL] = oklchToLinearRgb(L, 0.0, H);
    return [
      Math.max(0.0, Math.min(1.0, linearToSRgb(rL))),
      Math.max(0.0, Math.min(1.0, linearToSRgb(gL))),
      Math.max(0.0, Math.min(1.0, linearToSRgb(bL))),
    ];
  }

  const [rL, gL, bL] = oklchToLinearRgb(L, C, H);
  const e = 1e-4;
  if (
    rL >= -e &&
    rL <= 1.0 + e &&
    gL >= -e &&
    gL <= 1.0 + e &&
    bL >= -e &&
    bL <= 1.0 + e
  ) {
    return [
      Math.max(0.0, Math.min(1.0, linearToSRgb(rL))),
      Math.max(0.0, Math.min(1.0, linearToSRgb(gL))),
      Math.max(0.0, Math.min(1.0, linearToSRgb(bL))),
    ];
  }

  const maxC = maxChromaForLH(L, H);
  const [rF, gF, bF] = oklchToLinearRgb(L, Math.min(C, maxC), H);
  return [
    Math.max(0.0, Math.min(1.0, linearToSRgb(rF))),
    Math.max(0.0, Math.min(1.0, linearToSRgb(gF))),
    Math.max(0.0, Math.min(1.0, linearToSRgb(bF))),
  ];
}
