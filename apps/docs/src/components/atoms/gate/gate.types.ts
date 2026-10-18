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
