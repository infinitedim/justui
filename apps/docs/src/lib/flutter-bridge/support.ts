/**
 * Which browsers load Flutter at all. The bundle ships only the Wasm
 * (skwasm) build, which Flutter allows on Blink when dart2wasm Wasm probes
 * pass; every other browser keeps the React fallback and never fetches
 * `/flutter/*`. The checks mirror Flutter 3.50's own loader
 * (`flutter_js/src/supports_dart2wasm.js` and `browser_environment.js`).
 */

/** Minimal module validating final WasmGC support. */
const WASM_GC_PROBE = new Uint8Array([
  0, 97, 115, 109, 1, 0, 0, 0, 1, 5, 1, 95, 1, 120, 0,
]);

/** Minimal module validating Wasm SIMD support. */
const WASM_SIMD_PROBE = new Uint8Array([
  0, 97, 115, 109, 1, 0, 0, 0, 1, 5, 1, 96, 0, 1, 123, 3, 2, 1, 0, 10, 10, 1, 8,
  0, 65, 0, 253, 15, 253, 98, 11,
]);

/**
 * Invalid signature probe for `wasm:js-string.cast`: compliant runtimes with
 * JS String Builtins support return false here when passed `{ builtins }`.
 */
const JS_STRING_BUILTINS_PROBE = new Uint8Array([
  0, 97, 115, 109, 1, 0, 0, 0, 1, 4, 1, 96, 0, 0, 2, 23, 1, 14, 119, 97, 115,
  109, 58, 106, 115, 45, 115, 116, 114, 105, 110, 103, 4, 99, 97, 115, 116, 0,
  0,
]);

/** Minimal module validating `try_table` exception-handling instructions. */
const TRY_TABLE_PROBE = new Uint8Array([
  0, 97, 115, 109, 1, 0, 0, 0, 1, 4, 1, 96, 0, 0, 3, 2, 1, 0, 10, 13, 1, 11, 0,
  2, 64, 31, 64, 1, 2, 0, 11, 11, 11,
]);

const JS_STRING_BUILTINS_OPTIONS: WebAssembly.WebAssemblyCompileOptions = {
  builtins: ['js-string'],
};

/** Blink (Chrome, Edge, other Chromium browsers), as Flutter detects it. */
export function isBlink(vendor: string, userAgent: string): boolean {
  return vendor === 'Google Inc.' || userAgent.includes('Edg/');
}

/** True when [validate] passes all 4 Flutter 3.50 dart2wasm Wasm probes. */
export function supportsDart2Wasm(
  validate: (
    bytes: Uint8Array<ArrayBuffer>,
    options?: WebAssembly.WebAssemblyCompileOptions
  ) => boolean
): boolean {
  try {
    return (
      validate(WASM_GC_PROBE) &&
      validate(WASM_SIMD_PROBE) &&
      !validate(JS_STRING_BUILTINS_PROBE, JS_STRING_BUILTINS_OPTIONS) &&
      validate(TRY_TABLE_PROBE)
    );
  } catch {
    // A runtime without WebAssembly.validate or builtins options cannot run the bundle.
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
    supportsDart2Wasm((bytes, options) => WebAssembly.validate(bytes, options))
  );
}
