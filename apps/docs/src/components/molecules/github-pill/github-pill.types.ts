export interface GitHubPillProps {
  /** GitHub repo URL. */
  href: string;
  /** Star count to display. null shows "Stars". */
  starCount: number | null;
  className?: string;
}
