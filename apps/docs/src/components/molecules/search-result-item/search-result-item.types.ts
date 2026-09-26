import type { Route } from 'next';

export interface SearchResultItemProps {
  /** Display label. */
  label: string;
  /** Type/category tag (e.g. "component", "doc"). */
  type: string;
  /** Navigation href. */
  href: Route;
  /** Click handler (e.g. to close modal). */
  onClick?: () => void;
  /** Highlights the item as the keyboard-selected result. */
  isSelected?: boolean;
  /** Pointer-enter handler, used to sync keyboard and mouse selection. */
  onMouseEnter?: () => void;
  className?: string;
}
