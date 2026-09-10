import type { SVGAttributes } from 'react';

export type IconSize = 'xs' | 'sm' | 'md' | 'lg' | 'xl';

export interface IconProps extends SVGAttributes<SVGSVGElement> {
  /** The lucide-react icon component to render. */
  icon: React.ComponentType<SVGAttributes<SVGSVGElement>>;
  /** Preset icon sizes. */
  size?: IconSize;
  /** Accessible label. When provided, role="img" is set; otherwise role="presentation". */
  label?: string;
}
