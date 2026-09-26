'use client';

import { useRouter } from 'next/navigation';
import { useEffect, useMemo, useRef, useState } from 'react';
import { X } from 'lucide-react';
import { SearchResultItem } from '@/components/molecules/search-result-item';
import { getSearchData } from '@/lib/search-data';
import type { SearchModalProps } from './search-modal.types';

export function SearchModal({ open, onOpenChange, lang }: SearchModalProps) {
  const [query, setQuery] = useState('');
  const [selectedIndex, setSelectedIndex] = useState(0);
  const inputRef = useRef<HTMLInputElement>(null);
  const router = useRouter();

  const results = useMemo(() => {
    const data = getSearchData(lang);
    const value = query.trim().toLowerCase();
    if (!value) return data;

    return data.filter((item) =>
      `${item.label} ${item.type}`.toLowerCase().includes(value)
    );
  }, [query, lang]);

  // Reset selected index on query change
  useEffect(() => {
    setSelectedIndex(0);
  }, [query]);

  // Lock body scroll when modal is open
  useEffect(() => {
    if (!open) return;
    const prevOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => {
      document.body.style.overflow = prevOverflow;
    };
  }, [open]);

  // Focus input and handle Escape key
  useEffect(() => {
    if (!open) return;

    inputRef.current?.focus();

    function onKeyDown(event: KeyboardEvent) {
      if (event.key === 'Escape') {
        onOpenChange(false);
      }
    }

    document.addEventListener('keydown', onKeyDown);
    return () => document.removeEventListener('keydown', onKeyDown);
  }, [onOpenChange, open]);

  if (!open) return null;

  const handleKeyDown = (event: React.KeyboardEvent<HTMLInputElement>) => {
    if (event.key === 'ArrowDown') {
      event.preventDefault();
      if (results.length > 0) {
        setSelectedIndex((prev) => (prev + 1) % results.length);
      }
    } else if (event.key === 'ArrowUp') {
      event.preventDefault();
      if (results.length > 0) {
        setSelectedIndex(
          (prev) => (prev - 1 + results.length) % results.length
        );
      }
    } else if (event.key === 'Enter') {
      if (results[selectedIndex]) {
        event.preventDefault();
        onOpenChange(false);
        router.push(results[selectedIndex].href);
      }
    }
  };

  return (
    // eslint-disable-next-line jsx-a11y/click-events-have-key-events, jsx-a11y/no-static-element-interactions
    <div
      data-testid="search-overlay"
      className="fixed inset-0 z-50 flex items-start justify-center bg-black/60 px-4 pt-24 backdrop-blur-sm"
      onClick={(e) => {
        if (e.target === e.currentTarget) onOpenChange(false);
      }}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-label="Search documentation"
        className="border-border bg-card w-full max-w-lg overflow-hidden rounded-xl border shadow-2xl"
      >
        <div className="border-border flex items-center border-b pr-3">
          <input
            ref={inputRef}
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="Search components, docs..."
            className="text-foreground w-full bg-transparent px-4 py-3.5 font-mono text-sm outline-none"
          />
          <button
            type="button"
            onClick={() => onOpenChange(false)}
            aria-label="Close search"
            className="text-muted hover:text-foreground hover:bg-accent-muted rounded p-1 transition-colors"
          >
            <X className="h-4 w-4" />
          </button>
        </div>
        <div className="max-h-80 overflow-y-auto p-2 font-mono">
          {results.length > 0 ? (
            results.map((item, index) => (
              <SearchResultItem
                key={`${item.type}-${item.href}`}
                label={item.label}
                type={item.type}
                href={item.href}
                isSelected={index === selectedIndex}
                onMouseEnter={() => setSelectedIndex(index)}
                onClick={() => onOpenChange(false)}
              />
            ))
          ) : (
            <p className="text-muted px-3 py-8 text-center text-sm">
              No results found.
            </p>
          )}
        </div>
      </div>
    </div>
  );
}
