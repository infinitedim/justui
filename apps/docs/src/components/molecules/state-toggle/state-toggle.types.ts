export interface StateToggleProps {
  /** Current boolean state. */
  value: boolean;
  /** Toggle handler. */
  onChange: (next: boolean) => void;
  /** Label text. */
  label: string;
  className?: string;
}
