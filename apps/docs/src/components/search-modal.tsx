'use client';

import Link from 'next/link';
import type { Route } from 'next';
import { useEffect, useMemo, useRef, useState } from 'react';
import { getSearchData } from '@/lib/search-data';

interface SearchModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  lang: string;
}

export function SearchModal({ open, onOpenChange, lang }: SearchModalProps) {
  const [query, setQuery] = useState('');
  const inputRef = useRef<HTMLInputElement>(null);

  const results = useMemo(() => {
    const data = getSearchData(lang);
    const value = query.trim().toLowerCase();
    if (!value) return data;

    return data.filter((item) =>
      `${item.label} ${item.type}`.toLowerCase().includes(value)
    );
  }, [query, lang]);

  useEffect(() => {
    if (!open) return;

    inputRef.current?.focus();

    function onKeyDown(event: KeyboardEvent) {
      if (event.key === 'Escape') onOpenChange(false);
    }

    document.addEventListener('keydown', onKeyDown);
    return () => document.removeEventListener('keydown', onKeyDown);
  }, [onOpenChange, open]);

  if (!open) return null;

  return (
    <div
      className="fixed inset-0 z-50 flex items-start justify-center bg-black/60 px-4 pt-24 backdrop-blur-sm"
      onClick={(e) => {
        if (e.target === e.currentTarget) onOpenChange(false);
      }}
      role="button"
      aria-label="Close search overlay"
      tabIndex={0}
      onKeyDown={(e) => {
        if (
          (e.key === 'Enter' || e.key === ' ') &&
          e.target === e.currentTarget
        )
          onOpenChange(false);
      }}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-label="Search documentation"
        className="w-full max-w-lg rounded-lg border border-(--color-gray) bg-(--color-black-2)"
      >
        <input
          ref={inputRef}
          value={query}
          onChange={(event) => setQuery(event.target.value)}
          placeholder="Search components, docs..."
          className="w-full border-b border-(--color-gray) bg-transparent px-4 py-3 font-mono text-sm text-white outline-none placeholder:text-(--color-gray-2)"
        />
        <div className="max-h-80 overflow-y-auto p-2">
          {results.length > 0 ? (
            results.map((item) => (
              <Link
                key={`${item.type}-${item.href}`}
                href={item.href as Route}
                className="hover:bg-accent-muted flex items-center justify-between rounded-md px-3 py-2 text-sm text-(--color-gray-3) transition-colors hover:text-white"
                onClick={() => onOpenChange(false)}
              >
                <span>{item.label}</span>
                <span className="font-mono text-xs text-(--color-gray-2)">
                  {item.type}
                </span>
              </Link>
            ))
          ) : (
            <p className="px-3 py-8 text-center text-sm text-(--color-gray-2)">
              No results found.
            </p>
          )}
        </div>
      </div>
    </div>
  );
}
