/**
 * Class strings shared by the runner-kit parts. Every preset-dependent value
 * reads an `--ip-*` variable (globals.css, Ink and Paper block), so a part
 * renders correctly in whichever preset its stage region applies.
 */

const motion =
  'transition-[transform,box-shadow,background-color,border-color,color] duration-[120ms] ease-[cubic-bezier(0.16,1,0.3,1)]';

/** Button shell: size-independent shape, motion and press handling. */
export const kitButtonBase = `inline-flex items-center justify-center gap-2 leading-none whitespace-nowrap select-none touch-manipulation cursor-pointer rounded-(--ip-radius-control) border-(length:--ip-line) ${motion} active:shadow-none`;

/** Button heights and paddings. */
export const kitButtonSizes = {
  md: 'h-10 px-4 text-sm',
  sm: 'h-8 px-3 text-[13px]',
  icon: 'size-10 p-0',
} as const satisfies Record<string, string>;

/** Button roles, following spec section 6 Rule A for neobrutalism. */
export const kitButtonVariants = {
  primary:
    'bg-(--ip-part-primary-bg) text-(--ip-part-primary-fg) border-(--ip-part-primary-border) [font-weight:var(--ip-primary-weight)] shadow-(--ip-shadow-primary) hover:bg-(--ip-part-primary-hover) active:bg-(--ip-part-primary-pressed) active:[transform:var(--ip-press-primary)]',
  secondary:
    'bg-transparent text-ip-text-primary border-(--ip-part-secondary-border) [font-weight:var(--ip-secondary-weight)] shadow-(--ip-shadow-secondary) hover:bg-ip-hover active:bg-ip-hover active:[transform:var(--ip-press-secondary)]',
  destructive:
    'bg-(--ip-part-danger-bg) text-(--ip-part-danger-fg) border-(--ip-part-danger-border) [font-weight:var(--ip-primary-weight)] shadow-(--ip-shadow-primary) hover:bg-(--ip-part-danger-pressed) active:bg-(--ip-part-danger-pressed) active:[transform:var(--ip-press-primary)]',
} as const satisfies Record<string, string>;

/** Short text next to a control (switch, checkbox, radio). */
export const kitLabel = 'text-sm font-medium text-ip-text-primary';

/** Label above a field, slider or progress bar. */
export const kitFieldLabel =
  'text-[13px] [font-weight:var(--ip-strong-weight)] text-ip-text-primary';

/** Text field and native select shell. */
export const kitField = `h-10 w-full rounded-(--ip-radius-control) border-(length:--ip-line) border-(--ip-part-control-border) bg-ip-surface px-3 text-sm text-ip-text-primary caret-ip-text-primary ${motion}`;

/** Raised or flat surfaces: cards, toasts, dialogs, sheets, slides. */
export const kitSurface =
  'rounded-(--ip-radius-card) border-(length:--ip-surface-line) border-(--ip-part-container-border) bg-ip-surface';

/** Title inside small cards, dialogs and sheets. */
export const kitCardTitle = 'text-[15px] font-bold text-ip-text-primary';

/** Description under a small card title. */
export const kitCardDescription =
  'mt-1 text-[13px] leading-[19px] text-ip-text-secondary';

/** Lucide icon defaults shared by the parts. */
export const kitIcon = { strokeWidth: 2, 'aria-hidden': true } as const;
