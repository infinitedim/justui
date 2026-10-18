import type { InkPaperPageProps } from './ink-paper-page.types';

/**
 * Page shell for the landing and the 404. `.ink-paper` scopes the Ink and
 * Paper tokens and Plus Jakarta Sans to this tree; `data-page-root` marks
 * what the theme-switch page curl rasterizes.
 */
export function InkPaperPage({ nav, footer, children }: InkPaperPageProps) {
  return (
    <div data-page-root className="ink-paper flex min-h-screen flex-1 flex-col">
      {nav}
      <main className="flex-1">{children}</main>
      {footer}
    </div>
  );
}
