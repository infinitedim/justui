#[derive(Debug, Clone, PartialEq, Eq)]
pub struct JustUIConfig {
    pub version: u32,

    pub components_dir: String,

    pub tokens_dir: String,

    pub shared_dir: String,

    pub registry_url: String,

    pub preset: String,

    pub color_space: String,

    pub dart_target: crate::utils::env_resolver::DartTarget,
}

impl JustUIConfig {
    pub const CURRENT_VERSION: u32 = 1;
    pub const CONFIG_FILE_NAME: &'static str = "justui.config.yaml";
    pub const DEFAULT_REGISTRY_URL: &'static str = concat!(
        "https://raw.githubusercontent.com/infinitedim/justui/v",
        env!("CARGO_PKG_VERSION"),
        "/registry"
    );

    pub const KNOWN_FIELDS: &'static [&'static str] = &[
        "version",
        "components_dir",
        "tokens_dir",
        "shared_dir",
        "registry_url",
        "preset",
        "color_space",
        "dart_target",
    ];

    fn check_unknown_fields(map: &serde_yaml::Mapping) {
        for (key, _) in map {
            if let Some(k) = key.as_str()
                && !Self::KNOWN_FIELDS.contains(&k)
            {
                crate::utils::logger::warning(&format!(
                    "Unknown configuration field in {}: '{k}'",
                    Self::CONFIG_FILE_NAME
                ));
            }
        }
    }

    fn migrate_version(from_version: u32, _map: &serde_yaml::Mapping) -> u32 {
        if from_version == 0 {
            // Unversioned legacy configuration migrated to current schema
            return Self::CURRENT_VERSION;
        }
        from_version
    }

    pub fn from_yaml(content: &str) -> Self {
        let Ok(parsed) = serde_yaml::from_str::<serde_yaml::Value>(content) else {
            return Self::default();
        };

        let Some(map) = parsed.as_mapping() else {
            return Self::default();
        };

        Self::check_unknown_fields(map);

        let raw_version = map
            .get("version")
            .and_then(serde_yaml::Value::as_u64)
            .and_then(|v| u32::try_from(v).ok())
            .unwrap_or(0);

        let version = Self::migrate_version(raw_version, map);

        let get_str = |key: &str| -> Option<String> {
            map.get(key)
                .and_then(|v| v.as_str())
                .map(std::string::ToString::to_string)
        };

        let components_dir = get_str("components_dir").unwrap_or_else(|| "lib/widgets".to_string());
        let shared_dir =
            get_str("shared_dir").unwrap_or_else(|| format!("{components_dir}/shared"));
        let preset = get_str("preset").unwrap_or_else(|| "default".to_string());
        let color_space = get_str("color_space").unwrap_or_else(|| "hsl".to_string());

        let dart_target = get_str("dart_target")
            .and_then(|s| match s.as_str() {
                "primary" => Some(crate::utils::env_resolver::DartTarget::Primary),
                "standard" => Some(crate::utils::env_resolver::DartTarget::Standard),
                _ => None,
            })
            .unwrap_or(crate::utils::env_resolver::DartTarget::Standard);

        Self {
            version,
            components_dir,
            tokens_dir: get_str("tokens_dir").unwrap_or_else(|| "lib/tokens".to_string()),
            shared_dir,
            registry_url: get_str("registry_url")
                .unwrap_or_else(|| Self::DEFAULT_REGISTRY_URL.to_string()),
            preset,
            color_space,
            dart_target,
        }
    }

    pub fn to_yaml_string(&self) -> String {
        format!(
            "# JustUI Scaffolding Configuration\n\
             # Version {version}\n\
             \n\
             version: {version}\n\
             \n\
             # Target directory where copied components will be placed\n\
             components_dir: {comp}\n\
             \n\
             # Target directory where copied token primitives will be placed\n\
             tokens_dir: {tok}\n\
             \n\
             # Target directory for shared components (used by 2+ other components)\n\
             # All shared files are placed flat inside this directory\n\
             shared_dir: {shared}\n\
             \n\
             # Base registry URL/path to download component sources from\n\
             registry_url: {reg}\n\
             \n\
             # Active style preset to use (e.g., 'default', 'neobrutalism')\n\
             preset: {preset}\n\
             \n\
             # Active color space engine to use (e.g., 'hsl', 'oklch', 'hsluv')\n\
             color_space: {cs}\n\
             \n\
             # Target Dart constructor syntax ('primary' or 'standard')\n\
             dart_target: {dt}\n",
            version = self.version,
            comp = self.components_dir,
            tok = self.tokens_dir,
            shared = self.shared_dir,
            reg = self.registry_url,
            preset = self.preset,
            cs = self.color_space,
            dt = match self.dart_target {
                crate::utils::env_resolver::DartTarget::Primary => "primary",
                crate::utils::env_resolver::DartTarget::Standard => "standard",
            }
        )
    }
}

impl Default for JustUIConfig {
    fn default() -> Self {
        Self {
            version: Self::CURRENT_VERSION,
            components_dir: "lib/widgets".to_string(),
            tokens_dir: "lib/tokens".to_string(),
            shared_dir: "lib/widgets/shared".to_string(),
            registry_url: Self::DEFAULT_REGISTRY_URL.to_string(),
            preset: "default".to_string(),
            color_space: "hsl".to_string(),
            dart_target: crate::utils::env_resolver::DartTarget::Standard,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_config_default_and_yaml() {
        let def = JustUIConfig::default();
        assert_eq!(def.version, 1);
        assert_eq!(def.components_dir, "lib/widgets");
        assert_eq!(def.tokens_dir, "lib/tokens");
        assert_eq!(def.shared_dir, "lib/widgets/shared");
        assert_eq!(def.preset, "default");
        assert_eq!(def.color_space, "hsl");

        let yaml = def.to_yaml_string();
        assert!(yaml.contains("version: 1"));
        let parsed = JustUIConfig::from_yaml(&yaml);
        assert_eq!(parsed.version, 1);
        assert_eq!(parsed.components_dir, def.components_dir);
        assert_eq!(parsed.tokens_dir, def.tokens_dir);
        assert_eq!(parsed.shared_dir, def.shared_dir);
        assert_eq!(parsed.preset, def.preset);
        assert_eq!(parsed.color_space, def.color_space);
    }

    #[test]
    fn test_config_migration_from_v0_and_unknown_fields() {
        let legacy_yaml = "components_dir: lib/custom\nunknown_future_field: true\n";
        let parsed = JustUIConfig::from_yaml(legacy_yaml);
        assert_eq!(parsed.version, 1);
        assert_eq!(parsed.components_dir, "lib/custom");
    }
}
