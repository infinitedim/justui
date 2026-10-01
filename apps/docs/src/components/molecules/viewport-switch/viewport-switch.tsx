'use client';

import { Monitor, Smartphone, Tablet } from 'lucide-react';
import { cn } from '@/lib/cn';
import type {
  ViewportSwitchLabels,
  ViewportSwitchProps,
  Viewport,
} from './viewport-switch.types';
import type { SVGAttributes } from 'react';

const viewportIcons: {
  id: Viewport;
  icon: React.ComponentType<SVGAttributes<SVGSVGElement>>;
}[] = [
  { id: 'mobile', icon: Smartphone },
  { id: 'tablet', icon: Tablet },
  { id: 'desktop', icon: Monitor },
];

const defaultLabels: ViewportSwitchLabels = {
  group: 'Preview width',
  mobile: 'Mobile viewport',
  tablet: 'Tablet viewport',
  desktop: 'Desktop viewport',
};

/**
 * Viewport size switcher molecule for responsive previews.
 * Client Component for toggle interaction.
 */
export function ViewportSwitch({
  value,
  onChange,
  labels = defaultLabels,
  className,
}: ViewportSwitchProps) {
  return (
    <div
      role="radiogroup"
      aria-label={labels.group}
      className={cn(
        'inline-flex items-center rounded-(--just-radius-md) p-0.5',
        'border-border bg-card border-(length:--just-border-width)',
        className
      )}
    >
      {viewportIcons.map(({ id, icon: IconComp }) => (
        <button
          key={id}
          type="button"
          role="radio"
          aria-checked={value === id}
          aria-label={labels[id]}
          onClick={() => onChange(id)}
          className={cn(
            'inline-flex h-7 w-7 items-center justify-center rounded-(--just-radius-sm) transition-colors',
            value === id
              ? 'bg-accent text-accent-foreground shadow-solid'
              : 'text-muted hover:text-foreground'
          )}
        >
          <IconComp width={14} height={14} aria-hidden="true" />
        </button>
      ))}
    </div>
  );
}
