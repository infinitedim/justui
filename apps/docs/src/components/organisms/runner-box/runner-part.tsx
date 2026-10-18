import { Gate } from '@/components/atoms/gate';
import { cn } from '@/lib/cn';
import { partCode } from '@/lib/parts';
import type { RunnerPartProps } from './runner-box.types';

/** One live part hanging from its gate on the runner frame. */
export function RunnerPart({
  slug,
  cut,
  onCut,
  children,
  className,
}: RunnerPartProps) {
  return (
    <div className={cn('flex flex-col items-start', className)}>
      <Gate
        code={partCode(slug)}
        name={slug}
        selected={slug === cut}
        onSelect={() => onCut(slug)}
        className="ml-5"
      />
      {children}
    </div>
  );
}
