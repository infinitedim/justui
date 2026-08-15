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

    // Determine current target platform asset name
    let target_os = env::consts::OS;
    let target_arch = env::consts::ARCH;
    let target_triple = get_target_triple();

    let asset = release.assets.iter().find(|a| {
        let name = a.name.to_lowercase();
        if !target_triple.is_empty() && name.contains(target_triple) {
            return true;
        }
        let os_match = name.contains(target_os) || (target_os == "macos" && name.contains("darwin"));
        let arch_match = name.contains(target_arch)
            || (target_arch == "x86_64" && (name.contains("amd64") || name.contains("x64")));
        os_match && arch_match
    });

    if let Some(asset) = asset {
        logger::info(&format!(
            "Downloading update from {}...",
            asset.browser_download_url
        ));

        let pb_dl = indicatif::ProgressBar::new_spinner();
        pb_dl.set_message("Downloading binary archive...");
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

        let downloaded_bytes = match dl_resp.bytes() {
            Ok(b) => b,
            Err(e) => {
                pb_dl.finish_and_clear();
                logger::error(&format!("Failed to read binary bytes: {}", e));
                print_fallback_instructions();
                return Ok(());
            }
        };
        pb_dl.finish_and_clear();

        let binary_name = if target_os == "windows" {
            "justui.exe"
        } else {
            "justui"
        };

        let binary_bytes = match unpack_binary_bytes(&downloaded_bytes, binary_name) {
            Ok(b) => b,
            Err(e) => {
                logger::error(&format!("Failed to extract binary from downloaded asset: {}", e));
                print_fallback_instructions();
                return Ok(());
            }
        };

        // Attempt self-update by replacing current executable
        match replace_current_executable(&binary_bytes) {
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

        let blocks = (size + 511) / 512;
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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_target_triple_not_empty() {
        let triple = get_target_triple();
        assert!(!triple.is_empty(), "Target triple should be known for this platform");
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

        // Build a minimal POSIX tar header for "justui" file containing "hello world"
        let binary_content = b"hello world executable bytes";
        let mut tar_bytes = vec![0u8; 1024]; // 512 header + 512 data

        // Header: name (0..100) = "justui"
        tar_bytes[0..6].copy_from_slice(b"justui");
        // Header: size in octal (124..136) = "00000000034 " (28 bytes)
        let octal_size = format!("{:011o} ", binary_content.len());
        tar_bytes[124..136].copy_from_slice(octal_size.as_bytes());
        // Header: typeflag (156) = '0'
        tar_bytes[156] = b'0';

        // Data block at 512..512 + binary_content.len()
        tar_bytes[512..512 + binary_content.len()].copy_from_slice(binary_content);

        // Compress tar_bytes into gzip
        let mut encoder = GzEncoder::new(Vec::new(), Compression::default());
        encoder.write_all(&tar_bytes).unwrap();
        let gz_bytes = encoder.finish().unwrap();

        // Extract using unpack_binary_bytes
        let extracted = unpack_binary_bytes(&gz_bytes, "justui").unwrap();
        assert_eq!(extracted, binary_content);
    }
}
