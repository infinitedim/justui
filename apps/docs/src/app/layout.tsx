import type { ReactNode } from 'react';
import './globals.css';

export const metadata = {
  title: 'JustUI Documentation',
  description: 'Beautiful, accessible, copy-paste Flutter UI components.',
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return children;
}
