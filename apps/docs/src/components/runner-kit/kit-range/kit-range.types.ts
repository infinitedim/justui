export interface KitSliderProps {
  label: string;
  defaultValue?: number;
  className?: string;
}

export interface KitProgressProps {
  label: string;
  /** 0 to 100. */
  value: number;
  className?: string;
}
