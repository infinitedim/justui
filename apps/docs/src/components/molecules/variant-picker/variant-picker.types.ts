export interface VariantOption {
  value: string;
  label: string;
}

export interface VariantPickerProps {
  /** Available variant options. */
  options: VariantOption[];
  /** Currently selected value. */
  value: string;
  /** Change handler. */
  onChange: (value: string) => void;
  /** Accessible group label. */
  label?: string;
  className?: string;
}
