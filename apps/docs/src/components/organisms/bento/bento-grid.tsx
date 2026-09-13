import { cn } from '@/lib/cn';
import { getHomepageDictionary } from '@/lib/homepage-translations';
import { Badge } from '@/components/atoms/badge';
import {
  BentoZeroDependency,
  BentoContrastAuditor,
  BentoAspectRebuild,
  BentoNeobrutalism,
  BentoCliWorkflow,
} from './cards';

interface BentoGridProps {
  lang?: string;
  className?: string;
}

export function BentoGrid({ lang = 'en', className }: BentoGridProps) {
  const t = getHomepageDictionary(lang);

  return (
    <section className={cn('relative flex flex-col items-center', className)}>
      {/* Section Header */}
      <div className="mx-auto flex max-w-2xl flex-col items-center text-center">
        <Badge variant="outline">
          {t.bentoBadge}
        </Badge>
        <h2 className="text-foreground mt-4 font-mono text-3xl font-bold tracking-tight sm:text-4xl">
          {t.bentoHeading}
        </h2>
        <p className="text-muted mt-3 text-sm leading-relaxed sm:text-base">
          {t.bentoDescription}
        </p>
      </div>

      {/* 5-Card Responsive Bento Grid */}
      <div className="mt-12 grid w-full grid-cols-12 gap-4 lg:gap-6">
        {/* Row 1: Zero-Dep (7 cols) + Contrast Auditor (5 cols) */}
        <BentoZeroDependency
          title={t.bentoCard1Title}
          description={t.bentoCard1Desc}
          className="col-span-12 lg:col-span-7"
        />

        <BentoContrastAuditor
          title={t.bentoCard2Title}
          description={t.bentoCard2Desc}
          className="col-span-12 lg:col-span-5"
        />

        {/* Row 2: Aspect Rebuilds (5 cols) + Neobrutalism Physics (7 cols) */}
        <BentoAspectRebuild
          title={t.bentoCard3Title}
          description={t.bentoCard3Desc}
          className="col-span-12 lg:col-span-5"
        />

        <BentoNeobrutalism
          title={t.bentoCard4Title}
          description={t.bentoCard4Desc}
          className="col-span-12 lg:col-span-7"
        />

        {/* Row 3: Modern Dart 3 DX & CLI (Full 12 cols) */}
        <BentoCliWorkflow
          title={t.bentoCard5Title}
          description={t.bentoCard5Desc}
          className="col-span-12"
        />
      </div>
    </section>
  );
}
