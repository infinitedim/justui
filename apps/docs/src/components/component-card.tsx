import Link from 'next/link';
import type { Route } from 'next';
import type { ComponentMeta } from '@/lib/components-data';

interface ComponentCardProps {
  component: ComponentMeta;
  lang: string;
}

export function ComponentCard({ component, lang }: ComponentCardProps) {
  return (
    <Link
      href={`/${lang}/docs/components/${component.slug}` as Route}
      className="hover:border-accent-dark hover:bg-accent-muted rounded-lg border border-border p-4 transition-colors"
    >
      <h3 className="text-sm font-medium text-foreground">{component.name}</h3>
      <p className="mt-2 text-xs leading-5 text-muted">
        {component.description}
      </p>
    </Link>
  );
}

