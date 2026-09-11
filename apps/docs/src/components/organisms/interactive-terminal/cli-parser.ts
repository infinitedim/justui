import type { TerminalLineKind } from '@/components/molecules/terminal-line';
import { REGISTRY_COMPONENT_NAMES, findClosestMatch } from './levenshtein';

export interface ParsedLine {
  kind: TerminalLineKind;
  text: string;
  delay?: number;
}

export interface ParseResult {
  lines: ParsedLine[];
  mountComponents?: string[];
  presetChange?: 'default' | 'neobrutalism';
  clearStage?: boolean;
}

const SUBCOMMANDS: readonly string[] = [
  'init',
  'add',
  'list',
  'search',
  'preset',
  'diff',
  'update',
  'doctor',
  'version',
  'help',
] as const;

function getHelpLines(): ParsedLine[] {
  return [
    {
      kind: 'info',
      text: 'JustUI CLI - Copy-paste Flutter components with zero dependencies',
    },
    { kind: 'output', text: '' },
    { kind: 'output', text: 'USAGE:' },
    { kind: 'output', text: '  justui <COMMAND> [OPTIONS]' },
    { kind: 'output', text: '' },
    { kind: 'output', text: 'COMMANDS:' },
    {
      kind: 'output',
      text: '  init       Initialize JustUI configuration and theme in your Flutter project',
    },
    {
      kind: 'output',
      text: '  add        Add one or more components to your project',
    },
    {
      kind: 'output',
      text: '  list       List all available components in the registry',
    },
    {
      kind: 'output',
      text: '  search     Search for components by name or keyword',
    },
    {
      kind: 'output',
      text: '  preset     Manage style presets (list, apply)',
    },
    {
      kind: 'output',
      text: '  diff       Compare local component code with upstream registry',
    },
    {
      kind: 'output',
      text: '  update     Update local components to latest registry versions',
    },
    {
      kind: 'output',
      text: '  doctor     Diagnose project configuration and dependencies',
    },
    {
      kind: 'output',
      text: '  version    Print CLI version',
    },
    {
      kind: 'output',
      text: '  help       Print this help message',
    },
  ];
}

export function parseCommand(rawInput: string): ParseResult {
  const trimmed = rawInput.trim();
  if (!trimmed) {
    return { lines: getHelpLines() };
  }

  const tokens = trimmed.split(/\s+/);
  let subcommand = tokens[0];
  let args = tokens.slice(1);

  if (subcommand === 'justui') {
    if (tokens.length === 1) {
      return { lines: getHelpLines() };
    }
    subcommand = tokens[1];
    args = tokens.slice(2);
  }

  switch (subcommand) {
    case 'help':
    case '--help':
    case '-h':
      return { lines: getHelpLines() };

    case 'version':
    case '--version':
    case '-v':
      return {
        lines: [
          {
            kind: 'output',
            text: 'justui v0.13.2 (rustc 1.87.0)',
          },
        ],
      };

    case 'init': {
      const presetFlagIndex = args.findIndex(
        (a) => a === '--preset' || a === '-p'
      );
      let preset: 'default' | 'neobrutalism' | undefined;
      if (presetFlagIndex !== -1) {
        const candidate = args[presetFlagIndex + 1]?.toLowerCase();
        if (!candidate) {
          return {
            lines: [
              {
                kind: 'error',
                text: 'error: Preset name required for --preset flag. Available presets: default, neobrutalism',
              },
            ],
          };
        }
        if (candidate === 'neobrutalism' || candidate === 'neo') {
          preset = 'neobrutalism';
        } else if (candidate === 'default' || candidate === 'd') {
          preset = 'default';
        } else {
          return {
            lines: [
              {
                kind: 'error',
                text: `error: Invalid preset '${candidate}'. Available presets: default, neobrutalism`,
              },
            ],
          };
        }
      }

      const lines: ParsedLine[] = [
        { kind: 'info', text: 'Initializing JustUI project...' },
        { kind: 'info', text: 'Created justui.config.yaml' },
        { kind: 'info', text: 'Created lib/theme/just_theme.dart' },
      ];

      if (preset) {
        lines.push({
          kind: 'info',
          text: `Applied preset: ${preset}`,
        });
      }

      lines.push({
        kind: 'success',
        text: 'Done! Run `justui add <component>` to start.',
      });

      return {
        lines,
        clearStage: true,
        ...(preset ? { presetChange: preset } : {}),
      };
    }

    case 'add': {
      if (args.length === 0) {
        return {
          lines: [
            {
              kind: 'error',
              text: 'error: No components specified. Usage: justui add <component...>',
            },
          ],
        };
      }

      if (args.includes('--all') || args.includes('-a')) {
        return {
          lines: [
            {
              kind: 'info',
              text: 'Installing all 33 components...',
            },
            {
              kind: 'output',
              text: 'Downloading specifications and building widget tree...',
            },
            {
              kind: 'success',
              text: 'Done! 33 components installed.',
            },
          ],
          mountComponents: ['button', 'switch', 'card'],
        };
      }

      const componentNames = args.filter((a) => !a.startsWith('-'));
      if (componentNames.length === 0) {
        return {
          lines: [
            {
              kind: 'error',
              text: 'error: No components specified. Usage: justui add <component...>',
            },
          ],
        };
      }

      const invalidComponents: { name: string; match?: string }[] = [];

      for (const name of componentNames) {
        if (!REGISTRY_COMPONENT_NAMES.includes(name)) {
          const match = findClosestMatch(name, REGISTRY_COMPONENT_NAMES);
          invalidComponents.push({ name, match: match?.match });
        }
      }

      if (invalidComponents.length > 0) {
        const errorLines: ParsedLine[] = invalidComponents.map(
          ({ name, match }) => ({
            kind: 'error',
            text: match
              ? `error: Component '${name}' not found. Did you mean '${match}'?`
              : `error: Component '${name}' not found in registry.`,
          })
        );
        return { lines: errorLines };
      }

      const lines: ParsedLine[] = [];
      for (const name of componentNames) {
        lines.push({
          kind: 'info',
          text: `Downloading ${name}...`,
        });
        lines.push({
          kind: 'output',
          text: `Installing ${name}...`,
        });
        lines.push({
          kind: 'success',
          text: `Created lib/widgets/${name}/just_${name}.dart`,
        });
      }

      lines.push({
        kind: 'success',
        text: `Done! ${componentNames.length} component(s) added successfully.`,
      });

      return {
        lines,
        mountComponents: componentNames,
      };
    }

    case 'preset': {
      const action = args[0];
      if (action === 'list') {
        return {
          lines: [
            { kind: 'info', text: 'Available presets:' },
            {
              kind: 'output',
              text: '  default        - Clean, modern aesthetic with subtle borders and shadows',
            },
            {
              kind: 'output',
              text: '  neobrutalism   - High-contrast, bold 2.5px borders and solid drop shadows',
            },
          ],
        };
      }

      if (action === 'apply') {
        const target = args[1]?.toLowerCase();
        if (!target) {
          return {
            lines: [
              {
                kind: 'error',
                text: 'error: Preset name required. Usage: justui preset apply <default|neobrutalism>',
              },
            ],
          };
        }

        const resolvedPreset =
          target === 'neobrutalism' || target === 'neo'
            ? 'neobrutalism'
            : target === 'default' || target === 'd'
              ? 'default'
              : undefined;

        if (resolvedPreset) {
          return {
            lines: [
              {
                kind: 'info',
                text: `Applying preset: ${resolvedPreset}...`,
              },
              {
                kind: 'output',
                text: 'Updated justui.config.yaml',
              },
              {
                kind: 'output',
                text: 'Regenerated just_theme.dart',
              },
              {
                kind: 'success',
                text: 'Done!',
              },
            ],
            presetChange: resolvedPreset,
          };
        }

        return {
          lines: [
            {
              kind: 'error',
              text: `error: Unknown preset '${target}'. Available presets: default, neobrutalism`,
            },
          ],
        };
      }

      return {
        lines: [
          {
            kind: 'output',
            text: 'Usage: justui preset <list|apply> [preset-name]',
          },
        ],
      };
    }

    case 'list':
      return {
        lines: [
          { kind: 'info', text: 'Available components (33 total):' },
          {
            kind: 'output',
            text: '  Buttons:       button, icon-button, toggle',
          },
          {
            kind: 'output',
            text: '  Form Controls: input, checkbox, radio, radio-group, switch, slider, select, date-picker, date-range-picker, time-picker',
          },
          {
            kind: 'output',
            text: '  Layout:        card, separator, scroll-area, resizable, carousel',
          },
          {
            kind: 'output',
            text: '  Feedback:      badge, skeleton, progress, toast',
          },
          {
            kind: 'output',
            text: '  Navigation:    breadcrumb, tabs, bottom-nav, sidebar',
          },
          {
            kind: 'output',
            text: '  Overlay:       dialog, sheet, tooltip, accordion',
          },
          {
            kind: 'output',
            text: '  Data Display:  avatar, avatar-group, table',
          },
        ],
      };

    case 'search': {
      const query = args[0]?.toLowerCase()?.trim();
      if (!query) {
        return {
          lines: [
            {
              kind: 'error',
              text: 'error: Search query required. Usage: justui search <query>',
            },
          ],
        };
      }
      const matches = REGISTRY_COMPONENT_NAMES.filter((c) => c.includes(query));
      if (matches.length === 0) {
        return {
          lines: [
            {
              kind: 'info',
              text: `No components found matching '${query}'.`,
            },
          ],
        };
      }
      return {
        lines: [
          {
            kind: 'info',
            text: `Found ${matches.length} matching component(s):`,
          },
          ...matches.map((m) => ({
            kind: 'output' as const,
            text: `  ${m}`,
          })),
        ],
      };
    }

    case 'diff': {
      const component = args[0]?.toLowerCase() || 'all';
      if (
        component !== 'all' &&
        !REGISTRY_COMPONENT_NAMES.includes(component)
      ) {
        const match = findClosestMatch(component, REGISTRY_COMPONENT_NAMES);
        return {
          lines: [
            {
              kind: 'error',
              text: match
                ? `error: Component '${component}' not found. Did you mean '${match.match}'?`
                : `error: Component '${component}' not found in registry.`,
            },
          ],
        };
      }
      return {
        lines: [
          {
            kind: 'info',
            text: `Comparing local vs registry for ${component}...`,
          },
          {
            kind: 'success',
            text: 'No changes detected.',
          },
        ],
      };
    }

    case 'update':
      return {
        lines: [
          {
            kind: 'info',
            text: 'Checking for component updates...',
          },
          {
            kind: 'success',
            text: 'All components up to date.',
          },
        ],
      };

    case 'doctor':
      return {
        lines: [
          {
            kind: 'info',
            text: 'Running JustUI system diagnostics...',
          },
          { kind: 'success', text: '[OK] Dart SDK: found (v3.10+)' },
          { kind: 'success', text: '[OK] Flutter SDK: found' },
          { kind: 'success', text: '[OK] Config: valid (justui.config.yaml)' },
          {
            kind: 'success',
            text: '[OK] Registry: connected (https://justui.dev/registry)',
          },
          { kind: 'success', text: '[OK] All systems operational.' },
        ],
      };

    default: {
      const match = findClosestMatch(subcommand, SUBCOMMANDS);
      if (match) {
        return {
          lines: [
            {
              kind: 'error',
              text: `error: Unknown command '${subcommand}'. Did you mean '${match.match}'?`,
            },
          ],
        };
      }
      return {
        lines: [
          {
            kind: 'error',
            text: `error: Unknown command '${subcommand}'. Run 'justui help' for usage.`,
          },
        ],
      };
    }
  }
}
