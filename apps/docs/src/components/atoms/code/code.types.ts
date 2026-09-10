import type { HTMLAttributes, ReactNode } from 'react';

export interface CodeProps extends HTMLAttributes<HTMLElement> {
  /** Whether to render as a block-level <pre><code> instead of inline <code>. */
  block?: boolean;
  children?: ReactNode;
}
