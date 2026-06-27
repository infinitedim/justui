use anyhow::Result;
use std::collections::HashMap;

use crate::config::JustUIConfig;
use crate::registry::RegistryClient;
use crate::utils::logger;

/// Runs the `justui list` command.
pub fn run() -> Result<()> {
    // 1. Resolve registry URL from configuration or use default
    let registry_url = if let Ok(content) = std::fs::read_to_string(JustUIConfig::CONFIG_FILE_NAME)
    {
        JustUIConfig::from_yaml(&content).registry_url
    } else {
        JustUIConfig::DEFAULT_REGISTRY_URL.to_string()
    };

    let pb_index = indicatif::ProgressBar::new_spinner();
    pb_index.set_message("Fetching component registry...");
    pb_index.enable_steady_tick(std::time::Duration::from_millis(100));

    let client = RegistryClient::new(registry_url);
    let index = match client.fetch_index() {
        Ok(idx) => {
            pb_index.finish_and_clear();
            idx
        }
        Err(e) => {
            pb_index.finish_and_clear();
            logger::error(&format!("Failed to list components: {}", e));
            return Ok(());
        }
    };

    if index.components.is_empty() {
        logger::warning("No components found in the registry.");
        return Ok(());
    }

    logger::stdout("\nAvailable components:");

    // Group components by category (preserving insertion order)
    let mut grouped: HashMap<String, Vec<_>> = HashMap::new();
    let mut category_order: Vec<String> = Vec::new();
    for comp in &index.components {
        if !grouped.contains_key(&comp.category) {
            category_order.push(comp.category.clone());
        }
        grouped.entry(comp.category.clone()).or_default().push(comp);
    }

    for category in &category_order {
        let comps = &grouped[category];

        // Capitalize first letter of category
        let capitalized = {
            let mut chars = category.chars();
            match chars.next() {
                None => String::new(),
                Some(c) => c.to_uppercase().to_string() + chars.as_str(),
            }
        };
        logger::stdout(&format!("  {}:", capitalized));

        for comp in comps {
            // Green bullet
            let dot = "\x1B[32m●\x1B[0m";
            let name_str = format!("{:<16}", comp.name);
            let version_str = format!("({:<})", comp.version);
            let version_padded = format!("{:<10}", version_str);
            logger::stdout(&format!(
                "    {} {} {} {}",
                dot, name_str, version_padded, comp.description
            ));
        }
    }
    logger::stdout("");

    Ok(())
}
