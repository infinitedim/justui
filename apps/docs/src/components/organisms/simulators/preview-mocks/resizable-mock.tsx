'use client';
/* eslint-disable jsx-a11y/no-noninteractive-tabindex, jsx-a11y/no-noninteractive-element-interactions -- focusable role="separator" is the WAI-ARIA window splitter pattern. */

import { useRef, useState, type KeyboardEvent, type PointerEvent } from 'react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { focusRing, surface } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

const MIN = 30;
const MAX = 70;
const STEP = 5;

const clamp = (value: number) => Math.min(MAX, Math.max(MIN, value));

export function ResizableMock() {
  const { crm } = useCatalogI18n();
  const [split, setSplit] = useState(45);
  const containerRef = useRef<HTMLDivElement>(null);
  const draggingRef = useRef(false);

  const onPointerDown = (event: PointerEvent<HTMLDivElement>) => {
    draggingRef.current = true;
    event.currentTarget.setPointerCapture(event.pointerId);
  };

  const onPointerMove = (event: PointerEvent<HTMLDivElement>) => {
    const container = containerRef.current;
    if (!draggingRef.current || !container) return;
    const rect = container.getBoundingClientRect();
    if (rect.width === 0) return;
    setSplit(
      clamp(Math.round(((event.clientX - rect.left) / rect.width) * 100))
    );
  };

  const onPointerUp = (event: PointerEvent<HTMLDivElement>) => {
    draggingRef.current = false;
    event.currentTarget.releasePointerCapture(event.pointerId);
  };

  const onKeyDown = (event: KeyboardEvent<HTMLDivElement>) => {
    const delta =
      event.key === 'ArrowLeft' ? -STEP : event.key === 'ArrowRight' ? STEP : 0;
    if (delta === 0) return;
    event.preventDefault();
    setSplit((s) => clamp(s + delta));
  };

  return (
    <div
      ref={containerRef}
      data-testid="mock-resizable"
      className={cn(
        surface,
        'flex h-28 w-full max-w-64 overflow-hidden text-xs'
      )}
    >
      <div style={{ width: `${split}%` }} className="min-w-0 p-2.5">
        <p className="text-muted mb-1 font-medium">{crm.resizable.listTitle}</p>
        <ul className="text-foreground space-y-0.5">
          {crm.resizable.listItems.map((item) => (
            <li key={item} className="truncate">
              {item}
            </li>
          ))}
        </ul>
      </div>
      <div
        role="separator"
        aria-orientation="vertical"
        aria-label={crm.resizable.label}
        aria-valuemin={MIN}
        aria-valuemax={MAX}
        aria-valuenow={split}
        tabIndex={0}
        onKeyDown={onKeyDown}
        onPointerDown={onPointerDown}
        onPointerMove={onPointerMove}
        onPointerUp={onPointerUp}
        className={cn(
          focusRing,
          'bg-border hover:bg-accent w-(--just-border-width) shrink-0 cursor-col-resize touch-none',
          'relative before:absolute before:inset-y-0 before:-right-2 before:-left-2'
        )}
      />
      <div className="bg-background min-w-0 flex-1 p-2.5">
        <p className="text-foreground mb-1 truncate font-medium">
          {crm.resizable.detailTitle}
        </p>
        <p className="text-muted">{crm.resizable.detail}</p>
      </div>
    </div>
  );
}
