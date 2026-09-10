import { cn } from '@/lib/cn';
import type {
  TooltipBubbleProps,
  TooltipPosition,
} from './tooltip-bubble.types';

const positionClassMap: Record<TooltipPosition, string> = {
  top: 'bottom-full left-1/2 -translate-x-1/2 mb-2',
  bottom: 'top-full left-1/2 -translate-x-1/2 mt-2',
  left: 'right-full top-1/2 -translate-y-1/2 mr-2',
  right: 'left-full top-1/2 -translate-y-1/2 ml-2',
};

/**
 * Tooltip bubble atom. Server Component (pure visual).
 * Renders a floating label with preset-aware border/shadow.
 * Visibility and positioning context is controlled by the parent.
 */
export function TooltipBubble({
  position = 'top',
  visible = true,
  className,
  children,
  ...rest
}: TooltipBubbleProps) {
  if (!visible) return null;

  return (
    <div
      role="tooltip"
      className={cn(
        'absolute z-50 rounded-(--just-radius-md) px-2.5 py-1.5 whitespace-nowrap',
        'border-border border-(length:--just-border-width)',
        'bg-card text-foreground font-mono text-xs',
        'shadow-solid',
        'animate-in fade-in-0 zoom-in-95',
        positionClassMap[position],
        className
      )}
      {...rest}
    >
      {children}
    </div>
  );
}
