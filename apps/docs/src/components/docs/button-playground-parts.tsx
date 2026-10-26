'use client';

// Client leaf: the props panel and the copy button keep local state.
import { useState } from 'react';
import { cn } from '@/lib/cn';
import { CodeLines } from './highlight';
import type { JustButtonSize, JustButtonVariant } from './just-button-preview';

const VARIANTS: JustButtonVariant[] = [
  'primary',
  'secondary',
  'ghost',
  'destructive',
  'link',
];
const SIZES: JustButtonSize[] = ['xs', 'sm', 'md', 'lg', 'xl'];

/** The JustButton props the playground can change. */
export interface PlaygroundProps {
  variant: JustButtonVariant;
  size: JustButtonSize;
  label: string;
  loading: boolean;
  disabled: boolean;
  fullWidth: boolean;
}

/** The Dart call for the chosen props; defaults are left out. */
export function dartCode(props: PlaygroundProps): string {
  const lines = [`  label: '${props.label}',`];
  if (props.variant !== 'primary') lines.push(`  variant: .${props.variant},`);
  if (props.size !== 'md') lines.push(`  size: .${props.size},`);
  if (props.loading) lines.push('  isLoading: true,');
  if (props.disabled) lines.push('  isDisabled: true,');
  if (props.fullWidth) lines.push('  isFullWidth: true,');
  lines.push('  onPressed: () {},');
  return `JustButton(\n${lines.join('\n')}\n)`;
}

interface ChipProps {
  active: boolean;
  onClick: () => void;
  children: string;
}

function Chip({ active, onClick, children }: ChipProps) {
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

interface GroupProps {
  label: string;
  children: React.ReactNode;
}

function Group({ label, children }: GroupProps) {
  return (
    <div>
      <div className="text-muted mb-2 font-mono text-xs font-medium">
        {label}
      </div>
      <div className="flex flex-wrap gap-1.5">{children}</div>
    </div>
  );
}

interface PropsPanelProps {
  props: PlaygroundProps;
  onChange: (patch: Partial<PlaygroundProps>) => void;
}

/** Chips and the label field that edit the playground props. */
export function PropsPanel({ props, onChange }: PropsPanelProps) {
  return (
    <div className="border-border grid gap-x-7 gap-y-5 border-b-(length:--just-border-width) p-5 sm:grid-cols-2">
      <Group label="variant">
        {VARIANTS.map((v) => (
          <Chip
            key={v}
            active={props.variant === v}
            onClick={() => onChange({ variant: v })}
          >
            {v}
          </Chip>
        ))}
      </Group>
      <Group label="size">
        {SIZES.map((s) => (
          <Chip
            key={s}
            active={props.size === s}
            onClick={() => onChange({ size: s })}
          >
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
          value={props.label}
          onChange={(e) => onChange({ label: e.target.value })}
          className="bg-background text-foreground border-border focus:ring-accent/40 h-8 w-full rounded-(--just-radius-md) border-(length:--just-border-width) px-2.5 font-mono text-[13px] outline-none focus:ring-2"
        />
      </div>
      <Group label="state">
        <Chip
          active={props.loading}
          onClick={() => onChange({ loading: !props.loading })}
        >
          isLoading
        </Chip>
        <Chip
          active={props.disabled}
          onClick={() => onChange({ disabled: !props.disabled })}
        >
          isDisabled
        </Chip>
        <Chip
          active={props.fullWidth}
          onClick={() => onChange({ fullWidth: !props.fullWidth })}
        >
          isFullWidth
        </Chip>
      </Group>
    </div>
  );
}

interface CopyCodeProps {
  code: string;
}

/** The Dart code with a copy button in its corner. */
export function CopyCode({ code }: CopyCodeProps) {
  const [copied, setCopied] = useState(false);

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
    <div className="bg-background relative">
      <button
        type="button"
        onClick={() => {
          void copy();
        }}
        className="bg-card text-secondary border-border absolute top-2.5 right-2.5 h-6.5 rounded-(--just-radius-sm) border-(length:--just-border-width) px-2.5 font-mono text-xs font-medium"
      >
        {copied ? 'Copied' : 'Copy'}
      </button>
      <CodeLines code={code} />
    </div>
  );
}
