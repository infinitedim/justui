import { PresetStage } from '@/components/organisms/preset-stage';
import { PartCell } from './part-cell';
import type { PartRunnerProps } from './parts-index.types';

/**
 * One runner of the components page (landing v3 Parts index): its parts in
 * a frame, with the runner's letter, name and part count set into the
 * bottom edge. The name is the section's heading, first in reading order.
 */
export function PartRunner({ group, copy }: PartRunnerProps) {
  const name = copy.page.groups[group.id];
  const headingId = `runner-${group.id}`;
  return (
    <section aria-labelledby={headingId} className="relative pb-4">
      <div className="bg-ip-canvas absolute right-6 bottom-0.5 z-10 flex h-7 items-center gap-2.5 px-2.5">
        <span aria-hidden="true" className="text-2xl/7 font-bold">
          {group.letter}
        </span>
        <h2
          id={headingId}
          className="text-ip-text-secondary text-sm font-semibold"
        >
          {name}
        </h2>
        <span className="text-ip-text-tertiary text-sm font-medium tabular-nums">
          {group.slugs.length}
        </span>
      </div>
      <PresetStage
        animated={false}
        className="border-ip-border-control overflow-hidden rounded-[20px] border-[1.5px]"
      >
        <ul className="flex flex-wrap">
          {group.slugs.map((slug) => (
            <PartCell key={slug} slug={slug} copy={copy} />
          ))}
        </ul>
      </PresetStage>
    </section>
  );
}
