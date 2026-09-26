use anyhow::{Context, Result};
use semver::Version;
use serde::Deserialize;
use std::env;
use std::fs;

use crate::utils::logger;

#[derive(Deserialize, Debug, Clone, PartialEq, Eq)]
pub struct GitHubAsset {
    pub name: String,
    pub browser_download_url: String,
}

#[derive(Deserialize, Debug, Clone, PartialEq, Eq)]
pub struct GitHubRelease {
    pub tag_name: String,
    pub html_url: String,
    pub body: Option<String>,
    pub assets: Vec<GitHubAsset>,
}

#[derive(Debug, PartialEq, Eq)]
pub enum UpgradeAction {
    AlreadyUpToDate,
    CheckOnly {
        target_version: String,
    },
    NoMatchingAsset {
        target_version: String,
    },
    InvalidVersion {
        raw_tag: String,
    },
    PerformDownload {
        download_url: String,
        target_version: String,
    },
}

fn get_target_triple() -> &'static str {
    let os = env::consts::OS;
    let arch = env::consts::ARCH;
    match (os, arch) {
        ("linux", "x86_64") => "x86_64-unknown-linux-gnu",
        ("linux", "aarch64") => "aarch64-unknown-linux-gnu",
        ("macos", "x86_64") => "x86_64-apple-darwin",
        ("macos", "aarch64") => "aarch64-apple-darwin",
        ("windows", "x86_64") => "x86_64-pc-windows-msvc",
        ("windows", "aarch64") => "aarch64-pc-windows-msvc",
        _ => "",
    }
}

fn get_repo_name() -> String {
    env::var("JUSTUI_REPO").unwrap_or_else(|_| "infinitedim/justui".to_string())
}

pub fn parse_tag_from_location(location: &str) -> Option<String> {
    let after_tag = location
        .rfind("/tag/")
        .map(|idx| &location[idx + 5..])
        .or_else(|| location.rfind("tag/").map(|idx| &location[idx + 4..]))?;
    let clean = after_tag.split('?').next().unwrap_or(after_tag);
    let clean = clean.split('#').next().unwrap_or(clean);
    let clean = clean.trim_matches('/');
    if clean.is_empty() {
        None
    } else {
        Some(clean.to_string())
    }
}

fn resolve_via_redirect(redirect_client: &reqwest::blocking::Client) -> Option<GitHubRelease> {
    let repo = get_repo_name();
    let url = format!("https://github.com/{}/releases/latest", repo);
    let resp = redirect_client
        .head(&url)
        .send()
        .ok()
        .filter(|r| r.status().is_redirection())
        .or_else(|| {
            redirect_client
                .get(&url)
                .send()
                .ok()
                .filter(|r| r.status().is_redirection())
        })?;

    let loc_header = resp
        .headers()
        .get(reqwest::header::LOCATION)?
        .to_str()
        .ok()?;

    let tag = parse_tag_from_location(loc_header)?;
    let target_triple = get_target_triple();
    let assets = if !target_triple.is_empty() {
        let ext = if env::consts::OS == "windows" {
            "zip"
        } else {
            "tar.gz"
        };
        let asset_name = format!("justui-{}.{}", target_triple, ext);
        let download_url = format!(
            "https://github.com/{}/releases/download/{}/{}",
            repo, tag, asset_name
        );
        vec![GitHubAsset {
            name: asset_name,
            browser_download_url: download_url,
        }]
    } else {
        vec![]
    };

    Some(GitHubRelease {
        tag_name: tag.clone(),
        html_url: format!("https://github.com/{}/releases/tag/{}", repo, tag),
        body: None,
        assets,
    })
}

pub fn resolve_latest_version(client: &reqwest::blocking::Client) -> Result<GitHubRelease> {
    // Strategy 1: GitHub Web 302 redirect (rate-limit free)
    let redirect_client = reqwest::blocking::Client::builder()
        .redirect(reqwest::redirect::Policy::none())
        .user_agent("justui-cli")
        .timeout(std::time::Duration::from_secs(10))
        .build();

    if let Ok(redirect_client) = redirect_client {
        if let Some(rel) = resolve_via_redirect(&redirect_client) {
            return Ok(rel);
        }
    }

    let repo = get_repo_name();
    let api_url = format!("https://api.github.com/repos/{}/releases/latest", repo);

    // Strategy 2: Authenticated API if GITHUB_TOKEN or GH_TOKEN is set
    let token = env::var("GITHUB_TOKEN")
        .or_else(|_| env::var("GH_TOKEN"))
        .ok();

    if let Some(token) = token {
        let token = token.trim();
        if !token.is_empty() {
            if let Ok(resp) = client
                .get(&api_url)
                .header(reqwest::header::AUTHORIZATION, format!("Bearer {}", token))
                .header(reqwest::header::USER_AGENT, "justui-cli")
                .header(reqwest::header::ACCEPT, "application/vnd.github.v3+json")
                .send()
            {
                if resp.status().is_success() {
                    if let Ok(rel) = resp.json::<GitHubRelease>() {
                        return Ok(rel);
                    }
                } else if resp.status() == reqwest::StatusCode::NOT_FOUND {
                    anyhow::bail!("No releases found on GitHub repository yet.");
                }
            }
        }
    }

    // Strategy 3: Unauthenticated API last resort
    let resp = client
        .get(&api_url)
        .header(reqwest::header::USER_AGENT, "justui-cli")
        .header(reqwest::header::ACCEPT, "application/vnd.github.v3+json")
        .send()
        .context("Could not connect to GitHub API to check for updates")?;

    if resp.status() == reqwest::StatusCode::NOT_FOUND {
        anyhow::bail!("No releases found on GitHub repository yet.");
    }

    if !resp.status().is_success() {
        anyhow::bail!("GitHub API returned HTTP status {}", resp.status());
    }

    let rel = resp
        .json::<GitHubRelease>()
        .context("Failed to parse GitHub release data")?;

    Ok(rel)
}

pub fn plan_upgrade(
    current_version_str: &str,
    release: &GitHubRelease,
    check_only: bool,
    force: bool,
) -> Result<UpgradeAction> {
    let current_version = Version::parse(current_version_str)
        .with_context(|| format!("Failed to parse local version '{}'", current_version_str))?;

    let clean_tag = release.tag_name.trim_start_matches('v');
    let latest_version = match Version::parse(clean_tag) {
        Ok(v) => v,
        Err(_) => {
            return Ok(UpgradeAction::InvalidVersion {
                raw_tag: release.tag_name.clone(),
            });
        }
    };

    if !force && latest_version <= current_version {
        return Ok(UpgradeAction::AlreadyUpToDate);
    }

    if check_only {
        return Ok(UpgradeAction::CheckOnly {
            target_version: clean_tag.to_string(),
        });
    }

    let target_os = env::consts::OS;
    let target_arch = env::consts::ARCH;
    let target_triple = get_target_triple();

    let asset = release.assets.iter().find(|a| {
        let name = a.name.to_lowercase();

        // Avoid non-archive metadata/checksum files
        if name.ends_with(".sha256")
            || name.ends_with(".sha512")
            || name.ends_with(".sig")
            || name.ends_with(".asc")
            || name.ends_with(".txt")
            || name.ends_with(".md5")
        {
            return false;
        }

        if !target_triple.is_empty() && name.contains(target_triple) {
            return true;
        }

        let os_match =
            name.contains(target_os) || (target_os == "macos" && name.contains("darwin"));

        let arch_match = match target_arch {
            "x86_64" => {
                (name.contains("x86_64") || name.contains("amd64") || name.contains("x64"))
                    && !name.contains("aarch64")
                    && !name.contains("arm64")
            }
            "aarch64" => {
                (name.contains("aarch64") || name.contains("arm64")) && !name.contains("x86_64")
            }
            other => name.contains(other),
        };

        os_match && arch_match
    });

    if let Some(asset) = asset {
        Ok(UpgradeAction::PerformDownload {
            download_url: asset.browser_download_url.clone(),
            target_version: clean_tag.to_string(),
        })
    } else {
        Ok(UpgradeAction::NoMatchingAsset {
            target_version: clean_tag.to_string(),
        })
    }
}

/// File name of the checksum manifest published next to every release archive
/// (see `.github/workflows/release.yaml` and `install/install.sh`).
const CHECKSUM_MANIFEST: &str = "SHA256SUMS";

/// Derives the `SHA256SUMS` URL and the archive file name from an archive URL.
/// Release assets live in one directory, so the manifest is a sibling of the archive.
fn checksum_manifest_location(download_url: &str) -> Result<(String, String)> {
    let without_query = download_url
        .split(['?', '#'])
        .next()
        .unwrap_or(download_url);
    let (base, asset_name) = without_query
        .rsplit_once('/')
        .filter(|(_, name)| !name.is_empty())
        .with_context(|| format!("Cannot derive archive name from URL {}", download_url))?;
    Ok((
        format!("{}/{}", base, CHECKSUM_MANIFEST),
        asset_name.to_string(),
    ))
}

/// Verifies `bytes` against the entry for `asset_name` in a `sha256sum`-style manifest
/// (`<hex>  <name>`, `<hex> *<name>` or `./<name>` per line, matching `install.sh`).
fn verify_sha256(bytes: &[u8], manifest: &str, asset_name: &str) -> Result<()> {
    use sha2::{Digest, Sha256};

    let expected = manifest
        .lines()
        .filter_map(|line| {
            let mut parts = line.split_whitespace();
            let hash = parts.next()?;
            let name = parts.next()?.trim_start_matches('*');
            let name = name.strip_prefix("./").unwrap_or(name);
            Some((hash, name))
        })
        .find(|(_, name)| *name == asset_name)
        .map(|(hash, _)| hash.to_ascii_lowercase())
        .with_context(|| {
            format!(
                "Archive \"{}\" is not listed in {}. Refusing to install an unverified binary.",
                asset_name, CHECKSUM_MANIFEST
            )
        })?;

    let actual = hex::encode(Sha256::digest(bytes));
    if actual != expected {
        anyhow::bail!(
            "Checksum mismatch for \"{}\": expected {}, got {}. The download may be corrupted or tampered with.",
            asset_name,
            expected,
            actual
        );
    }
    Ok(())
}

fn download_and_unpack(client: &reqwest::blocking::Client, download_url: &str) -> Result<Vec<u8>> {
    logger::info(&format!("Downloading update from {}...", download_url));
    let response = client
        .get(download_url)
        .send()
        .with_context(|| format!("Failed to download release archive from {}", download_url))?;

    if !response.status().is_success() {
        anyhow::bail!(
            "Failed to download release archive: HTTP status {}",
            response.status()
        );
    }

    let bytes = response.bytes().context("Failed to read response bytes")?;

    let (manifest_url, asset_name) = checksum_manifest_location(download_url)?;
    let manifest_response = client
        .get(&manifest_url)
        .header(reqwest::header::USER_AGENT, "justui-cli")
        .send()
        .with_context(|| format!("Failed to download checksum manifest from {}", manifest_url))?;
    if !manifest_response.status().is_success() {
        anyhow::bail!(
            "Failed to download checksum manifest {}: HTTP status {}. Refusing to install an unverified binary.",
            manifest_url,
            manifest_response.status()
        );
    }
    let manifest = manifest_response
        .text()
        .context("Failed to read checksum manifest")?;
    verify_sha256(&bytes, &manifest, &asset_name)?;

    let binary_name = if env::consts::OS == "windows" {
        "justui.exe"
    } else {
        "justui"
    };

    let unpacked_bytes =
        unpack_binary_bytes(&bytes, binary_name).context("Failed to unpack downloaded binary")?;

    validate_binary_executable(&unpacked_bytes)
        .context("Validation of downloaded binary failed")?;

    Ok(unpacked_bytes)
}

pub fn execute_upgrade(
    client: &reqwest::blocking::Client,
    download_url: &str,
    clean_tag: &str,
) -> Result<()> {
    let unpacked_bytes = download_and_unpack(client, download_url)?;
    replace_current_executable(&unpacked_bytes)
        .context("Failed to replace current executable with updated binary")?;

    logger::success(&format!(
        "Successfully upgraded JustUI CLI to v{}!",
        clean_tag
    ));

    Ok(())
}

#[cfg(test)]
pub fn execute_upgrade_to_path(
    client: &reqwest::blocking::Client,
    download_url: &str,
    clean_tag: &str,
    target_path: &std::path::Path,
) -> Result<()> {
    let unpacked_bytes = download_and_unpack(client, download_url)?;
    replace_executable_at_path(target_path, &unpacked_bytes)
        .context("Failed to replace current executable with updated binary")?;

    logger::success(&format!(
        "Successfully upgraded JustUI CLI to v{}!",
        clean_tag
    ));

    Ok(())
}

pub fn run(check_only: bool, force: bool) -> Result<()> {
    let current_version_str = env!("CARGO_PKG_VERSION");
    let _current_version = Version::parse(current_version_str)
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

    let release = match resolve_latest_version(&client) {
        Ok(rel) => {
            pb.finish_and_clear();
            rel
        }
        Err(e) => {
            pb.finish_and_clear();
            logger::warning(&format!("Could not check for updates: {}", e));
            return Ok(());
        }
    };

    let plan = match plan_upgrade(current_version_str, &release, check_only, force) {
        Ok(p) => p,
        Err(e) => {
            logger::warning(&format!("Failed to plan upgrade: {}", e));
            return Ok(());
        }
    };

    match plan {
        UpgradeAction::AlreadyUpToDate => {
            logger::success("JustUI CLI is already up to date!");
        }
        UpgradeAction::InvalidVersion { raw_tag } => {
            logger::warning(&format!(
                "GitHub release tag '{}' is not a valid semver.",
                raw_tag
            ));
        }
        UpgradeAction::CheckOnly { target_version } => {
            logger::stdout("");
            logger::info(&format!(
                "New version available: v{} -> v{} ({})",
                current_version_str, target_version, release.html_url
            ));
            print_release_notes(&release);
            logger::stdout("\nRun \"justui upgrade\" to download and install the latest version.");
        }
        UpgradeAction::NoMatchingAsset { target_version } => {
            logger::stdout("");
            logger::info(&format!(
                "New version available: v{} -> v{} ({})",
                current_version_str, target_version, release.html_url
            ));
            print_release_notes(&release);
            logger::warning(&format!(
                "No pre-compiled binary asset matching target ({}-{}) found in release.",
                env::consts::OS,
                env::consts::ARCH
            ));
            print_fallback_instructions();
        }
        UpgradeAction::PerformDownload {
            download_url,
            target_version,
        } => {
            logger::stdout("");
            logger::info(&format!(
                "New version available: v{} -> v{} ({})",
                current_version_str, target_version, release.html_url
            ));
            print_release_notes(&release);

            if cfg!(test) {
                let _ = execute_upgrade;
                logger::info(&format!(
                    "Downloading update from {} (skipped in test mode)...",
                    download_url
                ));
            } else if let Err(e) = execute_upgrade(&client, &download_url, &target_version) {
                logger::warning(&format!("Failed to upgrade: {}", e));
                print_fallback_instructions();
            }
        }
    }

    Ok(())
}

fn print_release_notes(release: &GitHubRelease) {
    if let Some(ref body) = release.body {
        if !body.is_empty() {
            logger::stdout("\nRelease Notes:");
            for line in body.lines().take(10) {
                logger::stdout(&format!("  {}", line));
            }
        }
    }
}

pub fn print_fallback_instructions() {
    logger::stdout("\nYou can update manually using:");
    logger::stdout("  curl -fsSL https://raw.githubusercontent.com/infinitedim/justui/main/packages/cli/install/install.sh | sh");
    logger::stdout(
        "  or download the release directly from https://github.com/infinitedim/justui/releases/latest",
    );
}

fn validate_binary_executable(bytes: &[u8]) -> Result<()> {
    if bytes.is_empty() {
        anyhow::bail!("Extracted binary is empty (0 bytes)");
    }

    let target_os = env::consts::OS;
    let target_arch = env::consts::ARCH;

    if target_os == "linux" {
        if bytes.len() < 20 || &bytes[0..4] != b"\x7fELF" {
            anyhow::bail!("Extracted binary is not a valid ELF executable");
        }
        let e_machine = u16::from_le_bytes([bytes[18], bytes[19]]);
        match target_arch {
            "x86_64" if e_machine != 0x3e => {
                anyhow::bail!(
                    "Downloaded binary architecture (e_machine: {:#x}) does not match system x86_64 architecture",
                    e_machine
                );
            }
            "aarch64" if e_machine != 0xb7 => {
                anyhow::bail!(
                    "Downloaded binary architecture (e_machine: {:#x}) does not match system AArch64 architecture",
                    e_machine
                );
            }
            _ => {}
        }
    } else if target_os == "windows" {
        if bytes.len() < 2 || &bytes[0..2] != b"MZ" {
            anyhow::bail!("Extracted binary is not a valid Windows PE executable");
        }
    } else if target_os == "macos" {
        if bytes.len() < 4 {
            anyhow::bail!("Extracted binary is too small to be a Mach-O executable");
        }
        let magic = &bytes[0..4];
        let is_macho = magic == [0xfe, 0xed, 0xfa, 0xce]
            || magic == [0xce, 0xfa, 0xed, 0xfe]
            || magic == [0xfe, 0xed, 0xfa, 0xcf]
            || magic == [0xcf, 0xfa, 0xed, 0xfe]
            || magic == [0xca, 0xfe, 0xba, 0xbe]
            || magic == [0xbe, 0xba, 0xfe, 0xca]
            || magic == [0xca, 0xfe, 0xba, 0xbf];
        if !is_macho {
            anyhow::bail!("Extracted binary is not a valid macOS Mach-O executable");
        }
    }

    Ok(())
}

fn unpack_binary_bytes(bytes: &[u8], binary_name: &str) -> Result<Vec<u8>> {
    // Check for GZIP magic header (0x1f, 0x8b)
    if bytes.len() >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b {
        return extract_binary_from_tar_gz(bytes, binary_name);
    }

    // Check for ZIP magic header ('P', 'K', 0x03, 0x04)
    if bytes.len() >= 4 && &bytes[0..4] == b"PK\x03\x04" {
        return extract_binary_from_zip(bytes, binary_name);
    }

    // Uncompressed raw binary
    Ok(bytes.to_vec())
}

fn extract_binary_from_tar_gz(gz_bytes: &[u8], binary_name: &str) -> Result<Vec<u8>> {
    use flate2::read::GzDecoder;
    use std::io::Read;

    let mut gz = GzDecoder::new(gz_bytes);
    let mut decompressed = Vec::new();
    gz.read_to_end(&mut decompressed)
        .context("Failed to decompress gzip archive")?;

    let mut cursor = 0;
    while cursor + 512 <= decompressed.len() {
        let header = &decompressed[cursor..cursor + 512];
        if header.iter().all(|&b| b == 0) {
            break; // End of tar stream
        }

        let name = std::str::from_utf8(&header[0..100])
            .unwrap_or("")
            .trim_matches('\0')
            .trim();

        let size_str = std::str::from_utf8(&header[124..136])
            .unwrap_or("")
            .trim_matches('\0')
            .trim();
        let size = usize::from_str_radix(size_str, 8).unwrap_or(0);

        cursor += 512;

        let filename = std::path::Path::new(name)
            .file_name()
            .and_then(|n| n.to_str())
            .unwrap_or("");

        let clean_binary_name = std::path::Path::new(binary_name)
            .file_name()
            .and_then(|n| n.to_str())
            .unwrap_or(binary_name);

        if filename == clean_binary_name || filename == binary_name {
            if cursor + size <= decompressed.len() {
                return Ok(decompressed[cursor..cursor + size].to_vec());
            } else {
                anyhow::bail!("Corrupted tar archive entry size");
            }
        }

        let blocks = size.div_ceil(512);
        cursor += blocks * 512;
    }

    anyhow::bail!("Binary '{}' not found inside tar archive", binary_name)
}

fn extract_binary_from_zip(zip_bytes: &[u8], binary_name: &str) -> Result<Vec<u8>> {
    let temp_dir = tempfile::tempdir().context("Failed to create temp directory")?;
    let zip_path = temp_dir.path().join("update.zip");
    fs::write(&zip_path, zip_bytes).context("Failed to write zip file")?;

    let output_dir = temp_dir.path().join("extracted");
    fs::create_dir_all(&output_dir)?;

    #[cfg(windows)]
    {
        let output = std::process::Command::new("powershell")
            .arg("-NoProfile")
            .arg("-Command")
            .arg(format!(
                "Expand-Archive -Path '{}' -DestinationPath '{}' -Force",
                zip_path.display(),
                output_dir.display()
            ))
            .output()
            .context("Failed to run powershell Expand-Archive")?;

        if !output.status.success() {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("Powershell Expand-Archive failed: {}", stderr.trim());
        }
    }

    #[cfg(not(windows))]
    {
        let output = std::process::Command::new("unzip")
            .arg("-q")
            .arg("-o")
            .arg(&zip_path)
            .arg("-d")
            .arg(&output_dir)
            .output()
            .context("Failed to run unzip command")?;

        if !output.status.success() {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("unzip failed: {}", stderr.trim());
        }
    }

    let target_file = output_dir.join(binary_name);
    if target_file.exists() {
        return fs::read(&target_file).context("Failed to read extracted binary");
    }

    for entry in fs::read_dir(&output_dir)? {
        let entry = entry?;
        if entry.file_name().to_string_lossy() == binary_name {
            return fs::read(entry.path()).context("Failed to read extracted binary");
        }
    }

    anyhow::bail!("Binary '{}' not found inside zip archive", binary_name)
}

fn replace_current_executable(new_bytes: &[u8]) -> Result<()> {
    let current_exe = env::current_exe().context("Failed to get current executable path")?;
    replace_executable_at_path(&current_exe, new_bytes)
}

fn replace_executable_at_path(current_exe: &std::path::Path, new_bytes: &[u8]) -> Result<()> {
    replace_executable_at(current_exe, new_bytes)
}

fn replace_executable_at(current_exe: &std::path::Path, new_bytes: &[u8]) -> Result<()> {
    let temp_exe = current_exe.with_extension("tmp_new");
    fs::write(&temp_exe, new_bytes).context("Failed to write temporary binary")?;

    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        let perms = fs::Permissions::from_mode(0o755);
        let _ = fs::set_permissions(&temp_exe, perms);
    }

    #[cfg(windows)]
    {
        let old_exe = current_exe.with_extension("old");
        if old_exe.exists() {
            let _ = fs::remove_file(&old_exe);
        }
        fs::rename(current_exe, &old_exe).context("Failed to rename running executable to .old")?;

        if let Err(e) = fs::rename(&temp_exe, current_exe) {
            let _ = fs::rename(&old_exe, current_exe);
            return Err(e).context("Failed to place new binary into executable path");
        }

        let _ = fs::remove_file(&old_exe);
    }

    #[cfg(not(windows))]
    {
        let old_exe = current_exe.with_extension("old");
        let _ = fs::remove_file(&old_exe);
        if current_exe.exists() {
            let _ = fs::rename(current_exe, &old_exe);
        }
        if let Err(e) = fs::rename(&temp_exe, current_exe) {
            if old_exe.exists() {
                let _ = fs::rename(&old_exe, current_exe);
            }
            return Err(e).context("Failed to replace binary");
        }
        let _ = fs::remove_file(&old_exe);
    }

    Ok(())
}

#[cfg(test)]
#[path = "upgrade_tests.rs"]
mod tests;
