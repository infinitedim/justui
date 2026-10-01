export interface CategoryFilterPillProps {
  /** Category label text. */
  label: string;
  /** Whether this category is currently selected. */
  active?: boolean;
  /** Click handler for selection. */
  onClick?: () => void;
  className?: string;
}
