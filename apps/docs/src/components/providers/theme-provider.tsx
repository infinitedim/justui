'use client';

import { ThemeProvider as NextThemesProvider } from 'next-themes';
import type { ComponentProps } from 'react';
import { env } from '@/lib/env';

// Suppress the React 19 / Next.js 16 warning about the next-themes inline <script> tag
// in development. next-themes injects an inline script to prevent FOUC; React warns about
// it but it is harmless. The message text changed across React versions, so we match both.
if (typeof window !== 'undefined' && env.NODE_ENV === 'development') {
  const originalError = console.error;
  console.error = (...args) => {
    if (
      typeof args[0] === 'string' &&
      (args[0].includes(
        'Encountered a script tag while rendering React component'
      ) ||
        args[0].includes(
          'Cannot render a sync or defer <script> outside the main document'
        ))
    ) {
      return;
    }
    originalError.apply(console, args);
  };
}

export function ThemeProvider({
  children,
  ...props
}: ComponentProps<typeof NextThemesProvider>) {
  return <NextThemesProvider {...props}>{children}</NextThemesProvider>;
}
