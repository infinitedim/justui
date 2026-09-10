export interface LightnessSliderProps {
  /** Current lightness value 0-100. */
  value: number;
  /** Change handler. */
  onChange: (value: number) => void;
  /** Optional label. */
  label?: string;
  className?: string;
}
