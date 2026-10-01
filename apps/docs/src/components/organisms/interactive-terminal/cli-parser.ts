import type { TerminalLineKind } from '@/components/molecules/terminal-line';
import {
  CLI_DEFAULTS,
  CLI_VERSION,
  GENERATED_REGISTRY,
  REGISTRY_PRESETS,
  type GeneratedRegistryEntry,
} from '@/lib/components.generated';
import { findClosestMatch } from './levenshtein';

/**
 * A browser-side replay of the real `justui` binary (packages/cli).
 *
 * Every line below copies the CLI's own format strings (logger.rs, add.rs,
 * preset.rs, list/mod.rs, search.rs, diff.rs, update.rs) and every fact
 * (versions, files, dependencies, theme classes, paths) comes from
 * `components.generated.ts`, which is generated from registry/index.json and
 * the CLI sources. test/cli-parser.test.ts compares the output against
 * transcripts recorded from the binary (test/fixtures/cli/*.txt).
 *
 * Commands that inspect the visitor's own machine (doctor, upgrade, info,
 * view, create) are not simulated; the terminal says so instead of
 * inventing a result.
 */

export interface ParsedLine {
  kind: TerminalLineKind;
  text: string;
}

export type SimPreset = 'default' | 'neobrutalism';

export interface CliSession {
  /** Registry names installed in the simulated project, internal ones included. */
  readonly installed: readonly string[];
  readonly preset: SimPreset;
}

export interface ParseResult {
  lines: ParsedLine[];
  /** Public components that the command copied into the project. */
  mountComponents?: string[];
  presetChange?: SimPreset;
  session: CliSession;
}

/** The simulated project has already run `justui init -y`. */
export const INITIAL_SESSION: CliSession = { installed: [], preset: 'default' };

// Glyphs exactly as the CLI prints them (kept as escapes so sources stay ASCII).
const INFO = '\u2139';
const SUCCESS = '\u2713';
const CHECK = '\u2714';
const WARN = '\u26a0';
const ERROR = '\u2717';
const ARROW = '\u2192';
const EM_DASH = '\u2014';
const DOT = '\u25cf';
const H = '\u2500';

const THEME_FILE = 'lib/core/theme/theme_data_material.dart';

export const SUBCOMMANDS: readonly string[] = [
  'version',
  'init',
  'preset',
  'add',
  'update',
  'create',
  'diff',
  'list',
  'search',
  'view',
  'info',
  'upgrade',
  'doctor',
  'help',
];

const LOCAL_ONLY_COMMANDS: Record<string, string> = {
  doctor: 'checks the Flutter and Dart SDKs on your PATH',
  upgrade: 'downloads a newer justui binary for your OS',
  info: 'reads your project config and SDK versions',
  view: 'opens component source in your terminal pager',
  create: 'writes a new component scaffold into your project',
};

const out = (text: string): ParsedLine => ({ kind: 'output', text });
const info = (text: string): ParsedLine => ({
  kind: 'info',
  text: `${INFO} ${text}`,
});
const success = (text: string): ParsedLine => ({
  kind: 'success',
  text: `${SUCCESS} ${text}`,
});
const warning = (text: string): ParsedLine => ({
  kind: 'warning',
  text: `${WARN} Warning: ${text}`,
});
const error = (text: string): ParsedLine => ({
  kind: 'error',
  text: `${ERROR} Error: ${text}`,
});

function findEntry(name: string): GeneratedRegistryEntry | undefined {
  return GENERATED_REGISTRY.find((c) => c.name === name);
}

function installDir(entry: GeneratedRegistryEntry): string {
  if (entry.category === 'tokens' || entry.category === 'core') {
    return CLI_DEFAULTS.tokensDir;
  }
  if (entry.internal) return CLI_DEFAULTS.sharedDir;
  return `${CLI_DEFAULTS.componentsDir}/${entry.name}`;
}

function localFileName(entry: GeneratedRegistryEntry, file: string): string {
  return entry.internal && file.startsWith('_shared_')
    ? `just_${file.slice('_shared_'.length)}`
    : file;
}

const chars = (s: string) => Array.from(s).length;
const padEnd = (s: string, width: number) =>
  s + ' '.repeat(Math.max(0, width - chars(s)));

/** logger::panel */
function panel(msg: string, kind: TerminalLineKind = 'info'): ParsedLine[] {
  const width = chars(msg) + 4;
  return [
    { kind, text: `\u250c${H.repeat(width)}\u2510` },
    { kind, text: `\u2502  ${msg}  \u2502` },
    { kind, text: `\u2514${H.repeat(width)}\u2518` },
  ];
}

/** logger::summary, including its padding arithmetic. */
function summary(
  title: string,
  items: { label: string; value: string }[]
): ParsedLine[] {
  const titleLen = chars(title) + 5;
  const itemMax = Math.max(
    0,
    ...items.map((i) => chars(i.label) + chars(i.value) + 8)
  );
  const inner = Math.max(titleLen, itemMax, 40);
  const pad = (s: string) =>
    `\u2502 ${s}${' '.repeat(Math.max(0, inner - chars(s)))} \u2502`;
  const lines = [
    `\u256d${H.repeat(inner + 2)}\u256e`,
    pad(`  ${CHECK}  ${title}`),
  ];
  if (items.length > 0) {
    lines.push(pad(''));
    for (const item of items) {
      lines.push(pad(`  ${ARROW}  ${padEnd(item.label, 12)} ${item.value}`));
    }
  }
  lines.push(`\u2570${H.repeat(inner + 2)}\u256f`);
  return lines.map((text) => ({ kind: 'success', text }));
}

/** resolve_dependencies_recursive: dependencies first, each name once. */
function resolveOrder(
  name: string,
  visited: Set<string>,
  order: string[]
): void {
  if (visited.has(name)) return;
  visited.add(name);
  const entry = findEntry(name);
  if (!entry) return;
  for (const dep of entry.registryDependencies) {
    resolveOrder(dep, visited, order);
  }
  order.push(name);
}

interface FileDetail {
  file: string;
  path: string;
}

/** One add_component() run: shared by `add` and `preset apply`. */
function addComponents(
  names: string[],
  installed: Set<string>
): { lines: ParsedLine[]; copied: FileDetail[]; skipped: FileDetail[] } {
  const order: string[] = [];
  const visited = new Set<string>();
  for (const name of names) resolveOrder(name, visited, order);

  const lines: ParsedLine[] = [];
  const copied: FileDetail[] = [];
  const skipped: FileDetail[] = [];

  for (const name of order) {
    const entry = findEntry(name);
    if (!entry) continue;
    const dir = installDir(entry);
    const wasInstalled = installed.has(name);
    lines.push(info(`Adding component "${name}" (v${CLI_VERSION})...`));
    for (const file of entry.files) {
      const local = localFileName(entry, file);
      const detail = { file: local, path: `${dir}/${local}` };
      if (wasInstalled) {
        lines.push(out(`  - ${local} is already up-to-date.`));
        skipped.push(detail);
        continue;
      }
      lines.push(out(`  - Copied ${local} to ${dir}/`));
      copied.push(detail);
      if (file.endsWith('_theme.dart') && entry.themeClass) {
        lines.push(
          out(`  - Registered ${entry.themeClass}.defaults in ${THEME_FILE}`)
        );
      }
    }
    installed.add(name);
    lines.push(success(`Component "${name}" added successfully.`));
  }

  return { lines, copied, skipped };
}

function runAdd(args: string[], session: CliSession): ParseResult {
  const all = args.includes('--all');
  const requested = all
    ? GENERATED_REGISTRY.map((c) => c.name)
    : args.filter((a) => !a.startsWith('-'));

  if (requested.length === 0) {
    return {
      lines: [
        out('error: no components given (the real CLI opens a picker here).'),
        out(''),
        out('Usage: justui add [OPTIONS] [COMPONENTS]...'),
      ],
      session,
    };
  }

  const unknown = requested.find((name) => !findEntry(name));
  if (unknown) {
    return {
      lines: [
        error(
          `Dependency resolution error: Component "${unknown}" not found in registry`
        ),
      ],
      session,
    };
  }

  const installed = new Set(session.installed);
  const { lines, copied, skipped } = addComponents(requested, installed);

  lines.push(out(''));
  if (copied.length > 0) {
    lines.push({
      kind: 'success',
      text: `${CHECK} ${copied.length} file(s) added/updated:`,
    });
    for (const d of copied) {
      lines.push(out(`  ${CHECK} ${d.file} (New) -> ${d.path}`));
    }
  }
  if (skipped.length > 0) {
    lines.push({
      kind: 'warning',
      text: `${WARN} ${skipped.length} file(s) skipped:`,
    });
    for (const d of skipped) {
      lines.push(out(`  ${WARN} ${d.file} (Up-to-date) -> ${d.path}`));
    }
  }

  lines.push(success('Components added successfully'));
  const summaryItems = requested.flatMap((name) => {
    const entry = findEntry(name);
    return entry
      ? [{ label: name, value: `v${CLI_VERSION}  ${installDir(entry)}/` }]
      : [];
  });
  lines.push(
    ...summary(
      `${summaryItems.length} component(s) added successfully`,
      summaryItems
    )
  );

  return {
    lines,
    mountComponents: requested.filter((name) => !findEntry(name)?.internal),
    session: { ...session, installed: [...installed] },
  };
}

function installedInRegistryOrder(session: CliSession): string[] {
  return GENERATED_REGISTRY.filter((c) =>
    session.installed.includes(c.name)
  ).map((c) => c.name);
}

function runPreset(args: string[], session: CliSession): ParseResult {
  const action = args[0];

  if (!action || action === 'list') {
    return {
      lines: [
        ...panel('Available Presets'),
        ...REGISTRY_PRESETS.map((preset) => {
          const count = GENERATED_REGISTRY.filter((c) =>
            c.supportedPresets.includes(preset)
          ).length;
          const active = preset === session.preset ? ' (active)' : '';
          return out(`  ${preset}${active}  ${EM_DASH}  ${count} component(s)`);
        }),
      ],
      session,
    };
  }

  if (action !== 'apply') {
    return {
      lines: [
        out(`error: unrecognized subcommand '${action}'`),
        out(''),
        out('Usage: justui preset [OPTIONS] [COMMAND]'),
        out(''),
        out("For more information, try '--help'."),
      ],
      session,
    };
  }

  const name = args.slice(1).find((a) => !a.startsWith('-'));
  if (!name) {
    return {
      lines: [
        out('error: the following required arguments were not provided:'),
        out('  <NAME>'),
        out(''),
        out('Usage: justui preset apply <NAME>'),
        out(''),
        out("For more information, try '--help'."),
      ],
      session,
    };
  }

  if (!REGISTRY_PRESETS.includes(name)) {
    return {
      lines: [
        error(
          `Preset "${name}" not found in registry. Run "justui preset list" to see available presets.`
        ),
      ],
      session,
    };
  }

  // preset.rs treats a component as installed when its install directory
  // exists, so every internal entry counts once the shared dir exists.
  const existingDirs = new Set(
    session.installed.flatMap((n) => {
      const e = findEntry(n);
      return e ? [installDir(e)] : [];
    })
  );
  const installedNames = GENERATED_REGISTRY.filter((c) =>
    existingDirs.has(installDir(c))
  ).map((c) => c.name);
  if (installedNames.length === 0) {
    return {
      lines: [
        warning('No installed components found. Run "justui add" first.'),
      ],
      session,
    };
  }

  const supports = (n: string) =>
    findEntry(n)?.supportedPresets.includes(name) ?? false;
  const unsupported = installedNames.filter((n) => !supports(n));
  const toApply = installedNames.filter(supports);

  const lines: ParsedLine[] = [];
  if (unsupported.length > 0) {
    lines.push(
      warning(
        `The following components do not support preset "${name}": ${unsupported.join(', ')}`
      ),
      warning('These components will be skipped and keep their current preset.')
    );
  }
  if (toApply.length === 0) {
    lines.push(error(`No installed components support preset "${name}".`));
    return { lines, session };
  }

  lines.push(...panel(`Applying preset "${name}"`));
  const installed = new Set(session.installed);
  lines.push(...addComponents(toApply, installed).lines);
  lines.push(
    ...summary(`Preset "${name}" applied successfully`, [
      { label: 'Succeeded', value: `${toApply.length} component(s)` },
      { label: 'Failed', value: '0 component(s)' },
      { label: 'Active preset', value: name },
    ])
  );

  const preset: SimPreset =
    name === 'neobrutalism' ? 'neobrutalism' : 'default';
  return {
    lines,
    presetChange: preset,
    session: { installed: [...installed], preset },
  };
}

function runList(session: CliSession): ParseResult {
  return {
    lines: [
      out('=== JustUI Registry Components ==='),
      ...GENERATED_REGISTRY.map((c) => {
        const status = session.installed.includes(c.name)
          ? 'Installed'
          : 'Not Installed';
        return out(
          `  ${padEnd(c.name, 20)} v${padEnd(CLI_VERSION, 8)} [${padEnd(status, 12)}] (${c.category})`
        );
      }),
    ],
    session,
  };
}

function runSearch(args: string[], session: CliSession): ParseResult {
  const query = args.filter((a) => !a.startsWith('-')).join(' ');
  if (!query) {
    return {
      lines: [
        out('error: the following required arguments were not provided:'),
        out('  <QUERY>'),
        out(''),
        out('Usage: justui search <QUERY>'),
        out(''),
        out("For more information, try '--help'."),
      ],
      session,
    };
  }

  const q = query.toLowerCase();
  const byName = GENERATED_REGISTRY.filter((c) => c.name.includes(q));
  const byOther = GENERATED_REGISTRY.filter(
    (c) =>
      !c.name.includes(q) &&
      (c.description.toLowerCase().includes(q) ||
        c.category.toLowerCase().includes(q))
  );
  const results = [...byName, ...byOther];
  if (results.length === 0) {
    return {
      lines: [out(`No components found matching "${query}".`)],
      session,
    };
  }

  const lines: ParsedLine[] = [out(`Search results for "${query}":`), out('')];
  const categories = [...new Set(results.map((c) => c.category))];
  for (const category of categories) {
    lines.push(
      out(`  ${category.charAt(0).toUpperCase()}${category.slice(1)}:`)
    );
    for (const c of results.filter((r) => r.category === category)) {
      lines.push(
        out(
          `    ${DOT} ${padEnd(c.name, 16)} ${padEnd(`(v${CLI_VERSION})`, 10)} ${c.description}`
        )
      );
    }
  }
  lines.push(out(''), out(`${results.length} component(s) found.`));
  return { lines, session };
}

function runDiff(args: string[], session: CliSession): ParseResult {
  const requested =
    args.find((a) => !a.startsWith('-')) ??
    installedInRegistryOrder(session).find((n) => !findEntry(n)?.internal);
  if (!requested) {
    return { lines: [warning('No installed components found.')], session };
  }
  const entry = findEntry(requested);
  if (!entry) {
    return {
      lines: [error(`Component "${requested}" not found in registry.`)],
      session,
    };
  }

  const lines: ParsedLine[] = [
    info(`Comparing component "${requested}" with registry...`),
  ];
  const isInstalled = session.installed.includes(requested);
  for (const file of entry.files) {
    lines.push(
      isInstalled
        ? success(`${file}: Up to date.`)
        : warning(`File ${file} is missing locally (needs to be added).`)
    );
  }
  return { lines, session };
}

function runUpdate(session: CliSession): ParseResult {
  if (session.installed.length === 0) {
    return { lines: [warning('No installed components found.')], session };
  }
  return { lines: [success('All components are up-to-date!')], session };
}

const HELP_LINES = [
  `justui v${CLI_VERSION}`,
  'JustUI CLI - High-performance Flutter UI scaffolding and copy-paste component tool',
  '',
  'Usage: justui [OPTIONS] [COMMAND]',
  '',
  'Commands:',
  '  version  Print CLI version information and update status',
  '  init     Initialize JustUI configuration and theme tokens in a Flutter project',
  '  preset   Manage and apply visual design style presets (e.g. default, neobrutalism)',
  '  add      Copy one or more components from the registry into your project',
  '  update   Synchronize local components with upstream registry updates',
  '  create   Scaffold a new custom component in your local project',
  '  diff     Inspect local component modifications vs upstream registry source code',
  '  list     List all available components in the JustUI registry',
  '  search   Search for components in the registry by keyword or category',
  '  view     View source code or documentation of a registry component',
  '  info     Display project configuration, installed components, and system status',
  '  upgrade  Check for and upgrade JustUI CLI to the latest version',
  '  doctor   Perform health and environment diagnostics check',
  '  help     Print this message or the help of the given subcommand(s)',
  '',
  'Options:',
  '  -y, --yes         Skip all interactive confirmation prompts (accept defaults)',
  '  -c, --cwd <PATH>  Specify target working directory for operation',
  '  -q, --quiet       Suppress non-essential informational logging output',
  '      --json        Output results in machine-readable JSON format',
  '      --no-color    Disable colored ANSI escape code output',
  '  -V, --version     Display CLI version and check for updates',
  '  -h, --help        Print help',
];

function unknownSubcommand(name: string): ParsedLine[] {
  const lines = [out(`error: unrecognized subcommand '${name}'`), out('')];
  // clap only suggests near-identical names; distance 1 approximates that.
  const match = findClosestMatch(name, SUBCOMMANDS, 1);
  if (match) {
    lines.push(
      out(`  tip: a similar subcommand exists: '${match.match}'`),
      out('')
    );
  }
  lines.push(
    out('Usage: justui [OPTIONS] [COMMAND]'),
    out(''),
    out("For more information, try '--help'.")
  );
  return lines;
}

export function parseCommand(
  rawInput: string,
  session: CliSession = INITIAL_SESSION
): ParseResult {
  const tokens = rawInput.trim().split(/\s+/).filter(Boolean);
  if (tokens.length === 0) return { lines: [], session };

  if (tokens[0] !== 'justui') {
    return {
      lines: [out(`sh: ${tokens[0]}: command not found`)],
      session,
    };
  }

  const subcommand = tokens[1];
  const args = tokens.slice(2);

  if (!subcommand || ['help', '--help', '-h'].includes(subcommand)) {
    return { lines: HELP_LINES.map(out), session };
  }

  switch (subcommand) {
    case 'version':
    case '--version':
    case '-V':
      return {
        lines: [out(`Current JustUI CLI version: v${CLI_VERSION}`)],
        session,
      };
    case 'init':
      return {
        lines: [warning('justui.config.yaml already exists in this project.')],
        session,
      };
    case 'add':
      return runAdd(args, session);
    case 'preset':
      return runPreset(args, session);
    case 'list':
      return runList(session);
    case 'search':
      return runSearch(args, session);
    case 'diff':
      return runDiff(args, session);
    case 'update':
      return runUpdate(session);
    default: {
      const localOnly = LOCAL_ONLY_COMMANDS[subcommand];
      if (localOnly) {
        return {
          lines: [
            out(
              `justui ${subcommand} ${localOnly}, so it can't run in this browser simulation.`
            ),
            out(
              'Install the CLI and run it in your project for the real result.'
            ),
          ],
          session,
        };
      }
      return { lines: unknownSubcommand(subcommand), session };
    }
  }
}
