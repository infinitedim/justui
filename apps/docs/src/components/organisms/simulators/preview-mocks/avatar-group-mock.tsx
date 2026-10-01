'use client';

import { hint } from './mock-styles';

const people = ['AR', 'MS', 'KT'];

export function AvatarGroupMock() {
  return (
    <div className="flex items-center gap-3">
      <div data-testid="mock-avatar-group" className="flex items-center">
        {people.map((initials, i) => (
          <span
            key={initials}
            className={`bg-fill text-foreground border-card flex h-9 w-9 items-center justify-center rounded-full border-2 text-xs font-semibold ${i > 0 ? '-ml-2.5' : ''}`}
          >
            {initials}
          </span>
        ))}
        <span className="bg-card text-secondary border-card -ml-2.5 flex h-9 w-9 items-center justify-center rounded-full border-2 text-xs font-semibold">
          +4
        </span>
      </div>
      <span className={hint}>Packing this order</span>
    </div>
  );
}
