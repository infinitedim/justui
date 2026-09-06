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
mod tests {
    use super::*;

    #[test]
    fn test_target_triple_not_empty() {
        let triple = get_target_triple();
        assert!(
            !triple.is_empty(),
            "Target triple should be known for this platform"
        );
    }

    #[test]
    fn test_parse_tag_from_location() {
        assert_eq!(
            parse_tag_from_location("https://github.com/infinitedim/justui/releases/tag/v0.12.2"),
            Some("v0.12.2".to_string())
        );
        assert_eq!(
            parse_tag_from_location("/infinitedim/justui/releases/tag/v1.0.0"),
            Some("v1.0.0".to_string())
        );
        assert_eq!(
            parse_tag_from_location("https://github.com/infinitedim/justui/releases/tag/v2.3.4/"),
            Some("v2.3.4".to_string())
        );
        assert_eq!(
            parse_tag_from_location(
                "https://github.com/infinitedim/justui/releases/tag/v2.3.4?source=web"
            ),
            Some("v2.3.4".to_string())
        );
        assert_eq!(
            parse_tag_from_location(
                "https://github.com/infinitedim/justui/releases/tag/v2.3.4#notes"
            ),
            Some("v2.3.4".to_string())
        );
        assert_eq!(
            parse_tag_from_location("https://github.com/infinitedim/justui/releases/latest"),
            None
        );
        assert_eq!(
            parse_tag_from_location("https://github.com/infinitedim/justui/releases/tag/"),
            None
        );
        assert_eq!(parse_tag_from_location(""), None);
    }

    #[test]
    fn test_unpack_raw_binary() {
        let raw_bytes = b"\x7fELF_fake_binary_content";
        let unpacked = unpack_binary_bytes(raw_bytes, "justui").unwrap();
        assert_eq!(unpacked, raw_bytes);
    }

    #[test]
    fn test_unpack_tar_gz_archive() {
        use flate2::write::GzEncoder;
        use flate2::Compression;
        use std::io::Write;

        let binary_content = b"hello world executable bytes";
        let mut tar_bytes = vec![0u8; 1024];

        tar_bytes[0..6].copy_from_slice(b"justui");
        let octal_size = format!("{:011o} ", binary_content.len());
        tar_bytes[124..136].copy_from_slice(octal_size.as_bytes());
        tar_bytes[156] = b'0';

        tar_bytes[512..512 + binary_content.len()].copy_from_slice(binary_content);

        let mut encoder = GzEncoder::new(Vec::new(), Compression::default());
        encoder.write_all(&tar_bytes).unwrap();
        let gz_bytes = encoder.finish().unwrap();

        let extracted = unpack_binary_bytes(&gz_bytes, "justui").unwrap();
        assert_eq!(extracted, binary_content);

        // Subpath match test: "bin/justui"
        let mut tar_bytes_sub = vec![0u8; 1024];
        tar_bytes_sub[0..10].copy_from_slice(b"bin/justui");
        tar_bytes_sub[124..136].copy_from_slice(octal_size.as_bytes());
        tar_bytes_sub[156] = b'0';
        tar_bytes_sub[512..512 + binary_content.len()].copy_from_slice(binary_content);
        let mut encoder_sub = GzEncoder::new(Vec::new(), Compression::default());
        encoder_sub.write_all(&tar_bytes_sub).unwrap();
        let gz_bytes_sub = encoder_sub.finish().unwrap();
        let extracted_sub = unpack_binary_bytes(&gz_bytes_sub, "justui").unwrap();
        assert_eq!(extracted_sub, binary_content);
    }

    #[test]
    fn test_tar_gz_archive_corrupted_or_missing() {
        use flate2::write::GzEncoder;
        use flate2::Compression;
        use std::io::Write;

        // Tar with size beyond buffer
        let mut tar_bytes = vec![0u8; 512];
        tar_bytes[0..6].copy_from_slice(b"justui");
        let octal_size = format!("{:011o} ", 10000);
        tar_bytes[124..136].copy_from_slice(octal_size.as_bytes());
        tar_bytes[156] = b'0';

        let mut encoder = GzEncoder::new(Vec::new(), Compression::default());
        encoder.write_all(&tar_bytes).unwrap();
        let gz_bytes = encoder.finish().unwrap();
        assert!(extract_binary_from_tar_gz(&gz_bytes, "justui").is_err());
    }

    #[test]
    fn test_unpack_zip_archive() {
        let temp_dir = tempfile::tempdir().unwrap();
        let binary_path = temp_dir.path().join("justui");
        std::fs::write(&binary_path, b"zip binary contents").unwrap();

        // Create zip using system zip command if available
        let zip_status = std::process::Command::new("zip")
            .arg("update.zip")
            .arg("justui")
            .current_dir(temp_dir.path())
            .status();

        if let Ok(status) = zip_status {
            if status.success() {
                let zip_bytes = std::fs::read(temp_dir.path().join("update.zip")).unwrap();
                let extracted = unpack_binary_bytes(&zip_bytes, "justui").unwrap();
                assert_eq!(extracted, b"zip binary contents");

                // Missing binary in zip
                assert!(unpack_binary_bytes(&zip_bytes, "missing_bin").is_err());
            }
        }

        // Invalid zip bytes test
        let invalid_zip = b"PK\x03\x04invalid_zip_header_bytes";
        assert!(extract_binary_from_zip(invalid_zip, "justui").is_err());
    }

    #[test]
    fn test_validate_binary_executable() {
        assert!(validate_binary_executable(&[]).is_err());

        // Short bytes < 20
        assert!(validate_binary_executable(b"\x7fELF_short").is_err());

        #[cfg(target_os = "linux")]
        {
            // Invalid ELF header
            assert!(
                validate_binary_executable(b"not_an_elf_binary_file_header_long_enough").is_err()
            );

            // Invalid architecture (e_machine mismatch)
            let mut bad_arch_elf = vec![0u8; 64];
            bad_arch_elf[0..4].copy_from_slice(b"\x7fELF");
            bad_arch_elf[18] = 0x00;
            bad_arch_elf[19] = 0x00;
            assert!(validate_binary_executable(&bad_arch_elf).is_err());

            let mut valid_elf = vec![0u8; 64];
            valid_elf[0..4].copy_from_slice(b"\x7fELF");
            #[cfg(target_arch = "x86_64")]
            {
                valid_elf[18] = 0x3e;
                valid_elf[19] = 0x00;
            }
            #[cfg(target_arch = "aarch64")]
            {
                valid_elf[18] = 0xb7;
                valid_elf[19] = 0x00;
            }
            assert!(validate_binary_executable(&valid_elf).is_ok());
        }

        #[cfg(target_os = "windows")]
        {
            assert!(validate_binary_executable(b"not_pe").is_err());
            assert!(validate_binary_executable(b"MZ_valid_pe").is_ok());
        }

        #[cfg(target_os = "macos")]
        {
            assert!(validate_binary_executable(b"not_macho").is_err());
            assert!(validate_binary_executable(&[0xcf, 0xfa, 0xed, 0xfe, 0, 0, 0, 0]).is_ok());
        }
    }

    #[test]
    fn test_print_fallback_instructions_and_zip_unpack_error() {
        print_fallback_instructions();

        let binary_content = b"hello";
        let mut tar_bytes = vec![0u8; 1024];
        tar_bytes[0..10].copy_from_slice(b"other_file");
        let octal_size = format!("{:011o} ", binary_content.len());
        tar_bytes[124..136].copy_from_slice(octal_size.as_bytes());
        tar_bytes[156] = b'0';

        use flate2::write::GzEncoder;
        use flate2::Compression;
        use std::io::Write;
        let mut encoder = GzEncoder::new(Vec::new(), Compression::default());
        encoder.write_all(&tar_bytes).unwrap();
        let gz_bytes = encoder.finish().unwrap();
        assert!(extract_binary_from_tar_gz(&gz_bytes, "justui").is_err());

        // Test ZIP magic header with invalid zip data
        let invalid_zip_header = b"PK\x03\x04invalid_zip_content";
        assert!(unpack_binary_bytes(invalid_zip_header, "justui").is_err());
    }

    #[test]
    fn test_replace_executable_at() {
        let temp_dir = tempfile::tempdir().unwrap();
        let fake_exe = temp_dir.path().join("fake_justui");
        std::fs::write(&fake_exe, b"old_exe_content").unwrap();

        let new_bytes = b"new_exe_content";
        assert!(replace_executable_at(&fake_exe, new_bytes).is_ok());
        assert_eq!(std::fs::read(&fake_exe).unwrap(), new_bytes);
    }

    #[test]
    fn test_plan_upgrade_matrix() {
        // 1. Up-to-date version with force=false
        let up_to_date_release = GitHubRelease {
            tag_name: "v0.12.2".to_string(),
            html_url: "https://example.com/rel".to_string(),
            body: Some("Release notes".to_string()),
            assets: vec![],
        };
        let action = plan_upgrade("0.12.2", &up_to_date_release, false, false).unwrap();
        assert_eq!(action, UpgradeAction::AlreadyUpToDate);

        // 1b. Up-to-date version with force=true
        let action_force = plan_upgrade("0.12.2", &up_to_date_release, false, true).unwrap();
        assert_eq!(
            action_force,
            UpgradeAction::NoMatchingAsset {
                target_version: "0.12.2".to_string()
            }
        );

        // 2. Newer version check_only = true with long release notes body (>10 lines)
        let long_body = (0..15)
            .map(|i| format!("Line {}", i))
            .collect::<Vec<_>>()
            .join("\n");
        let new_release = GitHubRelease {
            tag_name: "v9.9.9".to_string(),
            html_url: "https://example.com/rel9".to_string(),
            body: Some(long_body),
            assets: vec![
                GitHubAsset {
                    name: "justui-x86_64-unknown-linux-gnu.tar.gz".to_string(),
                    browser_download_url: "https://example.com/dl".to_string(),
                },
                GitHubAsset {
                    name: "justui-aarch64-apple-darwin.tar.gz".to_string(),
                    browser_download_url: "https://example.com/dl_mac".to_string(),
                },
                GitHubAsset {
                    name: "justui-x86_64-pc-windows-msvc.zip".to_string(),
                    browser_download_url: "https://example.com/dl_win".to_string(),
                },
                GitHubAsset {
                    name: "justui-linux-amd64.tar.gz".to_string(),
                    browser_download_url: "https://example.com/dl_amd64".to_string(),
                },
                GitHubAsset {
                    name: "justui-darwin-arm64.tar.gz".to_string(),
                    browser_download_url: "https://example.com/dl_arm64".to_string(),
                },
            ],
        };
        let action_check = plan_upgrade("0.12.2", &new_release, true, false).unwrap();
        assert_eq!(
            action_check,
            UpgradeAction::CheckOnly {
                target_version: "9.9.9".to_string()
            }
        );

        // 3. Newer version download flow with matching asset
        let action_dl = plan_upgrade("0.12.2", &new_release, false, false).unwrap();
        assert!(matches!(action_dl, UpgradeAction::PerformDownload { .. }));

        // 4. Newer version without matching asset
        let no_asset_release = GitHubRelease {
            tag_name: "v9.9.9".to_string(),
            html_url: "https://example.com/rel9".to_string(),
            body: None,
            assets: vec![GitHubAsset {
                name: "other-platform-asset.tar.gz".to_string(),
                browser_download_url: "https://example.com/dl_other".to_string(),
            }],
        };
        let action_no_asset = plan_upgrade("0.12.2", &no_asset_release, false, false).unwrap();
        assert_eq!(
            action_no_asset,
            UpgradeAction::NoMatchingAsset {
                target_version: "9.9.9".to_string()
            }
        );

        // 4b. Asset list containing checksum .sha256 should choose the real archive
        let release_with_checksum = GitHubRelease {
            tag_name: "v9.9.9".to_string(),
            html_url: "https://example.com/rel9".to_string(),
            body: None,
            assets: vec![
                GitHubAsset {
                    name: "justui-x86_64-unknown-linux-gnu.tar.gz.sha256".to_string(),
                    browser_download_url: "https://example.com/checksum".to_string(),
                },
                GitHubAsset {
                    name: "justui-x86_64-unknown-linux-gnu.tar.gz".to_string(),
                    browser_download_url: "https://example.com/real_binary".to_string(),
                },
                GitHubAsset {
                    name: "justui-aarch64-apple-darwin.tar.gz.sha256".to_string(),
                    browser_download_url: "https://example.com/checksum_mac".to_string(),
                },
                GitHubAsset {
                    name: "justui-aarch64-apple-darwin.tar.gz".to_string(),
                    browser_download_url: "https://example.com/real_binary_mac".to_string(),
                },
                GitHubAsset {
                    name: "justui-x86_64-pc-windows-msvc.zip.sha256".to_string(),
                    browser_download_url: "https://example.com/checksum_win".to_string(),
                },
                GitHubAsset {
                    name: "justui-x86_64-pc-windows-msvc.zip".to_string(),
                    browser_download_url: "https://example.com/real_binary_win".to_string(),
                },
            ],
        };
        let action_checksum = plan_upgrade("0.12.2", &release_with_checksum, false, false).unwrap();
        match action_checksum {
            UpgradeAction::PerformDownload { download_url, .. } => {
                assert!(
                    !download_url.contains("checksum"),
                    "Should not select checksum file"
                );
            }
            other => panic!("Expected PerformDownload, got {:?}", other),
        }

        // 5. Invalid semver tag
        let invalid_semver_release = GitHubRelease {
            tag_name: "invalid_tag_123".to_string(),
            html_url: "https://example.com/rel".to_string(),
            body: None,
            assets: vec![],
        };
        let action_invalid = plan_upgrade("0.12.2", &invalid_semver_release, false, false).unwrap();
        assert_eq!(
            action_invalid,
            UpgradeAction::InvalidVersion {
                raw_tag: "invalid_tag_123".to_string()
            }
        );

        // 6. Invalid local version
        assert!(plan_upgrade("invalid_local_version", &new_release, false, false).is_err());
    }

    #[test]
    fn test_execute_upgrade_to_path() {
        use std::io::{Read, Write};
        use std::net::TcpListener;

        let listener = TcpListener::bind("127.0.0.1:0").unwrap();
        let port = listener.local_addr().unwrap().port();

        // Create a valid dummy executable payload
        let fake_binary = if cfg!(target_os = "linux") {
            let mut b = vec![0u8; 64];
            b[0..4].copy_from_slice(b"\x7fELF");
            #[cfg(target_arch = "x86_64")]
            {
                b[18] = 0x3e;
            }
            #[cfg(target_arch = "aarch64")]
            {
                b[18] = 0xb7;
            }
            b
        } else if cfg!(target_os = "windows") {
            b"MZ_fake_windows_binary".to_vec()
        } else {
            vec![0xcf, 0xfa, 0xed, 0xfe, 0, 0, 0, 0]
        };

        // Package into tar.gz
        use flate2::write::GzEncoder;
        use flate2::Compression;
        let mut tar_bytes = vec![0u8; 1024];
        let bin_name = if cfg!(target_os = "windows") {
            "justui.exe"
        } else {
            "justui"
        };
        tar_bytes[0..bin_name.len()].copy_from_slice(bin_name.as_bytes());
        let octal_size = format!("{:011o} ", fake_binary.len());
        tar_bytes[124..136].copy_from_slice(octal_size.as_bytes());
        tar_bytes[156] = b'0';
        tar_bytes[512..512 + fake_binary.len()].copy_from_slice(&fake_binary);

        let mut encoder = GzEncoder::new(Vec::new(), Compression::default());
        encoder.write_all(&tar_bytes).unwrap();
        let archive_bytes = encoder.finish().unwrap();

        // Spawn thread to serve one HTTP response
        let server_thread = std::thread::spawn(move || {
            if let Ok((mut stream, _)) = listener.accept() {
                let mut buf = [0u8; 1024];
                let _ = stream.read(&mut buf);
                let response = format!(
                    "HTTP/1.1 200 OK\r\nContent-Length: {}\r\nConnection: close\r\n\r\n",
                    archive_bytes.len()
                );
                let _ = stream.write_all(response.as_bytes());
                let _ = stream.write_all(&archive_bytes);
                let _ = stream.flush();
            }
        });

        let client = reqwest::blocking::Client::builder().build().unwrap();
        let download_url = format!("http://127.0.0.1:{}/justui.tar.gz", port);

        let temp_dir = tempfile::tempdir().unwrap();
        let target_exe = temp_dir.path().join(bin_name);
        std::fs::write(&target_exe, b"old_binary_content").unwrap();

        let res = execute_upgrade_to_path(&client, &download_url, "9.9.9", &target_exe);
        assert!(res.is_ok(), "execute_upgrade_to_path failed: {:?}", res);

        let replaced_content = std::fs::read(&target_exe).unwrap();
        assert_eq!(replaced_content, fake_binary);

        server_thread.join().unwrap();
    }

    #[test]
    fn test_run_command_execution() {
        let _lock = crate::utils::lock_test_mutex();
        assert!(run(true, false).is_ok());
        assert!(run(false, false).is_ok());
    }

    #[test]
    fn test_replace_executable_at_path() {
        let temp_dir = tempfile::tempdir().unwrap();
        let exe_path = temp_dir.path().join("dummy_binary");
        std::fs::write(&exe_path, b"old_binary_content").unwrap();

        let res = replace_executable_at_path(&exe_path, b"new_binary_content");
        assert!(res.is_ok());

        let new_content = std::fs::read(&exe_path).unwrap();
        assert_eq!(new_content, b"new_binary_content");
    }
}
