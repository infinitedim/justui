export interface BreadcrumbSegment {
  label: string;
  href?: string;
}

export interface BreadcrumbTrailProps {
  segments: BreadcrumbSegment[];
  className?: string;
}
