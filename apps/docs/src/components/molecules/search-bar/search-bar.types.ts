export interface SearchBarProps {
  /** Keyboard shortcut label to display (e.g. "Ctrl K"). */
  shortcut?: string;
  /** Placeholder text. */
  placeholder?: string;
  /** Click handler to open the full search modal. */
  onActivate?: () => void;
  /** Accessible label. */
  label?: string;
  className?: string;
}
