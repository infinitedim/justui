import type { ReactNode } from 'react';

export interface CatalogTemplateProps {
  navbar: ReactNode;
  header: ReactNode;
  catalog: ReactNode;
  footer: ReactNode;
}

export function CatalogTemplate({
  navbar,
  header,
  catalog,
  footer,
}: CatalogTemplateProps) {
  return (
    <div className="bg-background text-foreground flex min-h-screen flex-col">
      {navbar}
      <main className="mx-auto w-full max-w-6xl flex-1 px-4 py-16 sm:px-6 lg:px-8">
        <div className="mb-10">{header}</div>
        {catalog}
      </main>
      {footer}
    </div>
  );
}
