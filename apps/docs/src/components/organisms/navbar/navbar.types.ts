export interface NavbarProps {
  /** GitHub star count; null renders the "Stars" fallback label. */
  starCount: number | null;
  /** Active locale code. */
  lang: string;
}
