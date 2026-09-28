import type { ReactNode } from 'react';

export interface StudioTemplateProps {
  navbar: ReactNode;
  studioContent: ReactNode;
  footer: ReactNode;
}

export function StudioTemplate({
  navbar,
  studioContent,
  footer,
}: StudioTemplateProps) {
  return (
    <div className="bg-background text-foreground flex min-h-screen flex-col">
      {navbar}
      <main className="flex-1">{studioContent}</main>
      {footer}
    </div>
  );
}
