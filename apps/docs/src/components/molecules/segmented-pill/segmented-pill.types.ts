export interface SegmentedPillOption<T extends string> {
  value: T;
  label: string;
}

export interface SegmentedPillProps<T extends string> {
  /** Accessible name of the group. */
  label: string;
  options: ReadonlyArray<SegmentedPillOption<T>>;
  value: T;
  onChange: (value: T) => void;
  /** `tabs` renders a tablist with roving focus; `toggle` uses aria-pressed. */
  kind?: 'tabs' | 'toggle';
  className?: string;
}
