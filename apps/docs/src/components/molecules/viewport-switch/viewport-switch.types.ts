export type Viewport = 'mobile' | 'tablet' | 'desktop';

export interface ViewportSwitchProps {
  /** Currently active viewport. */
  value: Viewport;
  /** Change handler. */
  onChange: (viewport: Viewport) => void;
  className?: string;
}
