use crossterm::{
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use std::io::{self, stdout};
use std::panic;

/// RAII Guard that enables terminal raw mode and alternate screen upon creation,
/// and guarantees clean restoration of normal terminal state upon drop (including panics).
pub struct TerminalGuard {
    active: bool,
}

impl TerminalGuard {
    /// Creates a dummy (inactive) guard that performs no terminal manipulations. Useful for unit tests.
    #[allow(dead_code)]
    pub fn dummy() -> Self {
        Self { active: false }
    }

    /// Enables raw mode, enters alternate screen, and installs a panic hook for cleanup.
    pub fn enter() -> io::Result<Self> {
        let prev_hook = panic::take_hook();
        panic::set_hook(Box::new(move |info| {
            let _ = disable_raw_mode();
            let _ = execute!(stdout(), LeaveAlternateScreen);
            prev_hook(info);
        }));

        enable_raw_mode()?;
        execute!(stdout(), EnterAlternateScreen)?;

        Ok(Self { active: true })
    }

    /// Temporarily exit alternate screen & raw mode (e.g. for executing bulk install output).
    pub fn leave_temporarily(&mut self) -> io::Result<()> {
        if self.active {
            disable_raw_mode()?;
            execute!(stdout(), LeaveAlternateScreen)?;
            self.active = false;
        }
        Ok(())
    }

    /// Re-enter alternate screen & raw mode.
    pub fn re_enter(&mut self) -> io::Result<()> {
        if !self.active {
            enable_raw_mode()?;
            execute!(stdout(), EnterAlternateScreen)?;
            self.active = true;
        }
        Ok(())
    }
}

impl Drop for TerminalGuard {
    fn drop(&mut self) {
        if self.active {
            let _ = disable_raw_mode();
            let _ = execute!(stdout(), LeaveAlternateScreen);
            self.active = false;
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_terminal_guard_struct() {
        let guard = TerminalGuard { active: false };
        assert!(!guard.active);
    }
}
