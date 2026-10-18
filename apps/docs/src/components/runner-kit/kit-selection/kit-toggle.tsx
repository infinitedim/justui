'use client';

// Client leaf: aria-pressed needs state; native inputs cover the rest.
import { useState } from 'react';
import { Bold } from 'lucide-react';
import { cn } from '@/lib/cn';
import type { KitToggleProps } from './kit-selection.types';

/** Icon toggle. Pressed: selection fill (default) or ink fill (neo). */
export function KitToggle({
  label,
  defaultPressed = true,
  className,
}: KitToggleProps) {
  const [pressed, setPressed] = useState(defaultPressed);
  return (
    <button
      type="button"
      aria-label={label}
      aria-pressed={pressed}
      onClick={() => setPressed(!pressed)}
      className={cn(
        'text-ip-text-primary flex size-10 cursor-pointer items-center justify-center rounded-(--ip-radius-control) border-(length:--ip-line) border-(--ip-part-control-border)',
        pressed
          ? 'bg-(--ip-part-selected-item-bg) text-(--ip-part-selected-item-fg)'
          : 'neo:bg-ip-surface bg-transparent shadow-(--ip-shadow-primary)',
        className
      )}
    >
      <Bold size={16} strokeWidth={2.5} aria-hidden="true" />
    </button>
  );
}
