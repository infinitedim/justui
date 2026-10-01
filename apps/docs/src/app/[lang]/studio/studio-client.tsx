'use client';

import { useState } from 'react';
import { RotateCcw, Share2, Check } from 'lucide-react';
import {
  ThemeStudioProvider,
  useThemeStudio,
} from '@/lib/theme-studio-context';
import { ThemeConfigurator } from '@/components/organisms/theme-configurator';
import { PhoneMockupCanvas } from '@/components/organisms/phone-mockup-canvas';
import { CodeExportDrawer } from '@/components/organisms/code-export-drawer';
import { getStudioDictionary } from '@/lib/theme-studio-translations';
import { Button } from '@/components/atoms/button';
import type { ColorSpace } from '@/lib/theme/color-resolver';

interface StudioClientProps {
  lang: string;
  initialSeedColor?: string;
  initialIsDark?: boolean;
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
    <div className="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
      {/* Studio Header Toolbar */}
      <div className="mb-8 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-foreground text-3xl font-medium tracking-tight sm:text-4xl">
            {t.title}
          </h1>
          <p className="text-secondary mt-1 max-w-2xl text-sm leading-relaxed sm:text-base">
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
      <div className="grid grid-cols-1 gap-8 lg:grid-cols-12 lg:items-start">
        {/* Left Column: Configurator Panel */}
        <div className="order-2 lg:order-1 lg:col-span-6 xl:col-span-5">
          <ThemeConfigurator lang={lang} />
        </div>

        {/* Right Column: Phone Mockup Canvas (sticky on desktop) */}
        <div className="order-1 flex justify-center lg:sticky lg:top-20 lg:order-2 lg:col-span-6 xl:col-span-7">
          <PhoneMockupCanvas lang={lang} />
        </div>

        {/* Bottom Full Width: Code Export Drawer */}
        <div className="order-3 col-span-12 mt-4">
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
  initialColorSpace,
}: StudioClientProps) {
  return (
    <ThemeStudioProvider
      initialSeedColor={initialSeedColor}
      initialIsDark={initialIsDark}
      initialColorSpace={initialColorSpace}
    >
      <StudioContent lang={lang} />
    </ThemeStudioProvider>
  );
}
