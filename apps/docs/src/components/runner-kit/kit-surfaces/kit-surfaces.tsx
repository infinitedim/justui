import { CircleCheck } from 'lucide-react';
import { cn } from '@/lib/cn';
import {
  kitCardDescription,
  kitCardTitle,
  kitSurface,
} from '@/lib/kit-classes';
import { KitButton } from '@/components/runner-kit/kit-actions';
import type {
  KitCardProps,
  KitDialogProps,
  KitSheetProps,
  KitToastProps,
} from './kit-surfaces.types';

const cardSizes = {
  sm: 'max-w-[240px] p-4',
  md: 'max-w-[420px] p-[22px]',
} as const;

/** Surface card. Default: soft ink shadow, no border. Neo: ink border. */
export function KitCard({
  title,
  description,
  size = 'sm',
  children,
  className,
}: KitCardProps) {
  return (
    <div
      className={cn(
        kitSurface,
        'w-full shadow-(--ip-shadow-md)',
        cardSizes[size],
        className
      )}
    >
      <p className={cn(kitCardTitle, size === 'md' && 'text-[17px] leading-6')}>
        {title}
      </p>
      <p
        className={cn(kitCardDescription, size === 'md' && 'text-sm leading-5')}
      >
        {description}
      </p>
      {children}
    </div>
  );
}

/** Status toast. Only the icon and the title carry the success color. */
export function KitToast({
  title,
  body,
  size = 'sm',
  className,
}: KitToastProps) {
  return (
    <div
      role="status"
      className={cn(
        kitSurface,
        'bg-ip-raised flex max-w-full items-start gap-3 px-4 py-3.5 shadow-(--ip-shadow-lg)',
        size === 'sm' ? 'w-[260px]' : 'w-[300px]',
        className
      )}
    >
      <CircleCheck
        size={18}
        aria-hidden="true"
        className="text-ip-success mt-px shrink-0"
      />
      <div className="flex flex-col gap-0.5">
        <span className="text-ip-success text-sm [font-weight:var(--ip-strong-weight)]">
          {title}
        </span>
        <span className="text-ip-text-secondary text-[13px] leading-[18px]">
          {body}
        </span>
      </div>
    </div>
  );
}

/** Confirmation surface with a destructive action (spec 6 Rule A). */
export function KitDialog({
  title,
  cancel,
  confirm,
  className,
}: KitDialogProps) {
  return (
    <div
      role="group"
      aria-label={title}
      className={cn(
        kitSurface,
        'bg-ip-raised w-full max-w-[250px] p-4 shadow-(--ip-shadow-lg)',
        className
      )}
    >
      <p className={kitCardTitle}>{title}</p>
      <div className="mt-3.5 flex justify-end gap-2">
        <KitButton variant="secondary" size="sm">
          {cancel}
        </KitButton>
        <KitButton variant="destructive" size="sm">
          {confirm}
        </KitButton>
      </div>
    </div>
  );
}

/** Bottom sheet with a grabber. */
export function KitSheet({ title, className }: KitSheetProps) {
  return (
    <div
      className={cn(
        kitSurface,
        'bg-ip-raised neo:rounded-none w-full max-w-[240px] rounded-t-[12px] rounded-b-none px-4 pb-5 shadow-(--ip-shadow-lg)',
        className
      )}
    >
      <span
        aria-hidden="true"
        className="bg-ip-border-control mx-auto mt-2 mb-3 block h-1 w-8 rounded-full"
      />
      <p className={kitCardTitle}>{title}</p>
    </div>
  );
}
