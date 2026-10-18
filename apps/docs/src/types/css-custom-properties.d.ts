import 'react';

declare module 'react' {
  /** Lets inline styles set Ink and Paper variables without a type assertion. */
  interface CSSProperties {
    [key: `--ip-${string}`]: string | number | undefined;
  }
}
