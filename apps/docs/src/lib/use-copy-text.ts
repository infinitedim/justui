'use client';

import { useEffect, useRef, useState } from 'react';

const RESET_MS = 1600;

/** State and action of a copy-to-clipboard control. */
export interface CopyText {
  /** True for 1.6s after a successful copy. */
  copied: boolean;
  /** Writes [text] to the clipboard. */
  copy: () => Promise<void>;
}

/**
 * Copies [text] to the clipboard and reports `copied` for 1.6s. A denied
 * clipboard (insecure context, permissions) leaves `copied` false; the text
 * stays on screen to select by hand.
 */
export function useCopyText(text: string): CopyText {
  const [copied, setCopied] = useState(false);
  const timer = useRef<number | undefined>(undefined);

  useEffect(() => () => window.clearTimeout(timer.current), []);

  async function copy() {
    try {
      await navigator.clipboard.writeText(text);
      setCopied(true);
      window.clearTimeout(timer.current);
      timer.current = window.setTimeout(() => setCopied(false), RESET_MS);
    } catch {
      // Intentional fallback: clipboard access can be denied (insecure
      // context, permissions); the command stays visible to select by hand.
    }
  }

  return { copied, copy };
}
