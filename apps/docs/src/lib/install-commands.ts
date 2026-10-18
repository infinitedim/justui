import { SITE_URL } from '@/lib/site';

/** Operating systems the install command is offered for. */
export const INSTALL_PLATFORMS = ['unix', 'windows'] as const;

export type InstallPlatform = (typeof INSTALL_PLATFORMS)[number];

/** Visible tab labels (product names, not translated). */
export const INSTALL_PLATFORM_LABELS = {
  unix: 'macOS / Linux',
  windows: 'Windows',
} as const satisfies Record<InstallPlatform, string>;

/** One-line installer for each platform, served by this site. */
export const INSTALL_COMMANDS = {
  unix: `curl -fsSL ${SITE_URL}/install.sh | sh`,
  windows: `irm ${SITE_URL}/install.ps1 | iex`,
} as const satisfies Record<InstallPlatform, string>;

/**
 * Splits a command into display segments. A line may break only between
 * segments: after a space, or after a `/` that does not start `//`. Spaces
 * end a segment, so no wrapped line starts with one. A trailing pipe
 * (`| sh`, `| iex`) stays one segment. Rendered with `white-space: pre`
 * per segment, the joined text equals the command exactly.
 */
export function commandSegments(command: string): readonly string[] {
  const pipe = /\| \w+$/.exec(command);
  const head = pipe ? command.slice(0, pipe.index) : command;
  const segments = head
    .split(/(?<= )|(?<=\/)(?!\/)/)
    .filter((segment) => segment.length > 0);
  return pipe ? [...segments, pipe[0]] : segments;
}
