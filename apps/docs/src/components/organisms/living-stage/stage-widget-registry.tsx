import type { ReactNode } from 'react';
import { dispatchStageEvent } from '@/lib/stage-bridge';
import { SIMULATOR_REGISTRY } from '../simulators/simulator-registry';
import { ButtonMock } from '../simulators/preview-mocks/button-mock';
import { SliderMock } from '../simulators/preview-mocks/slider-mock';
import { SwitchMock } from '../simulators/preview-mocks/switch-mock';
import { components } from '@/lib/components-data';

export interface WidgetDef {
  render: () => ReactNode;
  dartCode: string;
}

function dartSnippet(slug: string): string {
  return components.find((c) => c.slug === slug)?.dartSnippet ?? '';
}

/**
 * The stage renders the same mocks as the catalog. These three entries only
 * add a bridge event on interaction; every other component falls back to
 * SIMULATOR_REGISTRY in getWidgetDef. Dart code always comes from
 * components-data so the stage and the catalog show the same snippet.
 */
export const STAGE_WIDGET_REGISTRY: Record<string, WidgetDef> = {
  button: {
    render: () => (
      <ButtonMock
        onPress={() =>
          dispatchStageEvent({
            type: 'justui-interact',
            component: 'button',
            action: 'press',
          })
        }
      />
    ),
    dartCode: dartSnippet('button'),
  },
  switch: {
    render: () => (
      <SwitchMock
        onToggle={() =>
          dispatchStageEvent({
            type: 'justui-interact',
            component: 'switch',
            action: 'toggle',
          })
        }
      />
    ),
    dartCode: dartSnippet('switch'),
  },
  slider: {
    render: () => (
      <SliderMock
        onValueChange={() =>
          dispatchStageEvent({
            type: 'justui-interact',
            component: 'slider',
            action: 'slide',
          })
        }
      />
    ),
    dartCode: dartSnippet('slider'),
  },
};

export function getWidgetDef(name: string): WidgetDef | undefined {
  if (STAGE_WIDGET_REGISTRY[name]) {
    return STAGE_WIDGET_REGISTRY[name];
  }

  const MockComp = SIMULATOR_REGISTRY[name];
  if (MockComp) {
    const meta = components.find((c) => c.slug === name);
    const pascal = name
      .split('-')
      .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
      .join('');
    return {
      render: () => <MockComp />,
      dartCode: meta?.dartSnippet ?? `Just${pascal}()`,
    };
  }

  return undefined;
}
