pub mod diff_formatter;
pub mod embedded_templates;
pub mod env_resolver;
pub mod fvm_detector;
pub mod import_rewriter;
pub mod logger;
pub mod prompt;
pub mod pubspec_editor;
pub mod syntax_highlighter;
pub mod theme_editor;

#[cfg(test)]
pub static TEST_MUTEX: std::sync::Mutex<()> = std::sync::Mutex::new(());
