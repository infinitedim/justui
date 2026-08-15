use clap::{Parser, Subcommand};
use std::process;

mod commands;
mod config;
mod registry;
mod utils;

#[derive(Parser)]
#[command(
    name = "justui",
    about = "JustUI CLI - Scaffolding and copy-paste component tool for Flutter.",
    disable_version_flag = true
)]
struct Cli {
    #[arg(short = 'y', long = "yes", global = true)]
    auto_yes: bool,

    #[arg(short = 'V', long = "version")]
    version_flag: bool,

    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand)]
enum Commands {
    Version,
    Init {
        #[arg(
            long,
            value_parser = clap::builder::PossibleValuesParser::new(["default", "d", "neobrutalism", "neo"])
        )]
        preset: Option<String>,
    },
    Add {
        components: Vec<String>,
        #[arg(long = "dry-run")]
        dry_run: bool,
        #[arg(long = "diff")]
        show_diff: bool,
    },
    List,
    Diff {
        component: String,
        #[arg(short, long)]
        verbose: bool,
    },
    Update,
    Create {
        component_name: Option<String>,
    },
    View {
        component: String,
        #[arg(long = "file")]
        file: Option<String>,
    },
    Search {
        query: String,
        #[arg(long = "category")]
        category: Option<String>,
    },
    Info,
    Preset {
        name: Option<String>,
        #[arg(long = "apply")]
        apply: bool,
        #[arg(long = "list")]
        list: bool,
        #[arg(long = "info")]
        info: Option<String>,
    },
    Upgrade {
        #[arg(long = "check")]
        check_only: bool,
        #[arg(long = "force")]
        force: bool,
    },
}

fn main() {
    let cli = Cli::parse();
    let auto_yes = cli.auto_yes;

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
            name,
            apply,
            list,
            info,
        } => commands::preset::run(name, apply, list, info, auto_yes),
    };

    if let Err(e) = result {
        utils::logger::error(&e.to_string());
        process::exit(1);
    }
}
