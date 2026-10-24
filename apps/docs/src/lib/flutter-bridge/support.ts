/**
 * Which browsers load Flutter at all. The bundle ships only the Wasm
 * (skwasm) build, which Flutter allows on Blink with WasmGC; every other
 * browser keeps the React fallback and never fetches `/flutter/*`. The
 * checks mirror Flutter's own loader (`flutter_js/src/browser_environment.js`).
 */

/** The smallest module that validates only with final WasmGC support. */
const WASM_GC_PROBE = new Uint8Array([
  0, 97, 115, 109, 1, 0, 0, 0, 1, 5, 1, 95, 1, 120, 0,
]);

/** Blink (Chrome, Edge, other Chromium browsers), as Flutter detects it. */
export function isBlink(vendor: string, userAgent: string): boolean {
  return vendor === 'Google Inc.' || userAgent.includes('Edg/');
}

/** True when [validate] accepts the WasmGC probe module. */
export function hasWasmGc(
  validate: (bytes: Uint8Array<ArrayBuffer>) => boolean
): boolean {
  try {
    return validate(WASM_GC_PROBE);
  } catch {
    // A browser without WebAssembly.validate cannot run the bundle either.
    return false;
  }
}

/** True when this browser can run the bridge bundle. */
export function canRunFlutter(): boolean {
  if (typeof window === 'undefined' || typeof WebAssembly !== 'object') {
    return false;
  }
  return (
    isBlink(navigator.vendor, navigator.userAgent) &&
    hasWasmGc((bytes) => WebAssembly.validate(bytes))
  );
}
