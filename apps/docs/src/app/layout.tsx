import { SITE_URL } from '@/lib/site';
import type { Metadata } from 'next';
import type { ReactNode } from 'react';
import { ThemeProvider, PresetProvider } from '@/components/providers';
import './globals.css';

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    template: '%s | JustUI',
    default: 'JustUI Documentation',
  },
  description: 'Beautiful, accessible, copy-paste Flutter UI components.',
};

/**
 * Root layout wraps children with ThemeProvider and PresetProvider.
 * By keeping ThemeProvider here (above [lang]/layout), it does NOT re-render
 * when the user switches locales -- preventing the React 19 inline-script warning
 * that next-themes triggers on every client re-render of ThemeProvider.
 */
export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <ThemeProvider
      attribute="class"
      defaultTheme="system"
      enableSystem
      disableTransitionOnChange
    >
      <PresetProvider>{children}</PresetProvider>
    </ThemeProvider>
  );
}
