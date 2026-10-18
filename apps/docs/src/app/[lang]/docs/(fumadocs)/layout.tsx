import { DocsLayout } from 'fumadocs-ui/layouts/docs';
import { source } from '@/lib/source';
import { baseOptions } from '@/lib/layout.shared';
import type { ReactNode } from 'react';

export default async function Layout({
  params,
  children,
}: {
  params: Promise<{ lang: string }>;
  children: ReactNode;
}) {
  const lang = (await params).lang;

  const tree = source.pageTree[lang] ??
    source.pageTree['en'] ?? { name: 'Docs', children: [] };

  return (
    <DocsLayout {...baseOptions(lang)} tree={tree}>
      {children}
    </DocsLayout>
  );
}
