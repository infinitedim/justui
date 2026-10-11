import { describe, it, expectTypeOf } from 'vitest';
import type { Route } from 'next';
import {
  GENERATED_COMPONENTS,
  GENERATED_REGISTRY,
  CLI_VERSION,
  REGISTRY_VERSION,
  REGISTRY_PRESETS,
  CLI_DEFAULTS,
  type GeneratedComponentMeta,
  type GeneratedComponentCategory,
  type GeneratedRegistryEntry,
} from '@/lib/components.generated';
import {
  locales,
  defaultLocale,
  isLocale,
  localeStaticParams,
  localizedHref,
  switchLocalePath,
  type Locale,
} from '@/lib/i18n';

describe('Type Contract Checks (expectTypeOf)', () => {
  describe('components.generated.ts type contracts', () => {
    it('matches expected meta structure and categories', () => {
      expectTypeOf(GENERATED_COMPONENTS).toEqualTypeOf<
        ReadonlyArray<GeneratedComponentMeta>
      >();
      expectTypeOf(GENERATED_COMPONENTS[0]).toEqualTypeOf<
        GeneratedComponentMeta | undefined
      >();

      expectTypeOf<GeneratedComponentCategory>()
        .extract<'primitive'>()
        .toBeString();
      expectTypeOf<GeneratedComponentCategory>()
        .extract<'layout'>()
        .toBeString();
      expectTypeOf<GeneratedComponentCategory>().extract<'form'>().toBeString();

      expectTypeOf<GeneratedComponentMeta>().toHaveProperty('name');
      expectTypeOf<GeneratedComponentMeta>().toHaveProperty('slug');
      expectTypeOf<GeneratedComponentMeta>().toHaveProperty('category');

      expectTypeOf(CLI_VERSION).toBeString();
      expectTypeOf(REGISTRY_VERSION).toBeString();
      expectTypeOf(REGISTRY_PRESETS).toEqualTypeOf<ReadonlyArray<string>>();
      expectTypeOf(CLI_DEFAULTS.registryUrl).toBeString();

      expectTypeOf(GENERATED_REGISTRY).toEqualTypeOf<
        ReadonlyArray<GeneratedRegistryEntry>
      >();
      expectTypeOf(GENERATED_REGISTRY[0]).toEqualTypeOf<
        GeneratedRegistryEntry | undefined
      >();
    });
  });

  describe('i18n helpers type contracts', () => {
    it('verifies Locale union and routing types', () => {
      expectTypeOf<Locale>().toEqualTypeOf<'en' | 'id'>();
      expectTypeOf(defaultLocale).toEqualTypeOf<Locale>();
      expectTypeOf(locales).toEqualTypeOf<readonly ['en', 'id']>();

      expectTypeOf(isLocale).toBeCallableWith('en');
      expectTypeOf(isLocale('en')).toBeBoolean();

      expectTypeOf(localeStaticParams).returns.toEqualTypeOf<
        Array<{ lang: Locale }>
      >();

      expectTypeOf(localizedHref).toBeCallableWith('en', '/docs');
      expectTypeOf(localizedHref('en', '/docs')).toEqualTypeOf<Route>();

      expectTypeOf(switchLocalePath).toBeCallableWith('/en/docs', 'id');
      expectTypeOf(switchLocalePath('/en/docs', 'id')).toEqualTypeOf<Route>();
    });
  });
});
