'use client';

// Client leaf: the demo runs the checkout state machine and a timer.
import { useEffect, useRef, useState } from 'react';
import { cn } from '@/lib/cn';
import {
  ConfirmDiscard,
  DiscardedOrder,
  OrderSummary,
  WidgetState,
} from './checkout-demo-parts';
import { usePresetScope } from './preset-scope';

type PayState = 'idle' | 'paying' | 'paid' | 'discarded';

/**
 * Runs the same state machine as the CheckoutActions code sample:
 * `_paying` / `_paid`, a confirmation dialog, and a discarded end state.
 */
export function CheckoutDemo() {
  const { scopeClass, toggle } = usePresetScope();
  const [pay, setPay] = useState<PayState>('idle');
  const [confirm, setConfirm] = useState(false);
  const [saved, setSaved] = useState(false);
  const timer = useRef<number | undefined>(undefined);

  useEffect(() => () => window.clearTimeout(timer.current), []);

  function startPay() {
    if (pay !== 'idle') return;
    setPay('paying');
    timer.current = window.setTimeout(() => setPay('paid'), 1600);
  }

  function reset() {
    window.clearTimeout(timer.current);
    setPay('idle');
    setConfirm(false);
    setSaved(false);
  }

  function discard() {
    window.clearTimeout(timer.current);
    setPay('discarded');
    setConfirm(false);
  }

  const paying = pay === 'paying';
  const paid = pay === 'paid';

  return (
    <div className="not-prose my-4">
      <div className="mb-4 flex justify-end">{toggle}</div>
      <div
        className={cn(
          scopeClass,
          'bg-background text-foreground border-border rounded-(--just-radius-lg) border-(length:--just-border-width) p-6 shadow-md sm:p-10'
        )}
      >
        <div className="mx-auto grid max-w-3xl items-center gap-8 md:grid-cols-2">
          <div className="bg-card border-border relative min-h-85 overflow-hidden rounded-(--just-radius-lg) border-(length:--just-border-width) p-6 shadow-sm">
            {pay === 'discarded' ? (
              <DiscardedOrder onRestore={reset} />
            ) : (
              <OrderSummary
                paying={paying}
                paid={paid}
                saved={saved}
                onPay={startPay}
                onSave={() => setSaved(true)}
                onDiscard={() => setConfirm(true)}
              />
            )}
            {confirm ? (
              <ConfirmDiscard
                onCancel={() => setConfirm(false)}
                onDiscard={discard}
              />
            ) : null}
          </div>
          <WidgetState paying={paying} paid={paid} onReset={reset} />
        </div>
      </div>
    </div>
  );
}
