import { useId } from 'react';
import { Search } from 'lucide-react';
import {
  StatusMessage,
  type StatusTone,
} from '@/components/atoms/status-message';
import { cn } from '@/lib/cn';
import { formatMessage } from '@/lib/format-message';
import type { NotFoundDictionary } from '@/lib/not-found-translations';
import { classifyPartLookup, normalizePartQuery } from '@/lib/part-lookup';
import { partCode } from '@/lib/parts';
import type { PartLookupFieldProps } from './not-found-runner.types';

interface LookupMessage {
  tone: StatusTone;
  text: string;
}

/** Spec 5.3 feedback for a lookup query; null while the field is empty. */
function lookupMessage(
  query: string,
  t: NotFoundDictionary
): LookupMessage | null {
  const result = classifyPartLookup(query);
  switch (result.kind) {
    case 'empty':
      return null;
    case 'exact':
      return {
        tone: 'success',
        text: formatMessage(t.lookupExact, {
          name: result.slug,
          code: partCode(result.slug),
        }),
      };
    case 'near':
      return {
        tone: 'warning',
        text: formatMessage(t.lookupNear, { query, best: result.best }),
      };
    case 'none':
      return { tone: 'error', text: formatMessage(t.lookupNone, { query }) };
  }
}

/**
 * "Look up a part": re-ranks the nearest parts as the visitor types. Only
 * a query with nothing close is an error (2px oxblood border); success and
 * warning never get a border. The status region is always mounted so
 * screen readers announce each change.
 */
export function PartLookupField({ value, onChange, t }: PartLookupFieldProps) {
  const id = useId();
  const message = lookupMessage(normalizePartQuery(value), t);
  const invalid = message?.tone === 'error';
  return (
    <div className="flex flex-col gap-2">
      <label
        htmlFor={id}
        className="text-ip-text-secondary text-[13px] font-semibold"
      >
        {t.lookup}
      </label>
      <div className="relative">
        <Search
          size={16}
          aria-hidden="true"
          className="text-ip-text-secondary pointer-events-none absolute top-1/2 left-3.5 -translate-y-1/2"
        />
        <input
          id={id}
          value={value}
          onChange={(event) => onChange(event.target.value)}
          placeholder={t.lookupPlaceholder}
          spellCheck={false}
          autoComplete="off"
          autoCapitalize="none"
          aria-invalid={invalid}
          aria-describedby={`${id}-status`}
          className={cn(
            'bg-ip-surface text-ip-text-primary placeholder:text-ip-text-tertiary h-12 w-full rounded-[10px] pr-3.5 pl-10 font-mono text-[15px]',
            invalid
              ? 'border-ip-error border-2'
              : 'border-ip-border-control border'
          )}
        />
      </div>
      <div id={`${id}-status`} role="status" className="min-h-[18px]">
        {message ? (
          <StatusMessage tone={message.tone}>{message.text}</StatusMessage>
        ) : null}
      </div>
    </div>
  );
}
