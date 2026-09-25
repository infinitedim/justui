import type { ReactNode } from 'react';

export interface LandingTemplateProps {
  navbar: ReactNode;
  hero: ReactNode;
  workbench?: ReactNode;
  installStrip: ReactNode;
  bentoGrid: ReactNode;
  componentShowcase: ReactNode;
  footer: ReactNode;
}

export function LandingTemplate({
  navbar,
  hero,
  workbench,
  installStrip,
  bentoGrid,
  componentShowcase,
  footer,
}: LandingTemplateProps) {
  return (
    <div className="bg-background text-foreground min-h-screen flex flex-col">
      {navbar}
      <main className="flex-1">
        {/* Centered Hero Narrative */}
        <section className="mx-auto max-w-5xl px-4 pt-16 pb-8 sm:px-6 sm:pt-20 sm:pb-10 lg:px-8 lg:pt-24 lg:pb-12 text-center">
          {hero}
          {installStrip && (
            <div className="mt-10 flex w-full justify-center">
              {installStrip}
            </div>
          )}
        </section>

        {/* Interactive Workbench Showcase */}
        {workbench && (
          <section className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8 mb-20 sm:mb-24">
            {workbench}
          </section>
        )}

        {/* Bento Grid */}
        <section className="mx-auto max-w-6xl px-4 py-20 sm:px-6 lg:px-8">
          {bentoGrid}
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
