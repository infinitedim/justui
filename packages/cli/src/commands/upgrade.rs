use anyhow::{Context, Result};
use semver::Version;
use serde::Deserialize;
use std::env;
use std::fs;

use crate::utils::logger;

const GITHUB_RELEASES_API: &str = "https://api.github.com/repos/infinitedim/justui/releases/latest";

#[derive(Deserialize, Debug)]
struct GitHubAsset {
    name: String,
    browser_download_url: String,
}

#[derive(Deserialize, Debug)]
struct GitHubRelease {
    tag_name: String,
    html_url: String,
    body: Option<String>,
    assets: Vec<GitHubAsset>,
}

pub fn run(check_only: bool, force: bool) -> Result<()> {
    let current_version_str = env!("CARGO_PKG_VERSION");
    let current_version = Version::parse(current_version_str)
        .with_context(|| format!("Failed to parse local version '{}'", current_version_str))?;

    logger::stdout(&format!(
        "Current JustUI CLI version: v{}",
        current_version_str
    ));

    let pb = indicatif::ProgressBar::new_spinner();
    pb.set_message("Checking GitHub for latest release...");
    pb.enable_steady_tick(std::time::Duration::from_millis(100));

    let client = match reqwest::blocking::Client::builder()
        .user_agent("justui-cli")
        .build()
    {
        Ok(c) => c,
        Err(e) => {
            pb.finish_and_clear();
            logger::warning(&format!("Failed to initialize HTTP client: {}", e));
            return Ok(());
        }
    };

    let response = match client.get(GITHUB_RELEASES_API).send() {
        Ok(resp) => resp,
        Err(e) => {
            pb.finish_and_clear();
            logger::warning(&format!(
                "Could not connect to GitHub API to check for updates: {}",
                e
            ));
            return Ok(());
        }
    };

    if response.status() == reqwest::StatusCode::NOT_FOUND {
        pb.finish_and_clear();
        logger::info("No releases found on GitHub repository yet.");
        return Ok(());
    }

    if !response.status().is_success() {
        pb.finish_and_clear();
        logger::warning(&format!(
            "GitHub API returned HTTP status {}",
            response.status()
        ));
        return Ok(());
    }

    let release: GitHubRelease = match response.json() {
        Ok(rel) => {
            pb.finish_and_clear();
            rel
        }
        Err(e) => {
            pb.finish_and_clear();
            logger::warning(&format!("Failed to parse GitHub release data: {}", e));
            return Ok(());
        }
    };

    let clean_tag = release.tag_name.trim_start_matches('v');
    let latest_version = match Version::parse(clean_tag) {
        Ok(v) => v,
        Err(_) => {
            logger::warning(&format!(
                "GitHub release tag '{}' is not a valid semver.",
                release.tag_name
            ));
            return Ok(());
        }
    };

    if !force && latest_version <= current_version {
        logger::success("JustUI CLI is already up to date!");
        return Ok(());
    }

    logger::stdout("");
    logger::info(&format!(
        "New version available: v{} -> v{} ({})",
        current_version_str, clean_tag, release.html_url
    ));

    if let Some(body) = release.body {
        if !body.is_empty() {
            logger::stdout("\nRelease Notes:");
            for line in body.lines().take(10) {
                logger::stdout(&format!("  {}", line));
            }
        }
    }

    if check_only {
        logger::stdout("\nRun \"justui upgrade\" to download and install the latest version.");
        return Ok(());
    }

    let target_os = env::consts::OS;
    let target_arch = env::consts::ARCH;
    let expected_asset_name = format!(
        "justui-{}-{}{}",
        target_os,
        target_arch,
        if target_os == "windows" { ".exe" } else { "" }
    );

    let asset = release
        .assets
        .iter()
        .find(|a| a.name.eq_ignore_ascii_case(&expected_asset_name) || a.name.contains(target_os));

    if let Some(asset) = asset {
        logger::info(&format!(
            "Downloading binary update from {}...",
            asset.browser_download_url
        ));

        let pb_dl = indicatif::ProgressBar::new_spinner();
        pb_dl.set_message("Downloading binary...");
        pb_dl.enable_steady_tick(std::time::Duration::from_millis(100));

        let dl_resp = match client.get(&asset.browser_download_url).send() {
            Ok(r) => r,
            Err(e) => {
                pb_dl.finish_and_clear();
                logger::error(&format!("Download failed: {}", e));
                print_fallback_instructions();
                return Ok(());
            }
        };

        if !dl_resp.status().is_success() {
            pb_dl.finish_and_clear();
            logger::error(&format!(
                "Failed to download asset: HTTP {}",
                dl_resp.status()
            ));
            print_fallback_instructions();
            return Ok(());
        }

        let bytes = match dl_resp.bytes() {
            Ok(b) => b,
            Err(e) => {
                pb_dl.finish_and_clear();
                logger::error(&format!("Failed to read binary bytes: {}", e));
                print_fallback_instructions();
                return Ok(());
            }
        };
        pb_dl.finish_and_clear();

        match replace_current_executable(&bytes) {
            Ok(_) => {
                logger::success(&format!(
                    "Successfully upgraded JustUI CLI to v{}!",
                    clean_tag
                ));
            }
            Err(e) => {
                logger::warning(&format!("Could not auto-replace executable: {}", e));
                print_fallback_instructions();
            }
        }
    } else {
        logger::warning(&format!(
            "No pre-compiled binary asset matching target ({}-{}) found in release.",
            target_os, target_arch
        ));
        print_fallback_instructions();
    }

    Ok(())
}

fn replace_current_executable(new_bytes: &[u8]) -> Result<()> {
    let current_exe = env::current_exe().context("Failed to get current executable path")?;
    let temp_exe = current_exe.with_extension("tmp_new");

    fs::write(&temp_exe, new_bytes).context("Failed to write temporary binary")?;

    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        let mut perms = fs::metadata(&temp_exe)?.permissions();
        perms.set_mode(0o755);
        fs::set_permissions(&temp_exe, perms)?;
    }

    fs::rename(&temp_exe, &current_exe).context("Failed to replace binary")?;
    Ok(())
}

fn print_fallback_instructions() {
    logger::stdout("\nYou can update manually using:");
    logger::stdout("  cargo install justui --force");
    logger::stdout(
        "  or download the release directly from https://github.com/infinitedim/justui/releases",
    );
}
