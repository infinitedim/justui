/**
 * Reusable class strings built only from --just-* tokens. Every preset
 * difference (border width, radius, offset shadow, press motion) comes from
 * the token set applied to <body> or a preview scope, never from branching
 * on the preset in a component.
 */

/** Token border: color, width. */
export const tokenBorder = 'border-border border-(length:--just-border-width)';

/** Flat surface: card background, token border and radius. */
export const surface = `bg-card ${tokenBorder} rounded-(--just-radius-md)`;

/** Surface with the preset's elevation (flat offset shadow in neobrutalism). */
export const raised = `${surface} shadow-sm`;

/** Keyboard focus indicator used across the site. */
export const focusRing =
  'focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-accent';

/** Solid accent control that presses with the preset's motion. */
export const accentControl = `just-press bg-accent text-accent-foreground ${tokenBorder} rounded-(--just-radius-md) shadow-xs font-medium ${focusRing}`;

/** Neutral control (secondary button, chip, tab). */
export const neutralControl = `just-press bg-card text-foreground ${tokenBorder} rounded-(--just-radius-md) ${focusRing}`;

/** Text link in the accent color that passes AA in every preset. */
export const accentLink = `text-accent-text underline-offset-4 hover:underline ${focusRing}`;
