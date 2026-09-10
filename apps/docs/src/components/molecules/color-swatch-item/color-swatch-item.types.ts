export interface ColorSwatchItemProps {
  /** CSS color value to display. */
  color: string;
  /** Token label (e.g. "--just-accent"). */
  label: string;
  /** Hex or HSL string value. */
  value: string;
  /** Whether this swatch is currently selected. */
  active?: boolean;
  onClick?: () => void;
  className?: string;
}
