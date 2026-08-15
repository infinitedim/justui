# JustUI CLI

A fast, interactive Rust CLI for the [JustUI](https://docs.justui.dev) Flutter component library. Copy components from the registry into your project, resolve dependencies, check for updates, and manage your setup — all from the terminal.

---

## Installation

**Via install script:**

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/infinitedim/justui/main/packages/cli/install/install.sh | sh

# Windows (PowerShell)
irm https://raw.githubusercontent.com/infinitedim/justui/main/packages/cli/install/install.ps1 | iex
```

**From source:**

```bash
git clone https://github.com/infinitedim/justui.git
cd justui/packages/cli
cargo install --path .
```

Verify the install:

```bash
justui --version
```

---

## Commands

### `justui init`

Initialize JustUI in a Flutter project. Run this from your project root.

```bash
justui init
justui init --preset neobrutalism
justui init --preset default
```

Prompts for components directory, tokens directory, and brand color. Generates `justui.config.yaml` and bootstraps `lib/theme/just_theme.dart`.

**Config file generated:**

```yaml
components_dir: lib/ui
tokens_dir: lib/tokens
shared_dir: lib/ui/shared
registry_url: https://raw.githubusercontent.com/infinitedim/justui/main/registry
```

---

### `justui add`

Copy one or more components and their dependencies into your project.

```bash
# Add specific components
justui add button
justui add button input card

# Interactive fuzzy multi-select (no args)
justui add

# Preview without writing files
justui add button --dry-run

# Show diff before each file write
justui add button --diff

# Skip all confirmation prompts
justui add button -y
```

The CLI will:

- Recursively resolve and install all registry dependencies
- Verify file integrity with SHA-256 checksums
- Prompt for conflict resolution if local files have been modified (overwrite / skip / show diff)
- Inject any required pub.dev packages into `pubspec.yaml`
- Display a structured summary on completion

**Output structure:**

```
lib/
  ui/
    shared/           # Internal shared utilities (_shared_pressable, etc.)
    button/           # Named subfolder per component
      just_button.dart
      just_button_style.dart
      just_button_theme.dart
      just_button_variants.dart
```

---

### `justui list`

List all available components in the registry.

```bash
justui list
```

---

### `justui search`

Search the registry by name, description, or category.

```bash
justui search button
justui search input --category primitives
```

---

### `justui info`

Show CLI version, active config, and registry connection status.

```bash
justui info
```

---

### `justui view`

Print a component's source code to the terminal.

```bash
justui view button
justui view button --file just_button_style.dart
```

---

### `justui diff`

Compare your local component files against the current registry versions.

```bash
justui diff button

# Verbose line-by-line output
justui diff button --verbose
```

Status indicators:

- ✔ **Up to date** — file matches registry
- ⚠ **Modified locally** — you've edited the file since install
- ℹ **Update available** — registry has a newer version
- ⚠ **Conflict** — both local and registry have changed
- ⚠ **Missing** — file was deleted locally

---

### `justui update`

Check all installed components for registry updates and apply them interactively.

```bash
justui update

# Auto-apply all updates without prompts
justui update -y
```

---

### `justui create`

Scaffold a new custom component following JustUI's 4-file bundle convention.

```bash
justui create my_component
```

Generates under your configured `components_dir`:

```
my_component/
├── my_component.dart           # Widget implementation
├── my_component_style.dart     # Per-instance style overrides
├── my_component_variants.dart  # Size/variant enums
└── my_component_theme.dart     # ThemeExtension for global overrides
```

---

## Global Flags

| Flag    | Short | Description                                    |
| ------- | ----- | ---------------------------------------------- |
| `--yes` | `-y`  | Skip all confirmation prompts and use defaults |

---

## Config File Reference

`justui.config.yaml` is created by `justui init` at your project root.

```yaml
# Directory where components are copied
components_dir: lib/ui

# Directory where internal shared utilities are placed
shared_dir: lib/ui/shared

# Directory for token files (colors, spacing, typography)
tokens_dir: lib/tokens

# Registry URL (change to self-host your own registry)
registry_url: https://raw.githubusercontent.com/infinitedim/justui/main/registry
```

---

## Development

```bash
cd packages/cli

# Build
cargo build

# Build release binary
cargo build --release

# Run tests
cargo test

# Lint
cargo clippy --all-targets -- -D warnings

# Install locally for testing
cargo install --path .
```

---

## Architecture Notes

- Component target directory is determined by the `internal` field in `index.json`. Internal shared utilities (`"internal": true`) go to `shared_dir`. All other components get a named subfolder under `components_dir`.
- Import paths in copied files are rewritten automatically by `utils/import_rewriter.rs` to match the target project structure.
- File integrity is tracked via SHA-256 checksums stored in `index.json`. The `diff` command uses a metadata header embedded in copied files to detect local modifications vs registry changes.
