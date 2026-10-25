export interface CopyGateProps {
  /** Part code, e.g. `07`. */
  code: string;
  /** Registry slug, e.g. `button`. */
  name: string;
  /** Text the label copies (`justui add <name>`). */
  text: string;
  /** Accessible name of the label button. */
  label: string;
  /** Announced after a copy. */
  copiedText: string;
  className?: string;
}
