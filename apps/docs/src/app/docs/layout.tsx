import { DocsLayout } from 'fumadocs-ui/layouts/docs';
import { source } from '@/lib/source';
import type { ReactNode } from 'react';

export default function Layout({ children }: { children: ReactNode }) {
  return (
    <DocsLayout
      tree={source.pageTree}
      githubUrl="https://github.com/yourblooo/justui"
      nav={{
        title: 'JustUI Docs',
      }}
    >
      {children}
    </DocsLayout>
  );
}
