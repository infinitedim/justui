import {
  IBM_Plex_Mono,
  IBM_Plex_Sans,
  Plus_Jakarta_Sans,
} from 'next/font/google';

/** Docs pages UI face (docs identity in `.agents/rules/design.md`). */
export const plexSans = IBM_Plex_Sans({
  subsets: ['latin'],
  weight: ['400', '500', '600', '700'],
  variable: '--font-sans',
});

/**
 * Monospace for code, commands, paths, token names and keys everywhere.
 * The generic fallback keeps code monospace while a face is still loading
 * (the page-curl raster can catch a face mid-load).
 */
export const plexMono = IBM_Plex_Mono({
  subsets: ['latin'],
  weight: ['400', '500'],
  variable: '--font-mono',
  fallback: ['ui-monospace', 'monospace'],
});

/** Ink and Paper face for the landing and the 404 (DP-6). */
export const jakartaSans = Plus_Jakarta_Sans({
  subsets: ['latin'],
  weight: ['400', '500', '600', '700'],
  variable: '--font-jakarta',
});

/** Class names that expose every font variable on `<body>`. */
export const fontVariables = `${plexSans.variable} ${plexMono.variable} ${jakartaSans.variable}`;
