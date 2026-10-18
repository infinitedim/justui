import {
  CircleCheck,
  OctagonX,
  TriangleAlert,
  type LucideIcon,
} from 'lucide-react';
import { cn } from '@/lib/cn';
import type { StatusMessageProps, StatusTone } from './status-message.types';

const tones = {
  success: { Icon: CircleCheck, color: 'text-ip-success' },
  warning: { Icon: TriangleAlert, color: 'text-ip-warning' },
  error: { Icon: OctagonX, color: 'text-ip-error' },
} as const satisfies Record<StatusTone, { Icon: LucideIcon; color: string }>;

/**
 * One line of feedback (spec 5.3): the tone sets both the icon shape and
 * the color, so the state never depends on color alone.
 */
export function StatusMessage({
  tone,
  children,
  className,
}: StatusMessageProps) {
  const { Icon, color } = tones[tone];
  return (
    <span
      className={cn(
        'flex items-start gap-1.5 text-[13px]/4.5 font-medium',
        color,
        className
      )}
    >
      <Icon size={16} aria-hidden="true" className="mt-px shrink-0" />
      <span>{children}</span>
    </span>
  );
}
