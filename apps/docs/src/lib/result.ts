/**
 * Outcome of an operation that can fail for expected reasons (bad input,
 * missing data, a failed load). Throw only for bugs (`docs-web.md`).
 */
export type Result<T, E = string> =
  { ok: true; value: T } | { ok: false; error: E };

/** A successful [Result]. */
export function ok<T>(value: T): Result<T, never> {
  return { ok: true, value };
}

/** A failed [Result]. */
export function err<E>(error: E): Result<never, E> {
  return { ok: false, error };
}
