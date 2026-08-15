use anyhow::Result;
use std::collections::HashMap;

use crate::config::JustUIConfig;
use crate::registry::{RegistryClient, RegistryComponent};
use crate::utils::logger;

pub fn run(query: String, category: Option<String>) -> Result<()> {
    let registry_url = if let Ok(content) = std::fs::read_to_string(JustUIConfig::CONFIG_FILE_NAME)
    {
        JustUIConfig::from_yaml(&content).registry_url
    } else {
        JustUIConfig::DEFAULT_REGISTRY_URL.to_string()
    };

    let client = RegistryClient::new(registry_url);
    let index = match client.fetch_index() {
        Ok(idx) => idx,
        Err(e) => {
            logger::error(&format!("Failed to fetch registry: {}", e));
            return Ok(());
        }
    };

    let query_lc = query.to_lowercase();
    let category_lc = category.as_deref().map(|c| c.to_lowercase());

    let mut name_matches: Vec<&RegistryComponent> = Vec::new();
    let mut other_matches: Vec<&RegistryComponent> = Vec::new();

    for comp in &index.components {
        let name_lc = comp.name.to_lowercase();
        let desc_lc = comp.description.to_lowercase();
        let cat_lc = comp.category.to_lowercase();

        if let Some(ref cf) = category_lc {
            if &cat_lc != cf {
                continue;
            }
        }

        let name_match = name_lc.contains(&query_lc);
        let desc_match = desc_lc.contains(&query_lc);
        let cat_match = cat_lc.contains(&query_lc);

        if name_match {
            name_matches.push(comp);
        } else if desc_match || cat_match {
            other_matches.push(comp);
        }
    }

    let results: Vec<&RegistryComponent> = name_matches.into_iter().chain(other_matches).collect();

    if results.is_empty() {
        logger::stdout(&format!("No components found matching \"{}\".", query));
        return Ok(());
    }

    logger::stdout(&format!("Search results for \"{}\":\n", query));

    let mut grouped: HashMap<String, Vec<&&RegistryComponent>> = HashMap::new();
    let mut category_order: Vec<String> = Vec::new();
    for comp in &results {
        if !grouped.contains_key(&comp.category) {
            category_order.push(comp.category.clone());
        }
        grouped.entry(comp.category.clone()).or_default().push(comp);
    }

    for cat in &category_order {
        let comps = &grouped[cat];

        let capitalized = {
            let mut chars = cat.chars();
            match chars.next() {
                None => String::new(),
                Some(c) => c.to_uppercase().to_string() + chars.as_str(),
            }
        };
        logger::stdout(&format!("  {}:", capitalized));

        for comp in comps {
            let dot = "\x1B[32m●\x1B[0m";

            let highlighted_name = highlight_query(&comp.name, &query_lc);

            let visible_name_len = comp.name.len();
            let name_padding = if visible_name_len < 16 {
                " ".repeat(16 - visible_name_len)
            } else {
                String::new()
            };
            let version_str = format!("(v{})", comp.version);
            let version_padded = format!("{:<10}", version_str);
            logger::stdout(&format!(
                "    {} {}{} {} {}",
                dot, highlighted_name, name_padding, version_padded, comp.description
            ));
        }
    }

    logger::stdout("");
    logger::stdout(&format!("{} component(s) found.", results.len()));

    Ok(())
}

fn highlight_query(text: &str, query: &str) -> String {
    if query.is_empty() {
        return text.to_string();
    }

    let text_lc = text.to_lowercase();
    let mut result = String::new();
    let mut last = 0usize;
    let mut search_from = 0usize;

    while let Some(pos) = text_lc[search_from..].find(query) {
        let abs_pos = search_from + pos;
        result.push_str(&text[last..abs_pos]);
        result.push_str("\x1B[33m");
        result.push_str(&text[abs_pos..abs_pos + query.len()]);
        result.push_str("\x1B[0m");
        last = abs_pos + query.len();
        search_from = last;
        if search_from >= text.len() {
            break;
        }
    }
    result.push_str(&text[last..]);
    result
}
