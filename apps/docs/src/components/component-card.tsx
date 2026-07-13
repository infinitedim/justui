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
      className="hover:border-accent-dark hover:bg-accent-muted border-border rounded-lg border p-4 transition-colors"
    >
      <h3 className="text-foreground text-sm font-medium">{component.name}</h3>
      <p className="text-muted mt-2 text-xs leading-5">
        {component.description}
      </p>
    </Link>
  );
}
