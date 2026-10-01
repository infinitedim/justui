'use client';

import { useState, type CSSProperties } from 'react';
import { Check } from 'lucide-react';
import { cn } from '@/lib/cn';
import { useThemeStudio } from '@/lib/theme-studio-context';
import { getStudioDictionary } from '@/lib/theme-studio-translations';
import {
  outlineButton,
  primaryButton,
  raised,
  surface,
} from '@/components/organisms/simulators/preview-mocks/mock-styles';
import type { StudioPreviewProps } from './studio-preview.types';

/**
 * A 375px screen built from the same token-driven pieces as the catalog,
 * restyled with the palette the studio resolved. Nothing here is specific to
 * the studio: change the tokens and the components follow.
 */
export function StudioPreview({ lang = 'en', className }: StudioPreviewProps) {
  const t = getStudioDictionary(lang);
  const { resolvedTokens: tokens, preset, isDark } = useThemeStudio();
  const [notify, setNotify] = useState(true);

  const scope = {
    '--just-background': tokens.background,
    '--just-card-bg': tokens.card,
    '--just-elevated-bg': tokens.card,
    '--just-text-primary': tokens.textPrimary,
    '--just-text-secondary': tokens.textSecondary,
    '--just-text-muted': tokens.textSecondary,
    '--just-accent': tokens.accent,
    '--just-accent-foreground': tokens.accentForeground,
    '--just-accent-muted': `${tokens.accent}1f`,
    '--just-border': tokens.border,
    '--just-border-width': tokens.borderWidth,
    '--just-fill': tokens.border,
    '--just-success': tokens.success,
    '--just-warning': tokens.warning,
    '--just-error': tokens.error,
    '--just-radius-sm': tokens.radiusMd,
    '--just-radius-md': tokens.radiusMd,
    '--just-radius-lg': tokens.radiusLg,
    '--just-shadow-xs': tokens.shadowSolid,
    '--just-shadow-sm': tokens.shadowSolid,
    '--just-shadow-md': tokens.shadowSolid,
    '--just-shadow-solid': tokens.shadowSolid,
    colorScheme: isDark ? 'dark' : 'light',
  } as CSSProperties;

  return (
    <figure
      data-testid="studio-preview"
      className={cn('w-full max-w-[375px]', className)}
    >
      <div
        style={scope}
        className={cn(
          preset === 'neobrutalism' ? 'theme-neobrutalism' : 'preset-default',
          'bg-background text-foreground border-border overflow-hidden rounded-(--just-radius-lg) border-(length:--just-border-width)'
        )}
      >
        <div className="border-border border-b border-b-(length:--just-border-width) px-5 py-4">
          <p className="text-secondary text-xs">{t.previewOrder}</p>
          <h2 className="mt-0.5 text-lg font-semibold">{t.previewTitle}</h2>
        </div>

        <div className="space-y-5 p-5">
          <div className="space-y-1.5">
            <label
              htmlFor="studio-preview-email"
              className="text-secondary block text-xs font-medium"
            >
              {t.previewEmail}
            </label>
            <input
              id="studio-preview-email"
              type="email"
              defaultValue={t.previewEmailValue}
              className={cn(
                surface,
                'h-10 w-full px-3 text-sm outline-none',
                'focus-visible:outline-accent focus-visible:outline-2 focus-visible:outline-offset-1'
              )}
            />
          </div>

          <button
            type="button"
            role="switch"
            aria-checked={notify}
            onClick={() => setNotify((n) => !n)}
            className="flex w-full items-center justify-between gap-3 text-left text-sm"
          >
            <span>{t.previewNotify}</span>
            <span
              className={cn(
                'border-border relative inline-block h-7 w-12 shrink-0 rounded-full border-(length:--just-border-width)',
                notify ? 'bg-accent' : 'bg-fill'
              )}
            >
              <span
                className={cn(
                  'bg-foreground absolute top-1/2 h-4.5 w-4.5 -translate-y-1/2 rounded-full',
                  notify ? 'right-0.75' : 'left-0.75'
                )}
              />
            </span>
          </button>

          <div className={cn(raised, 'p-4')}>
            <div className="flex items-center justify-between gap-2">
              <span className="text-sm font-medium">{t.previewItem}</span>
              <span className="bg-accent text-accent-foreground border-border rounded-(--just-radius-sm) border-(length:--just-border-width) px-2 py-0.5 text-xs font-medium">
                {t.previewBadge}
              </span>
            </div>
            <p className="text-secondary mt-1 text-sm">{t.previewItemMeta}</p>
          </div>

          <div className="flex gap-2">
            <button type="button" className={cn(primaryButton, 'flex-1')}>
              {t.previewSave}
            </button>
            <button type="button" className={cn(outlineButton, 'flex-1')}>
              {t.previewCancel}
            </button>
          </div>

          <div
            role="status"
            className={cn(raised, 'flex items-center gap-2 px-3 py-2 text-sm')}
          >
            <Check className="text-success h-4 w-4" aria-hidden="true" />
            {t.previewToast}
          </div>
        </div>
      </div>
      <figcaption className="text-muted mt-2 text-center text-xs">
        375 px
      </figcaption>
    </figure>
  );
}
