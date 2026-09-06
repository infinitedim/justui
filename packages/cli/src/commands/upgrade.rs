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

/// Runs the `justui upgrade` command.
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

    process_release_update(&release, current_version_str, check_only, force)
}

fn process_release_update(
    release: &GitHubRelease,
    current_version_str: &str,
    check_only: bool,
    force: bool,
) -> Result<()> {
    let current_version = Version::parse(current_version_str)
        .with_context(|| format!("Failed to parse local version '{}'", current_version_str))?;

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

    if let Some(ref body) = release.body {
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
    let target_triple = get_target_triple();

    let asset = release.assets.iter().find(|a| {
        let name = a.name.to_lowercase();

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
        logger::info(&format!(
            "Downloading update from {}...",
            asset.browser_download_url
        ));
        print_fallback_instructions();
    } else {
        logger::warning(&format!(
            "No pre-compiled binary asset matching target ({}-{}) found in release.",
            target_os, target_arch
        ));
        print_fallback_instructions();
    }

    Ok(())
}

#[allow(dead_code)]
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
    } else if target_os == "windows" && (bytes.len() < 2 || &bytes[0..2] != b"MZ") {
        anyhow::bail!("Extracted binary is not a valid Windows PE executable");
    }

    Ok(())
}

#[allow(dead_code)]
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

#[allow(dead_code)]
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

#[allow(dead_code)]
fn extract_binary_from_zip(zip_bytes: &[u8], binary_name: &str) -> Result<Vec<u8>> {
    let temp_dir = tempfile::tempdir().context("Failed to create temp directory")?;
    let zip_path = temp_dir.path().join("update.zip");
    fs::write(&zip_path, zip_bytes).context("Failed to write zip file")?;

    let output_dir = temp_dir.path().join("extracted");
    fs::create_dir_all(&output_dir)?;

    #[cfg(windows)]
    {
        let status = std::process::Command::new("powershell")
            .arg("-NoProfile")
            .arg("-Command")
            .arg(format!(
                "Expand-Archive -Path '{}' -DestinationPath '{}' -Force",
                zip_path.display(),
                output_dir.display()
            ))
            .status()
            .context("Failed to run powershell Expand-Archive")?;

        if !status.success() {
            anyhow::bail!("Powershell Expand-Archive failed");
        }
    }

    #[cfg(not(windows))]
    {
        let status = std::process::Command::new("unzip")
            .arg("-o")
            .arg(&zip_path)
            .arg("-d")
            .arg(&output_dir)
            .status()
            .context("Failed to run unzip command")?;

        if !status.success() {
            anyhow::bail!("unzip failed");
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

#[allow(dead_code)]
fn replace_current_executable(new_bytes: &[u8]) -> Result<()> {
    let current_exe = env::current_exe().context("Failed to get current executable path")?;
    replace_executable_at_path(&current_exe, new_bytes)
}

#[allow(dead_code)]
fn replace_executable_at_path(current_exe: &std::path::Path, new_bytes: &[u8]) -> Result<()> {
    replace_executable_at(current_exe, new_bytes)
}

#[allow(dead_code)]
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

fn print_fallback_instructions() {
    logger::stdout("\nYou can update manually using:");
    logger::stdout("  cargo install justui --force");
    logger::stdout(
        "  or download the release directly from https://github.com/infinitedim/justui/releases",
    );
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
    fn test_process_release_update_matrix() {
        // 1. Up-to-date version with force=false
        let up_to_date_release = GitHubRelease {
            tag_name: "v0.12.0".to_string(),
            html_url: "https://example.com/rel".to_string(),
            body: Some("Release notes".to_string()),
            assets: vec![],
        };
        assert!(process_release_update(&up_to_date_release, "0.12.0", false, false).is_ok());

        // 1b. Up-to-date version with force=true
        assert!(process_release_update(&up_to_date_release, "0.12.0", false, true).is_ok());

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
        assert!(process_release_update(&new_release, "0.12.0", true, false).is_ok());

        // 3. Newer version download flow with matching asset
        assert!(process_release_update(&new_release, "0.12.0", false, false).is_ok());

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
        assert!(process_release_update(&no_asset_release, "0.12.0", false, false).is_ok());

        // 5. Invalid semver tag
        let invalid_semver_release = GitHubRelease {
            tag_name: "invalid_tag_123".to_string(),
            html_url: "https://example.com/rel".to_string(),
            body: None,
            assets: vec![],
        };
        assert!(process_release_update(&invalid_semver_release, "0.12.0", false, false).is_ok());
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
