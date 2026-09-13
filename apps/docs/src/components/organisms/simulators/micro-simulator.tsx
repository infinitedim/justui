'use client';

import React from 'react';
import { SimulatorHarness } from './simulator-harness';
import { SIMULATOR_REGISTRY } from './simulator-registry';

export interface MicroSimulatorProps {
  slug: string;
  preset?: 'default' | 'neobrutalism';
  badge?: string;
  className?: string;
}

export function MicroSimulator({
  slug,
  preset = 'default',
  badge,
  className,
}: MicroSimulatorProps) {
  const Mock = SIMULATOR_REGISTRY[slug];

  return (
    <SimulatorHarness preset={preset} badge={badge} className={className}>
      {Mock ? (
        <Mock preset={preset} />
      ) : (
        <div className="text-muted font-mono text-xs">Preview for {slug}</div>
      )}
    </SimulatorHarness>
  );
}
