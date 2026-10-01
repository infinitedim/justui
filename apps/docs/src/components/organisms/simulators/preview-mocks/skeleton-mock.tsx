'use client';

// Static on purpose: a placeholder that pulses forever fails WCAG 2.2.2.
const block = 'bg-fill rounded-(--just-radius-sm)';

export function SkeletonMock() {
  return (
    <div
      data-testid="mock-skeleton"
      aria-label="Loading order"
      className="w-full max-w-56 space-y-2.5"
    >
      <div className="flex items-center gap-2.5">
        <div className="bg-fill h-9 w-9 rounded-full" />
        <div className="flex-1 space-y-1.5">
          <div className={`${block} h-3.5 w-3/4`} />
          <div className={`${block} h-3 w-1/2`} />
        </div>
      </div>
      <div className={`${block} h-8 w-full`} />
    </div>
  );
}
