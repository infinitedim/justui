export interface KitDatePickerProps {
  month: string;
  /** Accessible name of the day group. */
  label: string;
  className?: string;
}

export interface KitTableProps {
  columns: readonly [string, string];
  rows: ReadonlyArray<readonly [string, string]>;
  className?: string;
}

export interface KitTimePickerProps {
  hours: string;
  minutes: string;
  className?: string;
}
