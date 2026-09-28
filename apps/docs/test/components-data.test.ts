import { readFileSync } from 'node:fs';
import path from 'node:path';
import { describe, expect, it } from 'vitest';
import { components } from '@/lib/components-data';
import { REGISTRY_COMPONENT_NAMES } from '@/components/organisms/interactive-terminal/levenshtein';

interface RegistryFile {
  components: Array<{
    name: string;
    internal?: boolean;
    category?: string;
  }>;
}

function loadRegistryPublicComponents() {
  const registryPath = path.resolve(__dirname, '../../../registry/index.json');
  const raw = JSON.parse(readFileSync(registryPath, 'utf-8')) as RegistryFile;
  return raw.components.filter(
    (c) => !c.internal && c.category !== 'tokens' && c.category !== 'core'
  );
}

describe('components-data single source of truth', () => {
  it('has exactly one entry per public registry component, no more, no less', () => {
    const registrySlugs = new Set(
      loadRegistryPublicComponents().map((c) => c.name)
    );
    const docsSlugs = new Set(components.map((c) => c.slug));

    expect(docsSlugs).toEqual(registrySlugs);
  });

  it('takes its category from the registry, not a hand-typed duplicate', () => {
    const registryBySlug = new Map(
      loadRegistryPublicComponents().map((c) => [
        c.name,
        c.category === 'forms' ? 'form' : c.category,
      ])
    );

    for (const component of components) {
      expect(
        component.category,
        `category for "${component.slug}" must match the registry`
      ).toBe(registryBySlug.get(component.slug));
    }
  });

  it('matches the known-correct categories for icon-button and table specifically', () => {
    // These two were historically wrong in the hand-maintained data:
    // icon-button depends on the public `button` component so it belongs
    // under "composite" (like avatar-group/date-picker), while table only
    // depends on internal `_shared_*` helpers so it stays "primitive".
    const bySlug = new Map(components.map((c) => [c.slug, c.category]));
    expect(bySlug.get('icon-button')).toBe('composite');
    expect(bySlug.get('table')).toBe('primitive');
  });

  it('REGISTRY_COMPONENT_NAMES matches the same component slugs', () => {
    const docsSlugs = new Set(components.map((c) => c.slug));
    expect(new Set(REGISTRY_COMPONENT_NAMES)).toEqual(docsSlugs);
  });
});
