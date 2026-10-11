/**
 * Pure TypeScript HSLuv conversion engine and boundary intersection.
 * Matches packages/tokens/lib/src/colors/hsluv_engine.dart.
 * Strictly 100% ASCII.
 */

function sRgbToLinear(c: number): number {
  return c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
}

function linearToSRgb(c: number): number {
  return c <= 0.0031308 ? 12.92 * c : 1.055 * Math.pow(c, 1.0 / 2.4) - 0.055;
}

const REF_X = 0.9504559270516717;
const REF_Y = 1.0;
const REF_Z = 1.0890577507598784;

const REF_U = (4.0 * REF_X) / (REF_X + 15.0 * REF_Y + 3.0 * REF_Z);
const REF_V = (9.0 * REF_Y) / (REF_X + 15.0 * REF_Y + 3.0 * REF_Z);

const KAPPA = 24389 / 27;
const EPSILON = 216 / 24389;

const MR0 = 0.41239079926595934;
const MR1 = 0.35758433938387796;
const MR2 = 0.18048078840183429;
const MG0 = 0.21263900587151036;
const MG1 = 0.715168678767756;
const MG2 = 0.07219231536073371;
const MB0 = 0.01933081871559185;
const MB1 = 0.11919477979462598;
const MB2 = 0.9505321522496606;

const MX0 = 3.240969941904521;
const MX1 = -1.537383177570093;
const MX2 = -0.498610760293003;
const MY0 = -0.96924363628087;
const MY1 = 1.87596750150772;
const MY2 = 0.041555057407175;
const MZ0 = 0.055630080164829;
const MZ1 = -0.204007460932413;
const MZ2 = 1.05722521677329;

function yToL(y: number): number {
  return y <= EPSILON ? y * KAPPA : 116.0 * Math.pow(y, 1.0 / 3.0) - 16.0;
}

function lToY(l: number): number {
  if (l <= 8.0) return l / KAPPA;
  const lNorm = (l + 16.0) / 116.0;
  return lNorm * lNorm * lNorm;
}

export function maxChromaForLH(l: number, h: number): number {
  if (l <= 1e-6 || l >= 100.0 - 1e-6) return 0.0;

  const hRad = h * (Math.PI / 180.0);
  const sinH = Math.sin(hRad);
  const cosH = Math.cos(hRad);

  const l16 = l + 16.0;
  const sub1 = (l16 * l16 * l16) / 1560896.0;
  const sub2 = sub1 > EPSILON ? sub1 : l / KAPPA;

  let minLength = Infinity;

  for (let c = 0; c < 3; c++) {
    const m1 = c === 0 ? MX0 : c === 1 ? MY0 : MZ0;
    const m2 = c === 0 ? MX1 : c === 1 ? MY1 : MZ1;
    const m3 = c === 0 ? MX2 : c === 1 ? MY2 : MZ2;

    for (let boundary = 0; boundary < 2; boundary++) {
      const bound = boundary;
      const top1 = (284517.0 * m1 - 94839.0 * m3) * sub2;
      const top2 =
        (838422.0 * m3 + 769860.0 * m2 + 731718.0 * m1) * l * sub2 -
        769860.0 * bound * l;
      const bottom = (632260.0 * m3 - 126452.0 * m2) * sub2 + 126452.0 * bound;

      const denom = bottom * sinH - top1 * cosH;
      if (Math.abs(denom) < 1e-12) continue;

      const length = top2 / denom;
      if (length >= 0.0 && length < minLength) {
        minLength = length;
      }
    }
  }

  return Number.isFinite(minLength) ? minLength : 0.0;
}

export function rgbToHsluv(
  r: number,
  g: number,
  b: number
): { h: number; s: number; l: number } {
  const rL = sRgbToLinear(r);
  const gL = sRgbToLinear(g);
  const bL = sRgbToLinear(b);

  const x = MR0 * rL + MR1 * gL + MR2 * bL;
  const y = MG0 * rL + MG1 * gL + MG2 * bL;
  const z = MB0 * rL + MB1 * gL + MB2 * bL;

  const l = yToL(y);
  if (l <= 1e-6) return { h: 0.0, s: 0.0, l: 0.0 };
  if (l >= 99.999999) return { h: 0.0, s: 0.0, l: 100.0 };

  const denom = x + 15.0 * y + 3.0 * z;
  const uPrime = denom < 1e-12 ? REF_U : (4.0 * x) / denom;
  const vPrime = denom < 1e-12 ? REF_V : (9.0 * y) / denom;

  const u = 13.0 * l * (uPrime - REF_U);
  const v = 13.0 * l * (vPrime - REF_V);

  const c = Math.sqrt(u * u + v * v);
  let h = 0.0;
  if (c >= 1e-6) {
    h = Math.atan2(v, u) * (180.0 / Math.PI);
    if (h < 0) h += 360.0;
  }

  const maxC = maxChromaForLH(l, h);
  const s = maxC < 1e-6 ? 0.0 : (c / maxC) * 100.0;

  return {
    h,
    s: Math.max(0.0, Math.min(100.0, s)),
    l: Math.max(0.0, Math.min(100.0, l)),
  };
}

export function hsluvToRgb(
  h: number,
  s: number,
  l: number
): [number, number, number] {
  if (l > 99.999999) return [1.0, 1.0, 1.0];
  if (l < 1e-6) return [0.0, 0.0, 0.0];

  const maxC = maxChromaForLH(l, h);
  const c = (maxC / 100.0) * s;

  const hRad = h * (Math.PI / 180.0);
  const u = c * Math.cos(hRad);
  const v = c * Math.sin(hRad);

  const uPrime = u / (13.0 * l) + REF_U;
  const vPrime = v / (13.0 * l) + REF_V;

  const y = lToY(l);
  const x = vPrime < 1e-12 ? 0.0 : (y * (9.0 * uPrime)) / (4.0 * vPrime);
  const z =
    vPrime < 1e-12
      ? 0.0
      : (y * (12.0 - 3.0 * uPrime - 20.0 * vPrime)) / (4.0 * vPrime);

  const rL = MX0 * x + MX1 * y + MX2 * z;
  const gL = MY0 * x + MY1 * y + MY2 * z;
  const bL = MZ0 * x + MZ1 * y + MZ2 * z;

  return [
    Math.max(0.0, Math.min(1.0, linearToSRgb(rL))),
    Math.max(0.0, Math.min(1.0, linearToSRgb(gL))),
    Math.max(0.0, Math.min(1.0, linearToSRgb(bL))),
  ];
}
