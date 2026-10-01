'use client';

import React from 'react';
import { SimulatorHarness } from './simulator-harness';
import { SIMULATOR_REGISTRY } from './simulator-registry';

export interface MicroSimulatorProps {
  slug: string;
  preset?: 'default' | 'neobrutalism';
  className?: string;
}

export function MicroSimulator({
  slug,
  preset = 'default',
  className,
}: MicroSimulatorProps) {
  const Mock = SIMULATOR_REGISTRY[slug];

  return (
    <SimulatorHarness preset={preset} className={className}>
      {Mock ? <Mock /> : <span className="text-muted text-sm">{slug}</span>}
    </SimulatorHarness>
  );
}
