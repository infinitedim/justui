'use client';

// Client leaf: the playground keeps the chosen props in state.
import { useState } from 'react';
import { cn } from '@/lib/cn';
import {
  CopyCode,
  PropsPanel,
  dartCode,
  type PlaygroundProps,
} from './button-playground-parts';
import { JustButtonPreview } from './just-button-preview';
import { usePresetScope } from './preset-scope';

const INITIAL: PlaygroundProps = {
  variant: 'primary',
  size: 'md',
  label: 'Save',
  loading: false,
  disabled: false,
  fullWidth: false,
};

/** Interactive JustButton playground: props on the left, live button and Dart code. */
export function ButtonPlayground() {
  const { scopeClass, toggle } = usePresetScope();
  const [props, setProps] = useState<PlaygroundProps>(INITIAL);
  const update = (patch: Partial<PlaygroundProps>) =>
    setProps((current) => ({ ...current, ...patch }));

  return (
    <div className="not-prose my-6">
      <div className="mb-4 flex justify-end">{toggle}</div>
      <div className="bg-card border-border overflow-hidden rounded-(--just-radius-lg) border-(length:--just-border-width) shadow-sm">
        <div
          className={cn(
            scopeClass,
            'bg-background text-foreground border-border flex min-h-50 items-center justify-center border-b-(length:--just-border-width) p-8'
          )}
        >
          <div className={cn(props.fullWidth ? 'w-full' : 'w-auto')}>
            <JustButtonPreview
              variant={props.variant}
              size={props.size}
              loading={props.loading}
              disabled={props.disabled}
              fullWidth={props.fullWidth}
            >
              {props.loading ? 'Processing...' : props.label}
            </JustButtonPreview>
          </div>
        </div>
        <PropsPanel props={props} onChange={update} />
        <CopyCode code={dartCode(props)} />
      </div>
    </div>
  );
}
