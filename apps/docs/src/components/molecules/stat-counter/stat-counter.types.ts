export interface StatCounterProps {
  /** Numeric value to display. */
  value: number | string;
  /** Label below the number. */
  label: string;
  /** Optional unit suffix (e.g. "ms", "KB"). */
  unit?: string;
  className?: string;
}
