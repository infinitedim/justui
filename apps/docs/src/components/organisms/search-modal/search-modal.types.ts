export interface SearchModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  /** Active locale code used to build result links. */
  lang: string;
}
