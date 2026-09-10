'use client';

import { Monitor, Smartphone, Tablet } from 'lucide-react';
import { cn } from '@/lib/cn';
import type { ViewportSwitchProps, Viewport } from './viewport-switch.types';
import type { SVGAttributes } from 'react';

const viewportConfig: {
  id: Viewport;
  icon: React.ComponentType<SVGAttributes<SVGSVGElement>>;
  label: string;
}[] = [
  { id: 'mobile', icon: Smartphone, label: 'Mobile viewport' },
  { id: 'tablet', icon: Tablet, label: 'Tablet viewport' },
  { id: 'desktop', icon: Monitor, label: 'Desktop viewport' },
];

/**
 * Viewport size switcher molecule for responsive previews.
 * Client Component for toggle interaction.
 */
export function ViewportSwitch({
  value,
  onChange,
  className,
}: ViewportSwitchProps) {
  return (
    <div
      role="radiogroup"
      aria-label="Viewport size"
      className={cn(
        'inline-flex items-center rounded-full p-0.5',
        'border-border bg-card border-(length:--just-border-width)',
        className
      )}
    >
      {viewportConfig.map(({ id, icon: IconComp, label }) => (
        <button
          key={id}
          type="button"
          role="radio"
          aria-checked={value === id}
          aria-label={label}
          onClick={() => onChange(id)}
          className={cn(
            'inline-flex h-7 w-7 items-center justify-center rounded-full transition-colors',
            value === id
              ? 'bg-accent text-foreground shadow-solid'
              : 'text-muted hover:text-foreground'
          )}
        >
          <IconComp width={14} height={14} aria-hidden="true" />
        </button>
      ))}
    </div>
  );
}
