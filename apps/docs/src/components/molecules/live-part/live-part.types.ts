import type { ReactNode } from 'react';
import type { FlutterScene } from '@/lib/flutter-bridge';
import type { Locale } from '@/lib/i18n';
import type { JustUIPreset } from '@/lib/presets';

export interface LivePartProps {
  /** Registry slug of the Flutter scene to mount. */
  scene: FlutterScene;
  /** Locale of the copy sent to the scene. */
  lang: Locale;
  /** Preset of this part; the visitor's stored preset when omitted. */
  preset?: JustUIPreset;
  /** Scene props (playground controls). */
  props?: Record<string, boolean | number | string>;
  /** The React part: rendered on the server and kept as the fallback. */
  children: ReactNode;
  className?: string;
}
