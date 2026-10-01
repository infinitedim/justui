'use client';

const rule = 'bg-border h-(--just-border-width) w-full';

export function SeparatorMock() {
  return (
    <div
      data-testid="mock-separator"
      className="w-full max-w-56 space-y-2 text-sm"
    >
      <div className="text-secondary flex justify-between">
        <span>Subtotal</span>
        <span>$44.00</span>
      </div>
      <div className="text-secondary flex justify-between">
        <span>Shipping</span>
        <span>$4.00</span>
      </div>
      <div role="separator" className={rule} />
      <div className="text-foreground flex justify-between font-semibold">
        <span>Total</span>
        <span>$48.00</span>
      </div>
    </div>
  );
}
