'use client';

import { useMemo, useState } from 'react';
import { cn } from '@/lib/cn';
import { CodeLines } from './highlight';
import {
  JustButtonPreview,
  type JustButtonSize,
  type JustButtonVariant,
} from './just-button-preview';
import { usePresetScope } from './preset-scope';

const VARIANTS: JustButtonVariant[] = [
  'primary',
  'secondary',
  'ghost',
  'destructive',
  'link',
];
const SIZES: JustButtonSize[] = ['xs', 'sm', 'md', 'lg', 'xl'];

function Chip({
  active,
  onClick,
  children,
}: {
  active: boolean;
  onClick: () => void;
  children: string;
}) {
  return (
    <button
      type="button"
      aria-pressed={active}
      onClick={onClick}
      className={cn(
        'h-7 rounded-(--just-radius-sm) border-(length:--just-border-width) px-2.5 font-mono text-xs',
        active
          ? 'bg-accent text-accent-foreground border-border font-semibold'
          : 'bg-card text-secondary border-fill'
      )}
    >
      {children}
    </button>
  );
}

function Group({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div>
      <div className="text-muted mb-2 font-mono text-xs font-medium">{label}</div>
      <div className="flex flex-wrap gap-1.5">{children}</div>
    </div>
  );
}

/** Interactive JustButton playground: props on the left, live button and Dart code. */
export function ButtonPlayground() {
  const { scopeClass, toggle } = usePresetScope();
  const [variant, setVariant] = useState<JustButtonVariant>('primary');
  const [size, setSize] = useState<JustButtonSize>('md');
  const [label, setLabel] = useState('Save');
  const [loading, setLoading] = useState(false);
  const [disabled, setDisabled] = useState(false);
  const [fullWidth, setFullWidth] = useState(false);
  const [copied, setCopied] = useState(false);

  const code = useMemo(() => {
    const lines = [`  label: '${label}',`];
    if (variant !== 'primary') lines.push(`  variant: .${variant},`);
    if (size !== 'md') lines.push(`  size: .${size},`);
    if (loading) lines.push('  isLoading: true,');
    if (disabled) lines.push('  isDisabled: true,');
    if (fullWidth) lines.push('  isFullWidth: true,');
    lines.push('  onPressed: () {},');
    return `JustButton(\n${lines.join('\n')}\n)`;
  }, [label, variant, size, loading, disabled, fullWidth]);

  async function copy() {
    try {
      await navigator.clipboard.writeText(code);
    } catch {
      /* clipboard unavailable: ignore */
    }
    setCopied(true);
    window.setTimeout(() => setCopied(false), 1400);
  }

  return (
    <div className="not-prose my-6">
      <div className="mb-4 flex justify-end">{toggle}</div>
      <div className="bg-card border-border overflow-hidden rounded-(--just-radius-lg) border-(length:--just-border-width) shadow-sm">
        <div
          className={cn(
            scopeClass,
            'bg-background text-foreground border-border flex min-h-[200px] items-center justify-center border-b border-b-(length:--just-border-width) p-8'
          )}
        >
          <div className={cn(fullWidth ? 'w-full' : 'w-auto')}>
            <JustButtonPreview
              variant={variant}
              size={size}
              loading={loading}
              disabled={disabled}
              fullWidth={fullWidth}
            >
              {loading ? 'Processing...' : label}
            </JustButtonPreview>
          </div>
        </div>

        <div className="border-border grid gap-x-7 gap-y-5 border-b border-b-(length:--just-border-width) p-5 sm:grid-cols-2">
          <Group label="variant">
            {VARIANTS.map((v) => (
              <Chip key={v} active={variant === v} onClick={() => setVariant(v)}>
                {v}
              </Chip>
            ))}
          </Group>
          <Group label="size">
            {SIZES.map((s) => (
              <Chip key={s} active={size === s} onClick={() => setSize(s)}>
                {s}
              </Chip>
            ))}
          </Group>
          <div>
            <label
              htmlFor="playground-label"
              className="text-muted mb-2 block font-mono text-xs font-medium"
            >
              label
            </label>
            <input
              id="playground-label"
              value={label}
              onChange={(e) => setLabel(e.target.value)}
              className="bg-background text-foreground border-border focus:ring-accent/40 h-8 w-full rounded-(--just-radius-md) border-(length:--just-border-width) px-2.5 font-mono text-[13px] outline-none focus:ring-2"
            />
          </div>
          <Group label="state">
            <Chip active={loading} onClick={() => setLoading((v) => !v)}>
              isLoading
            </Chip>
            <Chip active={disabled} onClick={() => setDisabled((v) => !v)}>
              isDisabled
            </Chip>
            <Chip active={fullWidth} onClick={() => setFullWidth((v) => !v)}>
              isFullWidth
            </Chip>
          </Group>
        </div>

        <div className="bg-background relative">
          <button
            type="button"
            onClick={copy}
            className="bg-card text-secondary border-border absolute top-2.5 right-2.5 h-[26px] rounded-(--just-radius-sm) border-(length:--just-border-width) px-2.5 font-mono text-xs font-medium"
          >
            {copied ? 'Copied' : 'Copy'}
          </button>
          <CodeLines code={code} />
        </div>
      </div>
    </div>
  );
}
