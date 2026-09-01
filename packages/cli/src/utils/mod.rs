pub mod constructor_transpiler;
pub mod diff_formatter;
pub mod embedded_templates;
pub mod env_resolver;
pub mod fvm_detector;
pub mod import_rewriter;
pub mod logger;
pub mod prompt;
pub mod pubspec_editor;
pub mod syntax_highlighter;
pub mod terminal_guard;
pub mod theme_editor;

#[cfg(test)]
pub static TEST_MUTEX: std::sync::Mutex<()> = std::sync::Mutex::new(());

#[cfg(test)]
pub fn lock_test_mutex() -> std::sync::MutexGuard<'static, ()> {
    TEST_MUTEX.lock().unwrap_or_else(|e| e.into_inner())
}

#[cfg(test)]
pub struct DirGuard(pub std::path::PathBuf);

#[cfg(test)]
impl Drop for DirGuard {
    fn drop(&mut self) {
        let _ = std::env::set_current_dir(&self.0);
    }
}

#[cfg(test)]
pub fn set_dir<P: AsRef<std::path::Path>>(p: P) -> DirGuard {
    let orig = std::env::current_dir().unwrap_or_else(|_| std::env::temp_dir());
    let _ = std::env::set_current_dir(p);
    DirGuard(orig)
}
