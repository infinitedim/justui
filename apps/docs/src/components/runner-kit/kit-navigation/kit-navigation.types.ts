export interface KitTabsProps {
  /** Accessible name of the tab list. */
  label: string;
  tabs: readonly string[];
  className?: string;
}

export interface KitBreadcrumbProps {
  label: string;
  trail: readonly string[];
  current: string;
  className?: string;
}

export interface KitItemListProps {
  /** Accessible name of the group. */
  label: string;
  items: readonly string[];
  defaultIndex?: number;
  className?: string;
}
