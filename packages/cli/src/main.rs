use clap::{Parser, Subcommand};
use std::process;

mod commands;
mod config;
mod registry;
mod utils;

#[derive(Parser)]
#[command(
    name = "justui",
    about = "JustUI CLI - Scaffolding and copy-paste component tool for Flutter."
)]
struct Cli {
    /// Skip all confirmation prompts and use default values automatically.
    #[arg(short = 'y', long = "yes", global = true)]
    auto_yes: bool,

    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Initialize JustUI configuration and themes in the project root.
    Init {
        /// Theme preset style to initialize. Aliases: neo=neobrutalism, d=default.
        #[arg(
            long,
            value_parser = clap::builder::PossibleValuesParser::new(["default", "d", "neobrutalism", "neo"])
        )]
        preset: Option<String>,
    },
    /// Add a component and its dependencies to your project.
    Add {
        /// Component names to add
        components: Vec<String>,
        /// Preview files that will be written without writing to disk.
        #[arg(long = "dry-run")]
        dry_run: bool,
        /// Show diff of each file before writing. Implicitly enables --dry-run.
        #[arg(long = "diff")]
        show_diff: bool,
    },
    /// List all available components in the registry.
    List,
    /// Show differences between local components and registry files.
    Diff {
        /// Component name to diff
        component: String,
        /// Show line-by-line diff details of modifications.
        #[arg(short, long)]
        verbose: bool,
    },
    /// Update installed components to the latest registry version.
    Update,
    /// Scaffold a standard 4-file bundle for a custom component.
    Create {
        /// Component name to scaffold
        component_name: Option<String>,
    },
    /// View the source code of a registry component.
    View {
        /// Component name to view
        component: String,
        /// Show only a specific file from the component.
        #[arg(long = "file")]
        file: Option<String>,
    },
    /// Search for components in the registry.
    Search {
        /// Search query (matches name, description, or category)
        query: String,
        /// Filter results by category.
        #[arg(long = "category")]
        category: Option<String>,
    },
    /// Show information about the CLI, config, project, and registry.
    Info,
    /// Manage style presets for installed components.
    Preset {
        /// Preset name to apply or inspect.
        name: Option<String>,
        /// Apply the specified preset to all installed components.
        #[arg(long = "apply")]
        apply: bool,
        /// List all available presets in the registry.
        #[arg(long = "list")]
        list: bool,
        /// Show info about a specific preset.
        #[arg(long = "info")]
        info: Option<String>,
    },
}

fn main() {
    let cli = Cli::parse();
    let auto_yes = cli.auto_yes;

    let result = match cli.command {
        Commands::Init { preset } => commands::init::run(preset, auto_yes),
        Commands::Add {
            components,
            dry_run,
            show_diff,
        } => commands::add::run(components, dry_run, show_diff, auto_yes),
        Commands::List => commands::list::run(),
        Commands::Diff { component, verbose } => commands::diff::run(component, verbose, auto_yes),
        Commands::Update => commands::update::run(auto_yes),
        Commands::Create { component_name } => commands::create::run(component_name, auto_yes),
        Commands::View { component, file } => commands::view::run(component, file, auto_yes),
        Commands::Search { query, category } => commands::search::run(query, category),
        Commands::Info => commands::info::run(),
        Commands::Preset { name, apply, list, info } => {
            commands::preset::run(name, apply, list, info, auto_yes)
        }
    };

    if let Err(e) = result {
        utils::logger::error(&e.to_string());
        process::exit(1);
    }
}
