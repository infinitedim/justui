import type { ReactNode } from 'react';

export interface LandingTemplateProps {
  navbar: ReactNode;
  hero: ReactNode;
  workbench?: ReactNode;
  installStrip: ReactNode;
  whatYouGet: ReactNode;
  componentShowcase: ReactNode;
  footer: ReactNode;
}

export function LandingTemplate({
  navbar,
  hero,
  workbench,
  installStrip,
  whatYouGet,
  componentShowcase,
  footer,
}: LandingTemplateProps) {
  return (
    <div className="bg-background text-foreground flex min-h-screen flex-col">
      {navbar}
      <main className="flex-1">
        {/* Centered Hero Narrative */}
        <section className="mx-auto max-w-5xl px-4 pt-16 pb-8 text-center sm:px-6 sm:pt-20 sm:pb-10 lg:px-8 lg:pt-24 lg:pb-12">
          {hero}
          {installStrip && (
            <div className="mt-10 flex w-full justify-center">
              {installStrip}
            </div>
          )}
        </section>

        {/* Interactive Workbench Showcase */}
        {workbench && (
          <section className="mx-auto mb-20 max-w-6xl px-4 sm:mb-24 sm:px-6 lg:px-8">
            {workbench}
          </section>
        )}

        {/* What you actually get */}
        <section className="mx-auto max-w-6xl px-4 py-20 sm:px-6 lg:px-8">
          {whatYouGet}
        </section>

        {/* Component Showcase Grid */}
        <section className="mx-auto max-w-6xl px-4 pb-24 sm:px-6 lg:px-8">
          {componentShowcase}
        </section>
      </main>
      {footer}
    </div>
  );
}
