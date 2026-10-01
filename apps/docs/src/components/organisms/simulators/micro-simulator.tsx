'use client';

import { SimulatorHarness } from './simulator-harness';
import { SIMULATOR_REGISTRY } from './simulator-registry';

export interface MicroSimulatorProps {
  slug: string;
  className?: string;
}

export function MicroSimulator({ slug, className }: MicroSimulatorProps) {
  const Mock = SIMULATOR_REGISTRY[slug];

  return (
    <SimulatorHarness className={className}>
      {Mock ? (
        <Mock />
      ) : (
        <span className="text-muted font-mono text-xs">{slug}</span>
      )}
    </SimulatorHarness>
  );
}
