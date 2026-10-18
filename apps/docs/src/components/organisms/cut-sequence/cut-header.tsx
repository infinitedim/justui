import type { CutHeaderProps } from './cut-sequence.types';

/** Section title, the command it runs and the reduced-motion switch. */
export function CutHeader({
  id,
  title,
  lead,
  command,
  tail,
  control,
}: CutHeaderProps) {
  return (
    <div className="flex flex-wrap items-end justify-between gap-x-12 gap-y-4">
      <h2
        id={id}
        className="max-w-[18ch] text-[clamp(32px,4.2vw,56px)] leading-[1.06] font-bold tracking-[-0.03em] text-balance"
      >
        {title}
      </h2>
      <div className="flex max-w-[50ch] flex-col items-start gap-3.5">
        <p className="text-ip-text-secondary text-[17px] leading-[1.6]">
          {lead}{' '}
          <code className="text-ip-text-primary font-mono text-[15px]">
            {command}
          </code>
          {tail}
        </p>
        {control}
      </div>
    </div>
  );
}
