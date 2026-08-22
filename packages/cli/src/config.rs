#[derive(Debug, Clone)]
pub struct JustUIConfig {
    pub components_dir: String,

    pub tokens_dir: String,

    pub shared_dir: String,

    pub registry_url: String,

    pub preset: String,
}

impl JustUIConfig {
    pub const CONFIG_FILE_NAME: &'static str = "justui.config.yaml";
    pub const DEFAULT_REGISTRY_URL: &'static str =
        "https://raw.githubusercontent.com/infinitedim/justui/main/registry";

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
            map.get(key).and_then(|v| v.as_str()).map(|s| s.to_string())
        };

        let components_dir = get_str("components_dir").unwrap_or_else(|| "lib/widgets".to_string());
        let shared_dir =
            get_str("shared_dir").unwrap_or_else(|| format!("{}/shared", components_dir));
        let preset = get_str("preset").unwrap_or_else(|| "default".to_string());

        Self {
            components_dir,
            tokens_dir: get_str("tokens_dir").unwrap_or_else(|| "lib/tokens".to_string()),
            shared_dir,
            registry_url: get_str("registry_url")
                .unwrap_or_else(|| Self::DEFAULT_REGISTRY_URL.to_string()),
            preset,
        }
    }

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
             registry_url: {}\n\
             \n\
             # Active style preset to use (e.g., 'default', 'neobrutalism')\n\
             preset: {}\n",
            self.components_dir, self.tokens_dir, self.shared_dir, self.registry_url, self.preset
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
            preset: "default".to_string(),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_config_default_and_yaml() {
        let def = JustUIConfig::default();
        assert_eq!(def.components_dir, "lib/widgets");
        assert_eq!(def.tokens_dir, "lib/tokens");
        assert_eq!(def.shared_dir, "lib/widgets/shared");
        assert_eq!(def.preset, "default");

        let yaml = def.to_yaml_string();
        let parsed = JustUIConfig::from_yaml(&yaml);
        assert_eq!(parsed.components_dir, def.components_dir);
        assert_eq!(parsed.tokens_dir, def.tokens_dir);
        assert_eq!(parsed.shared_dir, def.shared_dir);
        assert_eq!(parsed.preset, def.preset);
    }
}
