'use client';

import { useState } from 'react';
import { cn } from '@/lib/cn';
import { Badge } from '@/components/atoms/badge';

interface BentoZeroDependencyProps {
  title: string;
  description: string;
  className?: string;
}

type Mode = 'traditional' | 'justui';

interface DepNode {
  name: string;
  category: 'core' | 'transitive' | 'sdk';
  size: string;
}

const TRADITIONAL_NODES: DepNode[] = [
  { name: 'ui_kit_core', category: 'core', size: '1.4 MB' },
  { name: 'intl', category: 'transitive', size: '640 KB' },
  { name: 'equatable', category: 'transitive', size: '180 KB' },
  { name: 'provider', category: 'transitive', size: '320 KB' },
  { name: 'uuid', category: 'transitive', size: '110 KB' },
  { name: 'collection', category: 'transitive', size: '290 KB' },
  { name: 'vector_math', category: 'transitive', size: '950 KB' },
  { name: 'crypto', category: 'transitive', size: '310 KB' },
];

export function BentoZeroDependency({
  title,
  description,
  className,
}: BentoZeroDependencyProps) {
  const [mode, setMode] = useState<Mode>('justui');
  const [selectedNode, setSelectedNode] = useState<string | null>(null);

  const isJustUI = mode === 'justui';

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
            ARCHITECTURE
          </Badge>
          <div className="border-border bg-muted/20 inline-flex rounded-(--just-radius-sm) border p-0.5 text-xs">
            <button
              type="button"
              onClick={() => {
                setMode('traditional');
                setSelectedNode(null);
              }}
              className={cn(
                'rounded-(--just-radius-xs) px-2.5 py-1 font-mono transition-colors',
                !isJustUI
                  ? 'bg-destructive/20 text-destructive font-medium'
                  : 'text-muted hover:text-foreground'
              )}
            >
              Traditional Pub
            </button>
            <button
              type="button"
              onClick={() => {
                setMode('justui');
                setSelectedNode(null);
              }}
              className={cn(
                'rounded-(--just-radius-xs) px-2.5 py-1 font-mono transition-colors',
                isJustUI
                  ? 'bg-accent/20 text-accent-deep dark:text-accent font-medium'
                  : 'text-muted hover:text-foreground'
              )}
            >
              JustUI (0 Dep)
            </button>
          </div>
        </div>

        <h3 className="text-foreground mt-4 font-mono text-lg font-bold">
          {title}
        </h3>
        <p className="text-muted mt-1 text-sm leading-relaxed">
          {description}
        </p>

        {/* Tree simulation visualizer */}
        <div className="border-border bg-background/60 mt-5 rounded-(--just-radius-md) border p-4">
          <div className="text-muted mb-3 flex items-center justify-between font-mono text-xs">
            <span>pubspec.yaml graph</span>
            <span
              className={cn(
                'font-bold',
                isJustUI ? 'text-accent' : 'text-destructive'
              )}
            >
              {isJustUI ? '0 external dependencies' : '14 packages / 4.2 MB'}
            </span>
          </div>

          {isJustUI ? (
            <div className="flex flex-col gap-2 py-2 font-mono text-xs">
              <div className="border-border bg-card flex items-center justify-between rounded px-3 py-2 border">
                <span className="text-foreground font-semibold">my_flutter_app</span>
                <span className="text-muted">workspace</span>
              </div>
              <div className="border-accent/40 bg-accent/5 ml-4 flex items-center justify-between rounded px-3 py-2 border">
                <div className="flex items-center gap-2">
                  <span className="text-accent font-bold">|- lib/widgets/</span>
                  <span className="text-muted text-[11px]">(Copy-Paste Source)</span>
                </div>
                <Badge variant="success">100% Owned</Badge>
              </div>
              <div className="border-border/60 bg-muted/10 ml-4 flex items-center justify-between rounded px-3 py-2 border">
                <div className="flex items-center gap-2">
                  <span className="text-foreground">`- flutter</span>
                  <span className="text-muted text-[11px]">(SDK Core)</span>
                </div>
                <span className="text-muted">Official SDK</span>
              </div>
            </div>
          ) : (
            <div className="grid grid-cols-2 gap-2 py-1 font-mono text-xs sm:grid-cols-4">
              {TRADITIONAL_NODES.map((node) => {
                const isSelected = selectedNode === node.name;
                return (
                  <button
                    key={node.name}
                    type="button"
                    onClick={() => setSelectedNode(isSelected ? null : node.name)}
                    className={cn(
                      'flex flex-col items-start rounded p-2 text-left transition-colors border',
                      isSelected
                        ? 'border-destructive bg-destructive/10 text-destructive'
                        : 'border-border/60 bg-card hover:border-destructive/40 text-foreground'
                    )}
                  >
                    <span className="truncate text-[11px] font-medium">
                      {node.name}
                    </span>
                    <span className="text-muted text-[10px]">{node.size}</span>
                  </button>
                );
              })}
            </div>
          )}
        </div>
      </div>

      <div className="border-border/60 mt-4 flex items-center justify-between border-t pt-3 text-xs font-mono">
        <span className="text-muted">Supply Chain Vulnerability</span>
        <span className={cn('font-bold', isJustUI ? 'text-accent' : 'text-destructive')}>
          {isJustUI ? 'ZERO VECTOR (0)' : 'HIGH SURFACE (14+)'}
        </span>
      </div>
    </div>
  );
}
