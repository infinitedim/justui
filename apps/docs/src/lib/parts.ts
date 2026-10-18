import {
  CLI_DEFAULTS,
  GENERATED_COMPONENTS,
  GENERATED_REGISTRY,
} from '@/lib/components.generated';

/** Public part slugs in registry alphabetical order (`_shared_*` excluded). */
export const PART_SLUGS: readonly string[] = GENERATED_COMPONENTS.map(
  (component) => component.slug
);

/** Number of public parts on every runner. */
export const PART_COUNT: number = PART_SLUGS.length;

/**
 * Preset-independent part code: the 1-based alphabetical position,
 * zero-padded to two digits (`button` -> `07`). Unknown slugs return `--`.
 */
export function partCode(slug: string): string {
  const index = PART_SLUGS.indexOf(slug);
  return index < 0 ? '--' : String(index + 1).padStart(2, '0');
}

/** Dart file the CLI writes as the part's main widget (`just_date_picker.dart`). */
export function partMainFile(slug: string): string {
  return `just_${slug.replaceAll('-', '_')}.dart`;
}

/** Folder the CLI installs a part into, from the CLI defaults. */
export function partDir(slug: string): string {
  return `${CLI_DEFAULTS.componentsDir}/${slug}`;
}

/**
 * Files `justui add <slug>` writes into the part folder: the main widget
 * first, then the rest in alphabetical order.
 */
export function partFiles(slug: string): readonly string[] {
  const entry = GENERATED_REGISTRY.find((item) => item.name === slug);
  if (!entry) return [];
  const main = partMainFile(slug);
  const rest = entry.files.filter((file) => file !== main).toSorted();
  return entry.files.includes(main) ? [main, ...rest] : rest;
}

/** Shared registry dependencies (`_shared_*`) the CLI installs with a part. */
export function partSharedDeps(slug: string): readonly string[] {
  const entry = GENERATED_REGISTRY.find((item) => item.name === slug);
  return (entry?.registryDependencies ?? []).filter((dep) =>
    dep.startsWith('_shared_')
  );
}
