import { useEffect, useRef, type RefObject } from 'react';
import { cn } from '@/lib/cn';
import { prefersReducedMotion } from '@/lib/use-reduced-motion';
import type { MissingSocketProps } from './not-found-runner.types';

const EASE = 'cubic-bezier(0.16, 1, 0.3, 1)';
const line = 'bg-ip-border-control h-4 w-[1.5px] scale-y-[0.45]';

/**
 * The 404's one orchestrated move (site motion, not preset motion): the
 * gate snaps shut, the empty socket is traced and the missing number
 * rises into it. Base styles are the final state, so nothing stays hidden
 * when the animation does not run.
 */
function useEntrance(
  gate: RefObject<HTMLDivElement | null>,
  socket: RefObject<HTMLDivElement | null>,
  numeral: RefObject<HTMLSpanElement | null>
) {
  useEffect(() => {
    const rise = numeral.current;
    if (!rise?.animate || prefersReducedMotion()) return;
    const timing = (duration: number) => ({ duration, easing: EASE });
    for (const node of Array.from(gate.current?.children ?? [])) {
      node.animate(
        [{ scale: '1 1' }, { scale: '1 1', offset: 0.2 }, { scale: '1 0.45' }],
        timing(420)
      );
    }
    const hidden = 'inset(0 100% 0 0 round 16px)';
    socket.current?.animate(
      [
        { clipPath: hidden },
        { clipPath: hidden, offset: 0.25 },
        { clipPath: 'inset(0 0% 0 0 round 16px)' },
      ],
      timing(760)
    );
    const below = {
      transform: 'translateY(40%)',
      clipPath: 'inset(0 0 100% 0)',
    };
    rise.animate(
      [
        below,
        { ...below, offset: 0.45 },
        { transform: 'translateY(0)', clipPath: 'inset(0 0 0% 0)' },
      ],
      timing(820)
    );
  }, [gate, socket, numeral]);
}

/** The empty socket where part 404 would hang. */
export function MissingSocket({ missing }: MissingSocketProps) {
  const gate = useRef<HTMLDivElement | null>(null);
  const socket = useRef<HTMLDivElement | null>(null);
  const numeral = useRef<HTMLSpanElement | null>(null);
  useEntrance(gate, socket, numeral);
  return (
    <div className="flex min-w-0 flex-[1.7_1_360px] flex-col items-start">
      <div className="ml-7 flex items-start gap-2">
        <div ref={gate} aria-hidden="true" className="flex w-0.5 flex-col">
          <span className={cn(line, 'origin-top')} />
          <span className={cn(line, 'origin-bottom')} />
        </div>
        <span className="bg-ip-inverse text-ip-on-inverse mt-[3px] flex h-[26px] items-center gap-1.5 rounded-[6px] px-2 text-xs font-bold whitespace-nowrap">
          404<span className="font-medium">{missing}</span>
        </span>
      </div>
      <div
        ref={socket}
        className="border-ip-border-control flex min-h-[clamp(160px,20vw,260px)] w-full flex-1 items-center justify-center overflow-hidden rounded-[16px] border-2 border-dashed"
      >
        <span
          ref={numeral}
          aria-hidden="true"
          className="text-[clamp(84px,13vw,196px)] leading-[0.9] font-bold tracking-[-0.04em] whitespace-nowrap tabular-nums"
        >
          404
        </span>
      </div>
    </div>
  );
}
