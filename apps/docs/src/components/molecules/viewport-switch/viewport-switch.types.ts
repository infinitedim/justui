export type Viewport = 'mobile' | 'tablet' | 'desktop';

export interface ViewportSwitchLabels {
  /** Accessible name of the radio group. */
  group: string;
  mobile: string;
  tablet: string;
  desktop: string;
}

export interface ViewportSwitchProps {
  /** Currently active viewport. */
  value: Viewport;
  /** Change handler. */
  onChange: (viewport: Viewport) => void;
  /** Localized labels; English when omitted. */
  labels?: ViewportSwitchLabels;
  className?: string;
}
