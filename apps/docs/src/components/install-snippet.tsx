'use client';

import { Check, Copy } from 'lucide-react';
import { useState } from 'react';
import { getHomepageDictionary } from '@/lib/homepage-translations';

const command = 'flutter pub add just_ui_core';

export function InstallSnippet({ lang = 'en' }: { lang?: string }) {
  const [copied, setCopied] = useState(false);
  const t = getHomepageDictionary(lang);

  async function copyCommand() {
    await navigator.clipboard.writeText(command);
    setCopied(true);
    window.setTimeout(() => setCopied(false), 2000);
  }

  return (
    <button
      type="button"
      onClick={copyCommand}
      className="border-border text-secondary hover:border-accent-dark hover:text-foreground inline-flex max-w-full items-center gap-4 rounded-md border bg-transparent px-4 py-3 font-mono text-sm transition-colors"
      aria-label={t.copyCommand}
    >
      <code className="overflow-x-auto">{command}</code>
      {copied ? (
        <Check size={16} className="text-accent shrink-0" aria-hidden="true" />
      ) : (
        <Copy
          size={16}
          className="shrink-0 cursor-pointer"
          aria-hidden="true"
        />
      )}
    </button>
  );
}
