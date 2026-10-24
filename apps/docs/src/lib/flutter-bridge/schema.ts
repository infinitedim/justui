import * as z from 'zod/mini';
import { locales } from '@/lib/i18n';
import { PRESETS } from '@/lib/presets';
import { FLUTTER_SCENES } from './scenes';

/**
 * What the page sends to a Flutter view. The Dart side
 * (`apps/showcase/lib/bridge/view_config.dart`) checks the same limits
 * again: every value is validated on both sides of the JS boundary.
 */

/** Code point ranges never sent to Dart: controls, bidi and zero-width. */
const UNSAFE_RANGES: ReadonlyArray<readonly [number, number]> = [
  [0x00, 0x1f],
  [0x7f, 0x9f],
  [0x200b, 0x200d],
  [0x202a, 0x202e],
  [0x2066, 0x2069],
  [0xfeff, 0xfeff],
];

/** True when [text] holds no control, bidi or zero-width character. */
export function isSafeText(text: string): boolean {
  for (const char of text) {
    const code = char.codePointAt(0) ?? 0;
    if (UNSAFE_RANGES.some(([from, to]) => code >= from && code <= to)) {
      return false;
    }
  }
  return true;
}

const MAX_ENTRIES = 96;

const Key = z.string().check(z.regex(/^[a-zA-Z][a-zA-Z0-9]{0,39}$/));

const Text = z
  .string()
  .check(z.minLength(1), z.maxLength(200), z.refine(isSafeText));

/** Playground labels and other props: short printable ASCII. */
const PropText = z
  .string()
  .check(z.minLength(1), z.maxLength(40), z.regex(/^[\x20-\x7e]+$/));

const PropNumber = z.number().check(z.refine(Number.isFinite));

const Strings = z
  .record(
    Key,
    z.union([Text, z.array(Text).check(z.minLength(1), z.maxLength(8))])
  )
  .check(z.refine((value) => Object.keys(value).length <= MAX_ENTRIES));

const Props = z
  .record(Key, z.union([z.boolean(), PropNumber, PropText]))
  .check(z.refine((value) => Object.keys(value).length <= MAX_ENTRIES));

export const ViewTheme = z.enum(['light', 'dark']);

/** The `config` part of a view's `initialData`. */
export const ViewConfigSchema = z.object({
  scene: z.enum(FLUTTER_SCENES),
  preset: z.enum(PRESETS),
  theme: ViewTheme,
  locale: z.enum(locales),
  strings: Strings,
  props: z.optional(Props),
});

/** A change sent through the view controller; the scene never changes. */
export const ViewPatchSchema = z.partial(
  z.omit(ViewConfigSchema, { scene: true })
);

export type ViewConfig = z.infer<typeof ViewConfigSchema>;
export type ViewPatch = z.infer<typeof ViewPatchSchema>;
