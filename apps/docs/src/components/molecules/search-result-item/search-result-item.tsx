import Link from 'next/link';
import type { Route } from 'next';
import { cn } from '@/lib/cn';
import type { SearchResultItemProps } from './search-result-item.types';

/**
 * Individual search result item molecule. Server Component.
 * Renders a navigable list item with label and type badge.
 */
export function SearchResultItem({
  label,
  type,
  href,
  onClick,
  isSelected = false,
  onMouseEnter,
  className,
}: SearchResultItemProps) {
  return (
    <Link
      href={href as Route}
      onClick={onClick}
      onMouseEnter={onMouseEnter}
      aria-current={isSelected ? 'true' : undefined}
      className={cn(
        'flex items-center justify-between rounded-(--just-radius-md) px-3 py-2 text-sm transition-colors',
        isSelected
          ? 'bg-accent-muted text-foreground'
          : 'text-secondary hover:bg-accent-muted hover:text-foreground',
        className
      )}
    >
      <span className="font-sans font-medium">{label}</span>
      <span className="text-muted font-mono text-xs">{type}</span>
    </Link>
  );
}
