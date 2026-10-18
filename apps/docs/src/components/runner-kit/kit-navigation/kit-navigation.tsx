'use client';

// Client leaf: tabs, sidebar and bottom nav keep a selected item.
import { useState } from 'react';
import { cn } from '@/lib/cn';
import { useRovingTabs } from '@/lib/use-roving-tabs';
import type { KitItemListProps, KitTabsProps } from './kit-navigation.types';

/**
 * Underlined tabs: an ink indicator of 2px (default) or 4px (neo). Arrow
 * keys, Home and End move the selection (roving tabindex).
 */
export function KitTabs({ label, tabs, className }: KitTabsProps) {
  const [active, setActive] = useState(tabs[0] ?? '');
  const { registerTab, onKeyDown } = useRovingTabs(tabs, active, setActive);
  return (
    <div
      role="tablist"
      aria-label={label}
      className={cn(
        'flex border-b-(length:--ip-line) border-(--ip-part-container-border)',
        className
      )}
    >
      {tabs.map((tab) => {
        const selected = tab === active;
        return (
          <button
            key={tab}
            ref={registerTab(tab)}
            type="button"
            role="tab"
            aria-selected={selected}
            tabIndex={selected ? 0 : -1}
            onClick={() => setActive(tab)}
            onKeyDown={onKeyDown}
            className={cn(
              'h-[38px] cursor-pointer px-3 text-sm whitespace-nowrap transition-shadow duration-200',
              selected
                ? 'text-ip-text-primary neo:shadow-[inset_0_-4px_0_var(--ip-inverse)] font-(--ip-strong-weight) shadow-[inset_0_-2px_0_var(--ip-inverse)]'
                : 'text-ip-text-tertiary font-medium'
            )}
          >
            {tab}
          </button>
        );
      })}
    </div>
  );
}

/** Vertical section list; the current item uses the selected-item part. */
export function KitSidebar({
  label,
  items,
  defaultIndex = 1,
  className,
}: KitItemListProps) {
  const [current, setCurrent] = useState(defaultIndex);
  return (
    <div
      role="group"
      aria-label={label}
      className={cn(
        'bg-ip-surface flex w-[180px] flex-col gap-0.5 rounded-(--ip-radius-card) border-(length:--ip-line) border-(--ip-part-container-border) p-1.5',
        className
      )}
    >
      {items.map((item, index) => (
        <button
          key={item}
          type="button"
          aria-current={index === current ? 'page' : undefined}
          onClick={() => setCurrent(index)}
          className={cn(
            'neo:rounded-none cursor-pointer rounded-[6px] px-2.5 py-2 text-left text-[13px]',
            index === current
              ? 'bg-(--ip-part-selected-item-bg) font-(--ip-strong-weight) text-(--ip-part-selected-item-fg)'
              : 'text-ip-text-primary hover:bg-ip-hover font-medium'
          )}
        >
          {item}
        </button>
      ))}
    </div>
  );
}

/** Bottom navigation with an ink indicator bar under the current item. */
export function KitBottomNav({
  label,
  items,
  defaultIndex = 0,
  className,
}: KitItemListProps) {
  const [current, setCurrent] = useState(defaultIndex);
  return (
    <div
      role="group"
      aria-label={label}
      className={cn(
        'bg-ip-surface flex w-full max-w-[250px] justify-around border-t-(length:--ip-line) border-(--ip-part-container-border) pt-2 pb-1',
        className
      )}
    >
      {items.map((item, index) => (
        <button
          key={item}
          type="button"
          aria-current={index === current ? 'page' : undefined}
          onClick={() => setCurrent(index)}
          className={cn(
            'flex cursor-pointer flex-col items-center gap-1.5 px-2 py-1 text-xs',
            index === current
              ? 'text-ip-text-primary font-bold'
              : 'text-ip-text-tertiary font-medium'
          )}
        >
          <span>{item}</span>
          <span
            aria-hidden="true"
            className={cn(
              'bg-ip-inverse neo:h-1 neo:rounded-none h-[3px] w-5 rounded-full transition-transform duration-200',
              index === current ? 'scale-x-100' : 'scale-x-0'
            )}
          />
        </button>
      ))}
    </div>
  );
}
