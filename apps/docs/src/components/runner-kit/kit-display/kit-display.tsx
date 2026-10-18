import { Copy } from 'lucide-react';
import { cn } from '@/lib/cn';
import { kitLabel } from '@/lib/kit-classes';
import { KitIconButton } from '@/components/runner-kit/kit-actions';
import type {
  KitAvatarGroupProps,
  KitAvatarProps,
  KitBadgeProps,
  KitSeparatorProps,
  KitSkeletonProps,
  KitTooltipProps,
} from './kit-display.types';

const ring =
  'border-(length:--ip-surface-line) border-(--ip-part-container-border)';

/** Neutral pill label (status color is never used on badges, spec 5.3). */
export function KitBadge({ children, className }: KitBadgeProps) {
  return (
    <span
      className={cn(
        'bg-ip-sunken border-ip-border-subtle text-ip-text-primary inline-flex h-6 items-center rounded-full border px-2.5 text-xs font-(--ip-strong-weight)',
        'neo:bg-ip-surface neo:border-[2.5px] neo:border-ip-text-primary',
        className
      )}
    >
      {children}
    </span>
  );
}

/** Initials avatar on a sunken circle. */
export function KitAvatar({ initials, className }: KitAvatarProps) {
  return (
    <span
      className={cn(
        'bg-ip-sunken border-ip-border-subtle text-ip-text-primary flex size-10 shrink-0 items-center justify-center rounded-full border text-sm font-bold',
        'neo:border-[2.5px] neo:border-ip-text-primary',
        className
      )}
    >
      {initials}
    </span>
  );
}

/** Overlapping avatars separated by a canvas ring. */
export function KitAvatarGroup({ initials, className }: KitAvatarGroupProps) {
  return (
    <span className={cn('flex items-center', className)}>
      {initials.map((value, index) => (
        <span
          key={value}
          className={cn(
            'flex rounded-full',
            index > 0 && 'ring-ip-canvas -ml-2.5 ring-2'
          )}
        >
          <KitAvatar initials={value} />
        </span>
      ))}
    </span>
  );
}

/** Placeholder shapes while content loads (static in the demo). */
export function KitSkeleton({ className }: KitSkeletonProps) {
  const bar = 'bg-ip-selection h-3 rounded-[6px] neo:rounded-none';
  return (
    <span
      aria-hidden="true"
      className={cn('flex items-center gap-3', className)}
    >
      <span className="bg-ip-selection size-10 shrink-0 rounded-full" />
      <span className="flex flex-col gap-2">
        <span className={cn(bar, 'w-[150px]')} />
        <span className={cn(bar, 'w-[100px]')} />
      </span>
    </span>
  );
}

/** Vertical rule between two labels. */
export function KitSeparator({ start, end, className }: KitSeparatorProps) {
  return (
    <span className={cn('flex items-center gap-3', className)}>
      <span className={kitLabel}>{start}</span>
      <span
        role="separator"
        aria-orientation="vertical"
        className="h-5 w-(--ip-separator-width) bg-(--ip-part-separator)"
      />
      <span className={kitLabel}>{end}</span>
    </span>
  );
}

/** Inverse tooltip bubble above the icon button it describes. */
export function KitTooltip({ label, className }: KitTooltipProps) {
  return (
    <span className={cn('flex flex-col items-center gap-2', className)}>
      <span
        aria-hidden="true"
        className={cn(
          'bg-ip-inverse text-ip-on-inverse rounded-[6px] px-2.5 py-1.5 text-xs font-semibold',
          'neo:rounded-none',
          ring
        )}
      >
        {label}
      </span>
      <KitIconButton label={label}>
        <Copy size={16} aria-hidden="true" />
      </KitIconButton>
    </span>
  );
}
