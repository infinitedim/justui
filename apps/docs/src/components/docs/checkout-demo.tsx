'use client';

import { useEffect, useRef, useState } from 'react';
import { ArrowRight, Check, X } from 'lucide-react';
import { cn } from '@/lib/cn';
import { JustButtonPreview } from './just-button-preview';
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
          <div className="bg-card border-border relative min-h-[340px] overflow-hidden rounded-(--just-radius-lg) border-(length:--just-border-width) p-6 shadow-sm">
            {pay === 'discarded' ? (
              <div className="flex h-[290px] flex-col items-center justify-center gap-4 text-center">
                <div className="text-base font-medium">Order discarded</div>
                <JustButtonPreview variant="secondary" onClick={reset}>
                  Restore order
                </JustButtonPreview>
              </div>
            ) : (
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
                    onClick={startPay}
                    trailing={
                      paid ? (
                        <Check className="h-4 w-4" />
                      ) : (
                        <ArrowRight className="h-4 w-4" />
                      )
                    }
                  >
                    {paid ? 'Paid' : 'Pay now'}
                  </JustButtonPreview>
                  <div className="flex gap-2">
                    <JustButtonPreview
                      variant="secondary"
                      fullWidth
                      onClick={() => setSaved(true)}
                    >
                      {saved ? 'Draft saved' : 'Save draft'}
                    </JustButtonPreview>
                    <JustButtonPreview
                      variant="destructive"
                      aria-label="Discard order"
                      title="Discard order"
                      className="w-9 shrink-0 px-0"
                      onClick={() => setConfirm(true)}
                    >
                      <X className="mx-auto h-4 w-4" />
                    </JustButtonPreview>
                  </div>
                  <JustButtonPreview variant="link" size="sm" className="self-center">
                    Need help?
                  </JustButtonPreview>
                </div>
              </>
            )}

            {confirm ? (
              <div className="absolute inset-0 flex items-center justify-center bg-black/50 p-5">
                <div
                  role="alertdialog"
                  aria-label="Discard this order?"
                  className="bg-card border-border w-full max-w-[260px] rounded-(--just-radius-lg) border-(length:--just-border-width) p-5 shadow-sm"
                >
                  <div className="text-[15px] font-medium">Discard this order?</div>
                  <div className="text-secondary mt-1.5 text-[13px]">
                    This cannot be undone.
                  </div>
                  <div className="mt-4 flex justify-end gap-2">
                    <JustButtonPreview
                      variant="secondary"
                      size="sm"
                      onClick={() => setConfirm(false)}
                    >
                      Cancel
                    </JustButtonPreview>
                    <JustButtonPreview
                      variant="destructive"
                      size="sm"
                      onClick={discard}
                    >
                      Discard
                    </JustButtonPreview>
                  </div>
                </div>
              </div>
            ) : null}
          </div>

          <div className="flex flex-col gap-3">
            <div className="text-muted font-mono text-xs font-medium">
              widget state
            </div>
            <div className="bg-card border-border rounded-(--just-radius-md) border-(length:--just-border-width) px-4 py-3.5 font-mono text-[13px] leading-6">
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
              onClick={reset}
            >
              Reset
            </JustButtonPreview>
            <p className="text-muted text-[13px] leading-relaxed">
              Tap Pay now, or the red X to open the confirmation. The button
              stays disabled once paid.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
