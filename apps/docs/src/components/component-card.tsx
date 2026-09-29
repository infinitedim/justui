import Link from 'next/link';
import type { ComponentMeta } from '@/lib/components-data';

interface ComponentCardProps {
  component: ComponentMeta;
  lang: string;
}

export function ComponentCard({ component, lang }: ComponentCardProps) {
  return (
    <Link
      href={`/${lang}/docs/components/${component.slug}`}
      className="just-press bg-card border-border hover:border-accent hover:bg-accent-muted rounded-(--just-radius-md) border-(length:--just-border-width) shadow-solid p-4 block"
    >
      <h3 className="text-foreground text-sm font-medium">{component.name}</h3>
      <p className="text-muted mt-2 text-xs leading-5">
        {component.description}
      </p>
    </Link>
  );
}
