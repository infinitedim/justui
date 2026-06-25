'use client';

import { Check, Copy } from 'lucide-react';
import { useState } from 'react';

const command = 'flutter pub add just_ui_core';

export function InstallSnippet() {
  const [copied, setCopied] = useState(false);

  async function copyCommand() {
    await navigator.clipboard.writeText(command);
    setCopied(true);
    window.setTimeout(() => setCopied(false), 2000);
  }

  return (
    <button
      type="button"
      onClick={copyCommand}
      className="inline-flex max-w-full items-center gap-4 rounded-md border border-(--color-gray) bg-transparent px-4 py-3 font-mono text-sm text-(--color-gray-3) transition-colors hover:border-accent-dark hover:text-white"
      aria-label="Copy install command"
    >
      <code className="overflow-x-auto">{command}</code>
      {copied ? (
        <Check size={16} className="shrink-0 text-accent" aria-hidden="true" />
      ) : (
        <Copy size={16} className="shrink-0" aria-hidden="true" />
      )}
    </button>
  );
}
