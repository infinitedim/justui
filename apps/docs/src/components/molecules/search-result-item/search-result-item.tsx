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
  className,
}: SearchResultItemProps) {
  return (
    <Link
      href={href as Route}
      onClick={onClick}
      className={cn(
        'flex items-center justify-between rounded-(--just-radius-md) px-3 py-2 text-sm transition-colors',
        'text-secondary hover:bg-accent-muted hover:text-foreground',
        className
      )}
    >
      <span>{label}</span>
      <span className="text-muted font-mono text-xs">{type}</span>
    </Link>
  );
}
