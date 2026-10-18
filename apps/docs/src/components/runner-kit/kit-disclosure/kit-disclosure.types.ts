export interface KitAccordionProps {
  question: string;
  answer: string;
  className?: string;
}

export interface KitCarouselProps {
  /** Accessible name of the slide picker. */
  label: string;
  /** Slide text with `{index}` and `{total}` placeholders. */
  slideTemplate: string;
  /** Dot label with an `{index}` placeholder. */
  dotTemplate: string;
  total?: number;
  className?: string;
}

export interface KitScrollAreaProps {
  lines: readonly string[];
  className?: string;
}

export interface KitResizableProps {
  start: string;
  end: string;
  className?: string;
}
