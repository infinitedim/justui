'use client';

import { useState } from 'react';
import { RotateCcw, Share2, Check } from 'lucide-react';
import {
  ThemeStudioProvider,
  useThemeStudio,
} from '@/lib/theme-studio-context';
import { ThemeConfigurator } from '@/components/organisms/theme-configurator';
import { StudioPreview } from '@/components/organisms/studio-preview';
import { CodeExportDrawer } from '@/components/organisms/code-export-drawer';
import { getStudioDictionary } from '@/lib/theme-studio-translations';
import { Button } from '@/components/atoms/button';
import type { ColorSpace, JustUIPreset } from '@/lib/theme/color-resolver';

interface StudioClientProps {
  lang: string;
  initialSeedColor?: string;
  initialIsDark?: boolean;
  initialPreset?: JustUIPreset;
  initialColorSpace?: ColorSpace;
}

function StudioContent({ lang }: { lang: string }) {
  const t = getStudioDictionary(lang);
  const { reset, shareUrl } = useThemeStudio();
  const [copiedShare, setCopiedShare] = useState<boolean>(false);

  const handleShare = async () => {
    if (typeof navigator !== 'undefined' && navigator.clipboard) {
      try {
        await navigator.clipboard.writeText(shareUrl);
        setCopiedShare(true);
        setTimeout(() => setCopiedShare(false), 2000);
      } catch {
        // Ignore clipboard failure in restricted environments
      }
    }
  };

  return (
    <div className="mx-auto max-w-6xl px-4 py-16 sm:px-6 lg:px-8">
      <div className="mb-10 flex flex-col gap-6 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <h1 className="text-foreground text-4xl font-medium tracking-tight sm:text-5xl">
            {t.title}
          </h1>
          <p className="text-secondary mt-4 max-w-xl text-base leading-relaxed">
            {t.subtitle}
          </p>
        </div>

        {/* Global Toolbar Actions */}
        <div className="flex shrink-0 items-center gap-2.5">
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={reset}
            className="flex items-center gap-1.5"
            aria-label={t.reset}
          >
            <RotateCcw className="h-3.5 w-3.5" />
            <span>{t.reset}</span>
          </Button>

          <Button
            type="button"
            variant="primary"
            size="sm"
            onClick={handleShare}
            className="flex items-center gap-1.5"
            aria-label={t.share}
          >
            {copiedShare ? (
              <>
                <Check className="h-3.5 w-3.5" />
                <span>{t.copied}</span>
              </>
            ) : (
              <>
                <Share2 className="h-3.5 w-3.5" />
                <span>{t.share}</span>
              </>
            )}
          </Button>
        </div>
      </div>

      {/* Main Studio Interactive Grid */}
      <div className="grid gap-8 lg:grid-cols-12 lg:items-start">
        {/* Left Column: Configurator Panel */}
        <div className="order-2 lg:order-1 lg:col-span-6 xl:col-span-5">
          <ThemeConfigurator lang={lang} />
        </div>

        {/* Right column: the resolved palette applied to real components */}
        <div className="order-1 flex justify-center lg:sticky lg:top-20 lg:order-2 lg:col-span-6 xl:col-span-7">
          <StudioPreview lang={lang} />
        </div>

        {/* Bottom Full Width: Code Export Drawer */}
        <div className="order-3 mt-4 lg:col-span-12">
          <CodeExportDrawer lang={lang} />
        </div>
      </div>
    </div>
  );
}

export function StudioClient({
  lang,
  initialSeedColor,
  initialIsDark,
  initialPreset,
  initialColorSpace,
}: StudioClientProps) {
  return (
    <ThemeStudioProvider
      initialSeedColor={initialSeedColor}
      initialIsDark={initialIsDark}
      initialPreset={initialPreset}
      initialColorSpace={initialColorSpace}
    >
      <StudioContent lang={lang} />
    </ThemeStudioProvider>
  );
}
