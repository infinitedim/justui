use clap::{Parser, Subcommand};
use std::path::PathBuf;
use std::process;

mod commands;
mod config;
mod registry;
mod utils;

/// JustUI CLI - High-performance Flutter UI scaffolding and copy-paste component tool
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

    /// Initialize JustUI configuration and theme tokens in a Flutter project
    #[command(
        subcommand_help_heading = "Project Setup & Scaffolding",
        after_help = "EXAMPLES:\n  justui init\n  justui init --preset neobrutalism -y"
    )]
    Init {
        /// Visual style preset to apply during initialization (default, neobrutalism)
        #[arg(
            long,
            value_parser = clap::builder::PossibleValuesParser::new(["default", "d", "neobrutalism", "neo"])
        )]
        preset: Option<String>,
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
    },

    /// Synchronize local components with upstream registry updates
    #[command(
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
    },

    /// Inspect local component modifications vs upstream registry source code
    #[command(
        subcommand_help_heading = "Component Lifecycle",
        after_help = "EXAMPLES:\n  justui diff button\n  justui diff button --verbose"
    )]
    Diff {
        /// Component name to inspect
        component: String,
        /// Show detailed line-by-line diff breakdown
        #[arg(short, long)]
        verbose: bool,
    },

    /// List all available components in the JustUI registry
    #[command(
        subcommand_help_heading = "Discovery & Inspection",
        after_help = "EXAMPLES:\n  justui list"
    )]
    List,

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
    },

    /// Display project configuration, installed components, and system status
    #[command(
        subcommand_help_heading = "Discovery & Inspection",
        after_help = "EXAMPLES:\n  justui info"
    )]
    Info,

    /// Check for and upgrade JustUI CLI to the latest version
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
}

use commands::preset::PresetSubcommands;

fn main() {
    let cli = Cli::parse();
    let auto_yes = cli.auto_yes;

    if let Some(ref path) = cli.cwd {
        if let Err(e) = std::env::set_current_dir(path) {
            utils::logger::error(&format!(
                "Failed to change working directory to {}: {}",
                path.display(),
                e
            ));
            process::exit(1);
        }
    }

    if cli.version_flag {
        if let Err(e) = commands::upgrade::run(true, false) {
            utils::logger::error(&e.to_string());
            process::exit(1);
        }
        return;
    }

    let command = match cli.command {
        Some(cmd) => cmd,
        None => {
            use clap::CommandFactory;
            Cli::command().print_help().ok();
            println!();
            return;
        }
    };

    let result = match command {
        Commands::Version => commands::upgrade::run(true, false),
        Commands::Init { preset } => commands::init::run(preset, auto_yes),
        Commands::Add {
            components,
            dry_run,
            show_diff,
        } => commands::add::run(components, dry_run, show_diff, auto_yes),
        Commands::List => commands::list::run(),
        Commands::Diff { component, verbose } => commands::diff::run(component, verbose, auto_yes),
        Commands::Update => commands::update::run(auto_yes),
        Commands::Upgrade { check_only, force } => commands::upgrade::run(check_only, force),
        Commands::Create { component_name } => commands::create::run(component_name, auto_yes),
        Commands::View { component, file } => commands::view::run(component, file, auto_yes),
        Commands::Search { query, category } => commands::search::run(query, category),
        Commands::Info => commands::info::run(),
        Commands::Preset {
            subcommand,
            name,
            apply,
            list,
            info,
        } => commands::preset::run(subcommand, name, apply, list, info, auto_yes),
    };

    if let Err(e) = result {
        utils::logger::error(&e.to_string());
        process::exit(1);
    }
}
