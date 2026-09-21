import type { ReactNode } from 'react';
import { Button } from '@/components/atoms/button';
import { Badge } from '@/components/atoms/badge';
import { Slider } from '@/components/atoms/slider';
import { ToggleChip } from '@/components/atoms/toggle-chip';
import { ProgressBar } from '@/components/atoms/progress-bar';
import { Separator } from '@/components/atoms/separator';
import { dispatchStageEvent } from '@/lib/stage-bridge';
import { SIMULATOR_REGISTRY } from '../simulators/simulator-registry';
import { components } from '@/lib/components-data';

export interface WidgetDef {
  render: () => ReactNode;
  dartCode: string;
}

export const STAGE_WIDGET_REGISTRY: Record<string, WidgetDef> = {
  button: {
    render: () => (
      <Button
        variant="primary"
        size="md"
        onClick={() =>
          dispatchStageEvent({
            type: 'justui-interact',
            component: 'button',
            action: 'press',
          })
        }
      >
        Press me
      </Button>
    ),
    dartCode: [
      'JustButton(',
      '  label: "Press me",',
      '  variant: JustButtonVariant.primary,',
      '  onPressed: () {},',
      ')',
    ].join('\n'),
  },
  switch: {
    render: () => (
      <ToggleChip
        active
        onClick={() =>
          dispatchStageEvent({
            type: 'justui-interact',
            component: 'switch',
            action: 'toggle',
          })
        }
      >
        Toggle
      </ToggleChip>
    ),
    dartCode: [
      'JustSwitch(',
      '  value: true,',
      '  onChanged: (v) {},',
      ')',
    ].join('\n'),
  },
  card: {
    render: () => (
      <div className="border-border bg-card shadow-solid rounded-(--just-radius-lg) border-(length:--just-border-width) p-4">
        <p className="text-foreground text-sm font-medium">JustCard</p>
        <p className="text-muted text-xs">
          Surface container with optional header
        </p>
      </div>
    ),
    dartCode: [
      'JustCard(',
      '  child: Column(',
      '    children: [',
      '      Text("JustCard"),',
      '      Text("Surface container"),',
      '    ],',
      '  ),',
      ')',
    ].join('\n'),
  },
  input: {
    render: () => (
      <div className="border-border bg-card rounded-(--just-radius-md) border-(length:--just-border-width) px-3 py-2 font-mono text-sm">
        <span className="text-muted">Enter text...</span>
      </div>
    ),
    dartCode: [
      'JustInput(',
      '  placeholder: "Enter text...",',
      '  onChanged: (v) {},',
      ')',
    ].join('\n'),
  },
  badge: {
    render: () => <Badge variant="accent">New</Badge>,
    dartCode: [
      'JustBadge(',
      '  label: "New",',
      '  variant: JustBadgeVariant.accent,',
      ')',
    ].join('\n'),
  },
  slider: {
    render: () => (
      <Slider
        min={0}
        max={100}
        value={60}
        label="Volume"
        onChange={() =>
          dispatchStageEvent({
            type: 'justui-interact',
            component: 'slider',
            action: 'slide',
          })
        }
      />
    ),
    dartCode: [
      'JustSlider(',
      '  value: 0.6,',
      '  onChanged: (v) {},',
      ')',
    ].join('\n'),
  },
  progress: {
    render: () => <ProgressBar value={65} max={100} label="Loading" />,
    dartCode: ['JustProgress(', '  value: 0.65,', ')'].join('\n'),
  },
  separator: {
    render: () => <Separator className="my-2" />,
    dartCode: 'JustSeparator()',
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
