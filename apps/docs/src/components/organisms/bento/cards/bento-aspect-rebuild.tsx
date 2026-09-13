'use client';

import { useState } from 'react';
import { cn } from '@/lib/cn';
import { Badge } from '@/components/atoms/badge';
import { StatCounter } from '@/components/molecules/stat-counter';

interface BentoAspectRebuildProps {
  title: string;
  description: string;
  className?: string;
}

type Aspect = 'colors' | 'typography' | 'spacing';

interface TreeNode {
  id: string;
  name: string;
  aspect: Aspect | 'none';
  api: string;
}

const TREE_NODES: TreeNode[] = [
  { id: 'btn', name: 'JustButton', aspect: 'colors', api: 'context.justColors' },
  { id: 'card', name: 'JustCard', aspect: 'colors', api: 'context.justColors' },
  { id: 'h1', name: 'HeadlineText', aspect: 'typography', api: 'context.justTypo' },
  { id: 'body', name: 'BodyParagraph', aspect: 'typography', api: 'context.justTypo' },
  { id: 'pad', name: 'PaddingBox', aspect: 'spacing', api: 'context.justSpacing' },
  { id: 'ico', name: 'StaticIcon', aspect: 'none', api: 'context.readTheme()' },
];

export function BentoAspectRebuild({
  title,
  description,
  className,
}: BentoAspectRebuildProps) {
  const [activeAspect, setActiveAspect] = useState<Aspect>('colors');

  const triggerAspect = (aspect: Aspect) => {
    setActiveAspect(aspect);
  };

  const dirtyNodes = TREE_NODES.filter((n) => n.aspect === activeAspect);
  const dirtyCount = dirtyNodes.length;
  const totalNodes = TREE_NODES.length;
  const savingsPct = Math.round(((totalNodes - dirtyCount) / totalNodes) * 100);

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
            PERFORMANCE
          </Badge>
          <div className="flex gap-1">
            {(['colors', 'typography', 'spacing'] as Aspect[]).map((asp) => (
              <button
                key={asp}
                type="button"
                onClick={() => triggerAspect(asp)}
                className={cn(
                  'rounded-(--just-radius-xs) border px-2 py-1 font-mono text-[11px] uppercase transition-colors',
                  activeAspect === asp
                    ? 'border-accent bg-accent/20 text-accent-deep dark:text-accent font-bold'
                    : 'border-border bg-muted/20 text-muted hover:text-foreground'
                )}
              >
                {asp}
              </button>
            ))}
          </div>
        </div>

        <h3 className="text-foreground mt-4 font-mono text-lg font-bold">
          {title}
        </h3>
        <p className="text-muted mt-1 text-sm leading-relaxed">
          {description}
        </p>

        {/* Tree simulation nodes */}
        <div className="border-border bg-background/60 mt-4 rounded-(--just-radius-md) border p-3">
          <div className="text-muted mb-2 flex items-center justify-between font-mono text-xs">
            <span>Widget Tree Aspect Invalidation</span>
            <span className="text-accent font-bold">
              Aspect: {activeAspect.toUpperCase()}
            </span>
          </div>

          <div className="grid grid-cols-2 gap-2 font-mono text-xs sm:grid-cols-3">
            {TREE_NODES.map((node) => {
              const isDirty = node.aspect === activeAspect;
              return (
                <div
                  key={node.id}
                  className={cn(
                    'flex flex-col rounded p-2 transition-all duration-300 border',
                    isDirty
                      ? 'border-amber-500/80 bg-amber-500/10 text-amber-300 ring-1 ring-amber-500/30'
                      : 'border-border/60 bg-card/60 text-muted opacity-60'
                  )}
                >
                  <div className="flex items-center justify-between">
                    <span className="font-bold text-[11px]">{node.name}</span>
                    <span
                      className={cn(
                        'rounded px-1 py-0.2 text-[9px] font-bold',
                        isDirty
                          ? 'bg-amber-500/30 text-amber-200 animate-pulse'
                          : 'bg-muted/20 text-muted'
                      )}
                    >
                      {isDirty ? 'REBUILD' : 'IDLE'}
                    </span>
                  </div>
                  <span className="text-[10px] opacity-80 mt-1 truncate">
                    {node.api}
                  </span>
                </div>
              );
            })}
          </div>
        </div>

        {/* Stats counter */}
        <div className="mt-4 grid grid-cols-3 gap-2 border-t border-border/60 pt-3">
          <StatCounter
            value={`${dirtyCount}/${totalNodes}`}
            label="Dirty Nodes"
            unit="nodes"
          />
          <StatCounter
            value={`${savingsPct}%`}
            label="CPU Saved"
            unit="reduction"
          />
          <StatCounter
            value={`O(K)`}
            label="Complexity"
            unit="vs O(N)"
          />
        </div>
      </div>

      <div className="border-border/60 mt-4 flex items-center justify-between border-t pt-3 text-xs font-mono">
        <span className="text-muted">InheritedModel Aspect Scope</span>
        <span className="text-accent font-bold">ZERO UNNECESSARY REBUILDS</span>
      </div>
    </div>
  );
}
