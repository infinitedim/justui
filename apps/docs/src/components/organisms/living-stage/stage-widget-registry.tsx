import type { ReactNode } from 'react';
import { SIMULATOR_REGISTRY } from '../simulators/simulator-registry';
import { components } from '@/lib/components-data';

export interface WidgetDef {
  render: () => ReactNode;
  dartCode: string;
}

function toPascalCase(slug: string): string {
  return slug
    .split('-')
    .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
    .join('');
}

/**
 * The stage renders exactly the same mock and Dart snippet as the component
 * catalog, so `justui add switch` shows the switch you'd see on
 * /components, not a look-alike.
 */
export function getWidgetDef(name: string): WidgetDef | undefined {
  const MockComp = SIMULATOR_REGISTRY[name];
  if (!MockComp) return undefined;

  const meta = components.find((c) => c.slug === name);
  return {
    render: () => <MockComp />,
    dartCode: meta?.dartSnippet ?? `Just${toPascalCase(name)}()`,
  };
}
