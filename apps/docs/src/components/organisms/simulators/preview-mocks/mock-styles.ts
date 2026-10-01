/**
 * Shared class lists for the catalog mocks. Every value is a --just-* token,
 * so the active preset (default or neobrutalism) restyles the mocks without
 * a single preset branch in component code.
 *
 * All mocks show one small app, an online shop's order screen, so the
 * catalog reads like one product rather than 33 unrelated demos.
 */
export const surface =
  'bg-card text-foreground border-border border-(length:--just-border-width) rounded-(--just-radius-md)';

export const raised = `${surface} shadow-sm`;

const control =
  'just-press inline-flex h-9 items-center justify-center gap-1.5 px-3.5 text-sm font-medium select-none focus-visible:outline-accent focus-visible:outline-2 focus-visible:outline-offset-2';

export const primaryButton = `${control} bg-accent text-accent-foreground border-border border-(length:--just-border-width) rounded-(--just-radius-md) shadow-sm`;

export const outlineButton = `${control} bg-card text-foreground border-border border-(length:--just-border-width) rounded-(--just-radius-md) hover:bg-accent-muted`;

export const focusRing =
  'focus-visible:outline-accent focus-visible:outline-2 focus-visible:outline-offset-2';

export const label = 'text-secondary text-xs font-medium';

export const hint = 'text-muted text-xs';
