export interface CopyButtonProps {
  /** The text to copy to clipboard. */
  text: string;
  /** Accessible label. */
  label?: string;
  /** Announced to screen readers after a successful copy. */
  copiedLabel?: string;
  className?: string;
}
