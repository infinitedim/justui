import { FilePlus } from 'lucide-react';
import { partButton } from './cut-runner';
import type { CutMoverProps } from './cut-sequence.types';

/**
 * The copy of the part that flies from the runner to the file tree,
 * cross-fading from the button into its file row on the way. Purely
 * visual: hidden at rest and from assistive tech.
 */
export function CutMover({ label, file }: CutMoverProps) {
  return (
    <div
      data-cut="mover"
      aria-hidden="true"
      className="pointer-events-none absolute top-0 left-0 z-[2] opacity-0"
    >
      <span data-cut="mover-button" className={partButton}>
        {label}
      </span>
      <span
        data-cut="mover-row"
        className="text-ip-text-primary absolute top-0 left-0 inline-flex h-7 items-center gap-2 font-mono text-sm font-semibold whitespace-nowrap opacity-0"
      >
        <FilePlus size={14} aria-hidden="true" className="shrink-0" />
        {file}
      </span>
    </div>
  );
}
