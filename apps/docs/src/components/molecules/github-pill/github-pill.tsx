import { GitHubMark } from '@/components/atoms/github-mark';
import { cn } from '@/lib/cn';
import type { GitHubPillProps } from './github-pill.types';

function formatStars(stars: number | null): string {
  if (stars === null) return 'Stars';
  if (stars >= 1000) return `${(stars / 1000).toFixed(1)}k`;
  return stars.toString();
}

/**
 * GitHub link molecule with star count. Server Component.
 * Same box model as the other header controls (28px, preset-aware border,
 * xs shadow, press effect).
 */
export function GitHubPill({ href, starCount, className }: GitHubPillProps) {
  return (
    <a
      href={href}
      target="_blank"
      rel="noopener noreferrer"
      className={cn(
        'just-press bg-card text-foreground inline-flex h-7 items-center gap-2 px-3 font-mono text-xs',
        'border-border rounded-(--just-radius-md) border-(length:--just-border-width) shadow-xs',
        className
      )}
    >
      <GitHubMark size={14} aria-hidden="true" />
      <span>{formatStars(starCount)}</span>
    </a>
  );
}
