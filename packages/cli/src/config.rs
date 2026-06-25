/// Represents the configuration options for JustUI parsed from `justui.config.yaml`.
#[derive(Debug, Clone)]
pub struct JustUIConfig {
    /// Directory where components should be copied (e.g., 'lib/widgets').
    pub components_dir: String,
    /// Directory where design system tokens should be copied (e.g., 'lib/tokens').
    pub tokens_dir: String,
    /// Directory where shared (multi-dependent) components are placed.
    pub shared_dir: String,
    /// Base URL of the remote component registry.
    pub registry_url: String,
}

impl JustUIConfig {
    pub const CONFIG_FILE_NAME: &'static str = "justui.config.yaml";
    pub const DEFAULT_REGISTRY_URL: &'static str =
        "https://raw.githubusercontent.com/infinitedim/justui/main/registry";

    /// Parses config from a YAML string. Falls back to defaults on any error.
    pub fn from_yaml(content: &str) -> Self {
        let parsed: serde_yaml::Value = match serde_yaml::from_str(content) {
            Ok(v) => v,
            Err(_) => return Self::default(),
        };

        let map = match parsed.as_mapping() {
            Some(m) => m,
            None => return Self::default(),
        };

        let get_str = |key: &str| -> Option<String> {
            map.get(key)
                .and_then(|v| v.as_str())
                .map(|s| s.to_string())
        };

        let components_dir =
            get_str("components_dir").unwrap_or_else(|| "lib/widgets".to_string());
        let shared_dir = get_str("shared_dir")
            .unwrap_or_else(|| format!("{}/shared", components_dir));

        Self {
            components_dir,
            tokens_dir: get_str("tokens_dir").unwrap_or_else(|| "lib/tokens".to_string()),
            shared_dir,
            registry_url: get_str("registry_url")
                .unwrap_or_else(|| Self::DEFAULT_REGISTRY_URL.to_string()),
        }
    }

    /// Converts the configuration back into a formatted YAML string.
    /// The comment block is preserved identical to the Dart version.
    pub fn to_yaml_string(&self) -> String {
        format!(
            "# JustUI Scaffolding Configuration\n\
             # Version 1\n\
             \n\
             # Target directory where copied components will be placed\n\
             components_dir: {}\n\
             \n\
             # Target directory where copied token primitives will be placed\n\
             tokens_dir: {}\n\
             \n\
             # Target directory for shared components (used by 2+ other components)\n\
             # All shared files are placed flat inside this directory\n\
             shared_dir: {}\n\
             \n\
             # Base registry URL/path to download component sources from\n\
             registry_url: {}\n",
            self.components_dir, self.tokens_dir, self.shared_dir, self.registry_url
        )
    }
}

impl Default for JustUIConfig {
    fn default() -> Self {
        Self {
            components_dir: "lib/widgets".to_string(),
            tokens_dir: "lib/tokens".to_string(),
            shared_dir: "lib/widgets/shared".to_string(),
            registry_url: Self::DEFAULT_REGISTRY_URL.to_string(),
        }
    }
}
