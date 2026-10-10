#![expect(
    clippy::struct_excessive_bools,
    clippy::too_many_lines,
    reason = "legacy: fix when touched"
)]

use anyhow::Context;
use clap::{Parser, Subcommand};
use std::io::Write;
use std::path::PathBuf;
use std::process;

use justui_cli::{commands, utils};

/// `JustUI` CLI - High-performance Flutter UI scaffolding and copy-paste component tool
#[derive(Parser)]
#[command(
    name = "justui",
    about = "JustUI CLI - High-performance Flutter UI scaffolding and copy-paste component tool",
    version,
    disable_version_flag = true,
    help_template = "\
{before-help}{name} v{version}
{about-with-newline}
{usage-heading} {usage}

{all-args}{after-help}
"
)]
struct Cli {
    /// Skip all interactive confirmation prompts (accept defaults)
    #[arg(short = 'y', long = "yes", global = true)]
    auto_yes: bool,

    /// Specify target working directory for operation
    #[arg(short = 'c', long = "cwd", global = true, value_name = "PATH")]
    cwd: Option<PathBuf>,

    /// Suppress non-essential informational logging output
    #[arg(short = 'q', long = "quiet", global = true)]
    quiet: bool,

    /// Increase logging verbosity (-v for debug, -vv for trace)
    #[arg(short = 'v', long = "verbose", action = clap::ArgAction::Count, global = true)]
    verbose: u8,

    /// Output results in machine-readable JSON format
    #[arg(long = "json", global = true)]
    json: bool,

    /// Disable colored ANSI escape code output
    #[arg(long = "no-color", global = true)]
    no_color: bool,

    /// Display CLI version and check for updates
    #[arg(short = 'V', long = "version")]
    version_flag: bool,

    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand)]
enum Commands {
    /// Print CLI version information and update status
    #[command(
        subcommand_help_heading = "Maintenance & Utility",
        after_help = "EXAMPLES:\n  justui version"
    )]
    Version,

    /// Initialize `JustUI` configuration and theme tokens in a Flutter project
    #[command(
        alias = "i",
        subcommand_help_heading = "Project Setup & Scaffolding",
        after_help = "EXAMPLES:\n  justui init\n  justui init --preset neobrutalism -y"
    )]
    Init {
        /// Visual style preset to apply during initialization (default, neobrutalism)
        #[arg(long)]
        preset: Option<commands::init::PresetArg>,
        /// Color space engine for dynamic palette generation (hsl, oklch, hsluv)
        #[arg(long = "color-space")]
        color_space: Option<commands::init::ColorSpaceArg>,
        /// Target UI components directory
        #[arg(long = "components-dir")]
        components_dir: Option<String>,
        /// Target design tokens directory
        #[arg(long = "tokens-dir")]
        tokens_dir: Option<String>,
        /// Target Dart constructor syntax override (primary, standard)
        #[arg(long = "dart-target")]
        dart_target: Option<utils::env_resolver::DartTarget>,
        /// Primary brand seed color in hex format (e.g. #3b82f6 or 3b82f6)
        #[arg(long = "seed")]
        seed: Option<String>,
        /// Configure dark mode by default
        #[arg(long = "dark")]
        dark: bool,
        /// Enable experimental features (e.g. auto-detect-flutter-version)
        #[arg(
            long = "experimental",
            value_name = "FEATURE",
            help = "Activate an experimental feature by name",
            long_help = "Activate an experimental feature by name.\n\n\
                Available experimental features:\n  \
                auto-detect-flutter-version  Auto-detect Dart SDK version from pubspec.yaml and FVM\n                                       \
                to determine constructor syntax (primary vs standard)"
        )]
        experimental: Option<String>,
    },

    /// Manage and apply visual design style presets (e.g. default, neobrutalism)
    #[command(
        subcommand_help_heading = "Project Setup & Scaffolding",
        after_help = "EXAMPLES:\n  justui preset list\n  justui preset apply neobrutalism\n  justui preset info default"
    )]
    Preset {
        /// Preset action subcommand (list, apply, info)
        #[command(subcommand)]
        subcommand: Option<PresetSubcommands>,

        /// Name of the preset (legacy syntax)
        name: Option<String>,
        /// Apply the specified preset (legacy flag syntax)
        #[arg(long = "apply")]
        apply: bool,
        /// List all available presets (legacy flag syntax)
        #[arg(long = "list")]
        list: bool,
        /// Show details about a specific preset (legacy flag syntax)
        #[arg(long = "info")]
        info: Option<String>,
    },

    /// Copy one or more components from the registry into your project
    #[command(
        alias = "a",
        subcommand_help_heading = "Component Lifecycle",
        after_help = "EXAMPLES:\n  justui add button card\n  justui add button --dry-run"
    )]
    Add {
        /// Names of components to add (e.g. button input card)
        components: Vec<String>,
        /// Preview component addition without writing files to disk
        #[arg(long = "dry-run")]
        dry_run: bool,
        /// Display file diffs before applying changes
        #[arg(long = "diff")]
        show_diff: bool,
        /// Add all available components
        #[arg(long = "all")]
        all: bool,
        /// Overwrite existing local components without prompting
        #[arg(long = "overwrite")]
        overwrite: bool,
    },

    /// Synchronize local components with upstream registry updates
    #[command(
        alias = "up",
        subcommand_help_heading = "Component Lifecycle",
        after_help = "EXAMPLES:\n  justui update\n  justui update -y"
    )]
    Update,

    /// Scaffold a new custom component in your local project
    #[command(
        subcommand_help_heading = "Component Lifecycle",
        after_help = "EXAMPLES:\n  justui create custom_card"
    )]
    Create {
        /// Name of the new component to scaffold
        component_name: Option<String>,
        /// Category for the component
        #[arg(long = "category")]
        category: Option<String>,
        /// Preview component creation without writing files
        #[arg(long = "dry-run")]
        dry_run: bool,
    },

    /// Inspect local component modifications vs upstream registry source code
    #[command(
        subcommand_help_heading = "Component Lifecycle",
        after_help = "EXAMPLES:\n  justui diff button\n  justui diff button --verbose"
    )]
    Diff {
        /// Component name to inspect
        component: Option<String>,
        /// Automatically accept diff updates
        #[arg(long = "accept")]
        accept: bool,
    },

    /// List all available components in the `JustUI` registry
    #[command(
        alias = "ls",
        subcommand_help_heading = "Discovery & Inspection",
        after_help = "EXAMPLES:\n  justui list"
    )]
    List {
        /// Filter components by category
        #[arg(long = "category")]
        category: Option<String>,
        /// Output component list in JSON format
        #[arg(long = "json")]
        json: bool,
    },

    /// Search for components in the registry by keyword or category
    #[command(
        subcommand_help_heading = "Discovery & Inspection",
        after_help = "EXAMPLES:\n  justui search button\n  justui search --category primitive"
    )]
    Search {
        /// Search keyword query
        query: String,
        /// Filter components by category (e.g. primitive, composite)
        #[arg(long = "category")]
        category: Option<String>,
    },

    /// View source code or documentation of a registry component
    #[command(
        subcommand_help_heading = "Discovery & Inspection",
        after_help = "EXAMPLES:\n  justui view button\n  justui view button --file just_button.dart"
    )]
    View {
        /// Component name to view
        component: String,
        /// Specific file within component to inspect
        #[arg(long = "file")]
        file: Option<String>,
        /// Output raw code without formatting
        #[arg(long = "raw")]
        raw: bool,
    },

    /// Display project configuration, installed components, and system status
    #[command(
        subcommand_help_heading = "Discovery & Inspection",
        after_help = "EXAMPLES:\n  justui info"
    )]
    Info {
        /// Optional component name for component specific info
        component: Option<String>,
    },

    /// Check for and upgrade `JustUI` CLI to the latest version
    #[command(
        subcommand_help_heading = "Maintenance & Utility",
        after_help = "EXAMPLES:\n  justui upgrade\n  justui upgrade --check"
    )]
    Upgrade {
        /// Check for available CLI updates without installing
        #[arg(long = "check")]
        check_only: bool,
        /// Force re-installation of the latest release
        #[arg(long = "force")]
        force: bool,
    },

    /// Perform health and environment diagnostics check
    #[command(
        subcommand_help_heading = "Maintenance & Utility",
        after_help = "EXAMPLES:\n  justui doctor"
    )]
    Doctor,

    /// Sign registry index.json using the release keypair (internal utility)
    #[command(hide = true)]
    SignRegistry {
        /// Optional path to registry directory
        #[arg(long)]
        dir: Option<PathBuf>,
    },
}

use commands::preset::PresetSubcommands;

fn main() {
    let default_panic = std::panic::take_hook();
    std::panic::set_hook(Box::new(move |info| {
        let payload = info.to_string();
        if payload.contains("Broken pipe") || payload.contains("os error 32") {
            process::exit(0);
        }
        default_panic(info);
    }));

    let cli = Cli::parse();
    utils::logger::init(cli.quiet, cli.verbose, cli.no_color);
    let auto_yes = cli.auto_yes;

    if let Some(ref path) = cli.cwd
        && let Err(e) = std::env::set_current_dir(path)
    {
        utils::logger::error(&format!(
            "Failed to change working directory to {}: {}",
            path.display(),
            e
        ));
        process::exit(1);
    }

    if cli.version_flag {
        if let Err(e) = commands::upgrade::run(true, false) {
            utils::logger::error(&e.to_string());
            process::exit(1);
        }
        return;
    }

    let Some(command) = cli.command else {
        use clap::CommandFactory;
        Cli::command().print_help().ok();
        utils::logger::stdout("");
        return;
    };

    let result = match command {
        Commands::Version => commands::upgrade::run(true, false),
        Commands::Init {
            preset,
            color_space,
            components_dir,
            tokens_dir,
            experimental,
            dart_target,
            seed,
            dark,
        } => commands::init::run(commands::init::InitArgs {
            preset,
            color_space,
            components_dir,
            tokens_dir,
            auto_yes,
            experimental,
            dart_target,
            seed,
            dark,
        }),
        Commands::Add {
            components,
            dry_run,
            show_diff,
            all,
            overwrite,
        } => commands::add::run(components, dry_run, show_diff, all, overwrite, auto_yes),
        Commands::List { category, json } => commands::list::run(category, json || cli.json),
        Commands::Diff { component, accept } => {
            commands::diff::run(component, cli.verbose > 0, accept, auto_yes)
        }
        Commands::Update => commands::update::run(auto_yes),
        Commands::Upgrade { check_only, force } => commands::upgrade::run(check_only, force),
        Commands::Create {
            component_name,
            category,
            dry_run,
        } => commands::create::run(component_name, category, dry_run, auto_yes),
        Commands::View {
            component,
            file,
            raw,
        } => commands::view::run(component, file, raw, auto_yes),
        Commands::Search { query, category } => commands::search::run(query, category),
        Commands::Info { component } => commands::info::run(component),
        Commands::Preset {
            subcommand,
            name,
            apply,
            list,
            info,
        } => commands::preset::run(subcommand, name, apply, list, info, auto_yes),
        Commands::Doctor => commands::doctor::run(),
        Commands::SignRegistry { dir } => sign_registry_command(dir),
    };

    if let Err(e) = result {
        utils::logger::error(&e.to_string());
        process::exit(1);
    }

    let _ = std::io::stdout().flush();
}

fn sign_registry_command(dir: Option<PathBuf>) -> anyhow::Result<()> {
    let registry_dir = dir.unwrap_or_else(|| {
        if std::path::Path::new("registry/index.json").exists() {
            PathBuf::from("registry")
        } else if std::path::Path::new("../../registry/index.json").exists() {
            PathBuf::from("../../registry")
        } else {
            PathBuf::from("registry")
        }
    });
    let index_path = registry_dir.join("index.json");
    let sig_path = registry_dir.join("index.json.sig");

    let content =
        std::fs::read(&index_path).with_context(|| format!("Reading {}", index_path.display()))?;
    let keypair = utils::crypto::official_keypair();
    let sig_hex = utils::crypto::sign_content(&content, &keypair);
    std::fs::write(&sig_path, format!("{sig_hex}\n"))
        .with_context(|| format!("Writing {}", sig_path.display()))?;

    utils::logger::success(&format!(
        "Signed {} -> {}",
        index_path.display(),
        sig_path.display()
    ));
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use clap::CommandFactory;

    #[test]
    fn verify_cli() {
        Cli::command().debug_assert();
    }
}
