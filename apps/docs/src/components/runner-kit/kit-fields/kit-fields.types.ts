/** Validation rule applied while the visitor types. */
export type KitInputRule = 'project' | 'email';

export interface KitInputProps {
  label: string;
  defaultValue: string;
  rule: KitInputRule;
  /** Shown with an error icon when the value breaks the rule. */
  errorMessage: string;
  type?: 'text' | 'email';
  className?: string;
}

export interface KitSelectProps {
  label: string;
  options: readonly string[];
  className?: string;
}
