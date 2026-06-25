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
}

fn main() {
    let cli = Cli::parse();

    let result = match cli.command {
        Commands::Init { preset } => commands::init::run(preset),
        Commands::Add { components } => commands::add::run(components),
        Commands::List => commands::list::run(),
        Commands::Diff { component, verbose } => commands::diff::run(component, verbose),
        Commands::Update => commands::update::run(),
        Commands::Create { component_name } => commands::create::run(component_name),
    };

    if let Err(e) = result {
        utils::logger::error(&e.to_string());
        process::exit(1);
    }
}
