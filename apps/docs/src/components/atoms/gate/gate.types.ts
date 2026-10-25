export interface GateProps {
  /** Part code, e.g. `07`. */
  code: string;
  /** Registry slug, e.g. `button`. */
  name: string;
  /** The part is the one being cut: its gate narrows and its label inverts. */
  selected: boolean;
  /** Omit to render a static label (no button). */
  onSelect?: () => void;
  className?: string;
}

export interface GateLinesProps {
  /** Pull the lines to 45%, as a gate does while its part is cut. */
  narrow?: boolean;
}
