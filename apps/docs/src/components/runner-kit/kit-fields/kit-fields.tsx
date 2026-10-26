'use client';

// Client leaf: the input validates as the visitor types.
import { useId, useState } from 'react';
import { ChevronDown, OctagonX } from 'lucide-react';
import { cn } from '@/lib/cn';
import { kitField, kitFieldLabel } from '@/lib/kit-classes';
import type {
  KitInputProps,
  KitInputRule,
  KitSelectProps,
} from './kit-fields.types';

const RULES = {
  project: /^[a-z][a-z0-9_]*$/,
  email: /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/,
} as const satisfies Record<KitInputRule, RegExp>;

/**
 * Text field. Invalid values get the spec 5.3 treatment: an error border
 * (2px default, 3px neobrutalism), an octagon icon, a message and
 * `aria-invalid`.
 */
export function KitInput({
  label,
  defaultValue,
  rule,
  errorMessage,
  type = 'text',
  className,
}: KitInputProps) {
  const id = useId();
  const [value, setValue] = useState(defaultValue);
  const invalid = !RULES[rule].test(value);
  return (
    <div className={cn('flex w-full flex-col gap-1.5', className)}>
      <label htmlFor={id} className={kitFieldLabel}>
        {label}
      </label>
      <input
        id={id}
        type={type}
        value={value}
        spellCheck={false}
        autoComplete="off"
        onChange={(event) => setValue(event.target.value)}
        aria-invalid={invalid}
        aria-describedby={invalid ? `${id}-error` : undefined}
        className={cn(
          kitField,
          invalid && 'border-ip-error border-(length:--ip-error-width)'
        )}
      />
      {invalid ? (
        <p
          id={`${id}-error`}
          className="text-ip-error neo:font-bold flex items-start gap-1.5 text-[13px]/4.5 font-medium"
        >
          <OctagonX size={16} aria-hidden="true" className="mt-px shrink-0" />
          {errorMessage}
        </p>
      ) : null}
    </div>
  );
}

/** Native select styled as a field; neobrutalism adds the flat offset. */
export function KitSelect({ label, options, className }: KitSelectProps) {
  const id = useId();
  return (
    <div className={cn('flex w-full flex-col gap-1.5', className)}>
      <label htmlFor={id} className={kitFieldLabel}>
        {label}
      </label>
      <div className="relative">
        <select
          id={id}
          className={cn(
            kitField,
            'cursor-pointer appearance-none pr-9 shadow-(--ip-shadow-primary)'
          )}
        >
          {options.map((option) => (
            <option key={option}>{option}</option>
          ))}
        </select>
        <ChevronDown
          size={16}
          aria-hidden="true"
          className="text-ip-text-primary pointer-events-none absolute top-1/2 right-3 -translate-y-1/2"
        />
      </div>
    </div>
  );
}
