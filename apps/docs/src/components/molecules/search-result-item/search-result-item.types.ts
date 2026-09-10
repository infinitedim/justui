export interface SearchResultItemProps {
  /** Display label. */
  label: string;
  /** Type/category tag (e.g. "component", "doc"). */
  type: string;
  /** Navigation href. */
  href: string;
  /** Click handler (e.g. to close modal). */
  onClick?: () => void;
  className?: string;
}
