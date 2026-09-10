import { FaGithub } from 'react-icons/fa';
import { cn } from '@/lib/cn';
import type { GitHubPillProps } from './github-pill.types';

function formatStars(stars: number | null): string {
  if (stars === null) return 'Stars';
  if (stars >= 1000) return `${(stars / 1000).toFixed(1)}k`;
  return stars.toString();
}

/**
 * GitHub link pill molecule with star count. Server Component.
 * Shows the GitHub icon and formatted star count in a pill-shaped link.
 */
export function GitHubPill({ href, starCount, className }: GitHubPillProps) {
  return (
    <a
      href={href}
      target="_blank"
      rel="noopener noreferrer"
      className={cn(
        'inline-flex items-center gap-2 rounded-full bg-transparent px-3 py-1.5 font-mono text-xs transition-colors',
        'border-border border-(length:--just-border-width)',
        'text-muted hover:text-foreground',
        className
      )}
    >
      <FaGithub size={14} aria-hidden="true" />
      <span>{formatStars(starCount)}</span>
    </a>
  );
}
