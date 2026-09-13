'use client';

import { useState } from 'react';
import { cn } from '@/lib/cn';
import { Badge } from '@/components/atoms/badge';
import { FormulaMathBlock } from '@/components/molecules/formula-math-block';

interface BentoNeobrutalismProps {
  title: string;
  description: string;
  className?: string;
}

export function BentoNeobrutalism({
  title,
  description,
  className,
}: BentoNeobrutalismProps) {
  const [isPressed, setIsPressed] = useState<boolean>(false);
  const [switchOn, setSwitchOn] = useState<boolean>(true);

  // Switch calculus constants
  const trackHeight = 32;
  const padding = 3;
  const borderWidth = 2.5;
  const thumbDiameter = trackHeight - 2 * padding - 2 * borderWidth; // 21px

  return (
    <div
      className={cn(
        'group relative flex flex-col justify-between overflow-hidden rounded-(--just-radius-lg)',
        'border-border bg-card/80 p-6 backdrop-blur-xs transition-all duration-200',
        'border-(length:--just-border-width) hover:border-accent/40',
        className
      )}
    >
      <div>
        <div className="flex items-center justify-between gap-4">
          <Badge variant="outline">
            PHYSICS & CALCULUS
          </Badge>
          <span className="font-mono text-xs text-muted">
            0ms Frame-Lock
          </span>
        </div>

        <h3 className="text-foreground mt-4 font-mono text-lg font-bold">
          {title}
        </h3>
        <p className="text-muted mt-1 text-sm leading-relaxed">
          {description}
        </p>

        {/* Interactive Physics Sandbox */}
        <div className="border-border bg-background/60 mt-4 grid grid-cols-1 gap-4 rounded-(--just-radius-md) border p-4 sm:grid-cols-2">
          {/* Interactive Button Demo */}
          <div className="flex flex-col items-center justify-center gap-3 rounded border border-dashed border-border/80 p-4">
            <span className="font-mono text-[11px] text-muted">
              Click & Hold to Test Drift
            </span>
            <button
              type="button"
              onMouseDown={() => setIsPressed(true)}
              onMouseUp={() => setIsPressed(false)}
              onMouseLeave={() => setIsPressed(false)}
              onTouchStart={() => setIsPressed(true)}
              onTouchEnd={() => setIsPressed(false)}
              className={cn(
                'rounded-none border-[2.5px] border-foreground px-5 py-2.5 font-mono text-xs font-black uppercase text-foreground transition-none select-none',
                'bg-accent',
                isPressed
                  ? 'translate-x-1 translate-y-1 shadow-none'
                  : 'translate-x-0 translate-y-0 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] dark:shadow-[4px_4px_0px_0px_rgba(255,255,255,0.9)]'
              )}
            >
              {isPressed ? 'Pressed' : 'Press Me'}
            </button>
            <div className="flex gap-2 font-mono text-[10px] text-muted">
              <span>T: {isPressed ? '(4px, 4px)' : '(0px, 0px)'}</span>
              <span>S: {isPressed ? '(0px, 0px)' : '(4px, 4px)'}</span>
              <span className="text-accent font-bold">Invariance: 100%</span>
            </div>
          </div>

          {/* Interactive Switch with Inner-Border Calculus */}
          <div className="flex flex-col items-center justify-center gap-3 rounded border border-dashed border-border/80 p-4">
            <span className="font-mono text-[11px] text-muted">
              Inner-Border Track Calculus
            </span>
            <button
              type="button"
              onClick={() => setSwitchOn(!switchOn)}
              className={cn(
                'relative h-8 w-16 rounded-full border-[2.5px] border-foreground transition-colors',
                switchOn ? 'bg-accent' : 'bg-muted/40'
              )}
            >
              <span
                style={{
                  width: `${thumbDiameter}px`,
                  height: `${thumbDiameter}px`,
                  top: `${padding}px`,
                  left: switchOn ? `calc(100% - ${thumbDiameter + padding + 1}px)` : `${padding}px`,
                }}
                className="absolute rounded-full border-[1.5px] border-foreground bg-foreground transition-all duration-150"
              />
            </button>
            <span className="font-mono text-[10px] text-muted">
              Thumb D = {thumbDiameter}px (No Clipping)
            </span>
          </div>
        </div>

        {/* Math Formula display */}
        <div className="mt-3">
          <FormulaMathBlock
            formula="D = H - 2p - 2b | P_rest == P_pressed"
            caption="Bresenham Space Compensation & Spatial Invariance"
          />
        </div>
      </div>

      <div className="border-border/60 mt-4 flex items-center justify-between border-t pt-3 text-xs font-mono">
        <span className="text-muted">Zero Visual Drift</span>
        <span className="text-accent font-bold">DELTA AREA = 0px</span>
      </div>
    </div>
  );
}
