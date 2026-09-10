export interface CategoryFilterPillProps {

  /** Category label text. */
  label: string;
  /** Number of components in this category. */
  count?: number;
  /** Whether this category is currently selected. */
  active?: boolean;
  /** Click handler for selection. */
  onClick?: () => void;
  className?: string;
}
