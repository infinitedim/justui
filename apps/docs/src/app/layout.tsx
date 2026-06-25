import type { ReactNode } from 'react';
import { IBM_Plex_Mono, IBM_Plex_Sans } from 'next/font/google';
import { ThemeProvider } from 'next-themes';
import './globals.css';

const sans = IBM_Plex_Sans({
  subsets: ['latin'],
  weight: ['400', '500'],
  variable: '--font-sans',
});

const mono = IBM_Plex_Mono({
  subsets: ['latin'],
  weight: ['400', '500'],
  variable: '--font-mono',
});

export const metadata = {
  title: 'JustUI Documentation',
  description: 'Beautiful, accessible, copy-paste Flutter UI components.',
};

/**
 * Root layout renders <html>, <body>, and ThemeProvider exactly once.
 * By keeping ThemeProvider here (not in [lang]/layout), it does NOT re-render
 * when the user switches locales — preventing the React 19 inline-script warning
 * that next-themes triggers on every client re-render of ThemeProvider.
 */
export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    // lang is set client-side by HtmlLang in [lang]/layout.tsx.
    // suppressHydrationWarning silences the initial SSR mismatch.
    <html suppressHydrationWarning>
      <head />
      <body
        className={`${sans.variable} ${mono.variable} theme-neobrutalism bg-background text-foreground flex min-h-screen flex-col font-sans antialiased`}
      >
        <ThemeProvider
          attribute="class"
          defaultTheme="system"
          enableSystem
          disableTransitionOnChange
        >
          {children}
        </ThemeProvider>
      </body>
    </html>
  );
}
