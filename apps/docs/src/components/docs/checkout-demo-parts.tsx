import { ArrowRight, Check, X } from 'lucide-react';
import { JustButtonPreview } from './just-button-preview';

interface DiscardedOrderProps {
  onRestore: () => void;
}

export function DiscardedOrder({ onRestore }: DiscardedOrderProps) {
  return (
    <div className="flex h-72.5 flex-col items-center justify-center gap-4 text-center">
      <div className="text-base font-medium">Order discarded</div>
      <JustButtonPreview variant="secondary" onClick={onRestore}>
        Restore order
      </JustButtonPreview>
    </div>
  );
}

interface OrderSummaryProps {
  paying: boolean;
  paid: boolean;
  saved: boolean;
  onPay: () => void;
  onSave: () => void;
  onDiscard: () => void;
}

export function OrderSummary({
  paying,
  paid,
  saved,
  onPay,
  onSave,
  onDiscard,
}: OrderSummaryProps) {
  return (
    <>
      <div className="text-muted font-mono text-xs">Order #2841</div>
      <div className="mt-1.5 text-xl font-medium tracking-tight">
        Team plan, 5 seats
      </div>
      <div className="border-fill mt-4 flex justify-between border-y py-3.5 text-sm">
        <span className="text-secondary">Total</span>
        <span className="font-mono font-medium">49.00 USD</span>
      </div>
      <div className="mt-5 flex flex-col gap-3">
        <JustButtonPreview
          size="lg"
          fullWidth
          loading={paying}
          disabled={paid}
          onClick={onPay}
          trailing={
            paid ? (
              <Check className="size-4" />
            ) : (
              <ArrowRight className="size-4" />
            )
          }
        >
          {paid ? 'Paid' : 'Pay now'}
        </JustButtonPreview>
        <div className="flex gap-2">
          <JustButtonPreview variant="secondary" fullWidth onClick={onSave}>
            {saved ? 'Draft saved' : 'Save draft'}
          </JustButtonPreview>
          <JustButtonPreview
            variant="destructive"
            aria-label="Discard order"
            title="Discard order"
            className="w-9 shrink-0 px-0"
            onClick={onDiscard}
          >
            <X className="mx-auto size-4" />
          </JustButtonPreview>
        </div>
        <JustButtonPreview variant="link" size="sm" className="self-center">
          Need help?
        </JustButtonPreview>
      </div>
    </>
  );
}

interface ConfirmDiscardProps {
  onCancel: () => void;
  onDiscard: () => void;
}

export function ConfirmDiscard({ onCancel, onDiscard }: ConfirmDiscardProps) {
  return (
    <div className="absolute inset-0 flex items-center justify-center bg-black/50 p-5">
      <div
        role="alertdialog"
        aria-label="Discard this order?"
        className="bg-card border-border w-full max-w-65 rounded-(--just-radius-lg) border-(length:--just-border-width) p-5 shadow-sm"
      >
        <div className="text-[15px] font-medium">Discard this order?</div>
        <div className="text-secondary mt-1.5 text-[13px]">
          This cannot be undone.
        </div>
        <div className="mt-4 flex justify-end gap-2">
          <JustButtonPreview variant="secondary" size="sm" onClick={onCancel}>
            Cancel
          </JustButtonPreview>
          <JustButtonPreview
            variant="destructive"
            size="sm"
            onClick={onDiscard}
          >
            Discard
          </JustButtonPreview>
        </div>
      </div>
    </div>
  );
}

interface WidgetStateProps {
  paying: boolean;
  paid: boolean;
  onReset: () => void;
}

/** The `_paying` / `_paid` fields of the code sample, live. */
export function WidgetState({ paying, paid, onReset }: WidgetStateProps) {
  return (
    <div className="flex flex-col gap-3">
      <div className="text-muted font-mono text-xs font-medium">
        widget state
      </div>
      <div className="bg-card border-border rounded-(--just-radius-md) border-(length:--just-border-width) px-4 py-3.5 font-mono text-[13px]/6">
        <div>
          _paying:{' '}
          <span className={paying ? 'text-syn-keyword' : 'text-syn-number'}>
            {String(paying)}
          </span>
        </div>
        <div>
          _paid:{' '}
          <span className={paid ? 'text-syn-keyword' : 'text-syn-number'}>
            {String(paid)}
          </span>
        </div>
      </div>
      <JustButtonPreview
        variant="ghost"
        size="sm"
        className="self-start"
        onClick={onReset}
      >
        Reset
      </JustButtonPreview>
      <p className="text-muted text-[13px] leading-relaxed">
        Tap Pay now, or the red X to open the confirmation. The button stays
        disabled once paid.
      </p>
    </div>
  );
}
