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
        parse_tag_from_location("https://github.com/infinitedim/justui/releases/tag/v0.14.0"),
        Some("v0.14.0".to_string())
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
        parse_tag_from_location("https://github.com/infinitedim/justui/releases/tag/v2.3.4#notes"),
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
        assert!(validate_binary_executable(b"not_an_elf_binary_file_header_long_enough").is_err());

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
        tag_name: "v0.14.0".to_string(),
        html_url: "https://example.com/rel".to_string(),
        body: Some("Release notes".to_string()),
        assets: vec![],
    };
    let action = plan_upgrade("0.14.0", &up_to_date_release, false, false).unwrap();
    assert_eq!(action, UpgradeAction::AlreadyUpToDate);

    // 1b. Up-to-date version with force=true
    let action_force = plan_upgrade("0.14.0", &up_to_date_release, false, true).unwrap();
    assert_eq!(
        action_force,
        UpgradeAction::NoMatchingAsset {
            target_version: "0.14.0".to_string()
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
    let action_check = plan_upgrade("0.14.0", &new_release, true, false).unwrap();
    assert_eq!(
        action_check,
        UpgradeAction::CheckOnly {
            target_version: "9.9.9".to_string()
        }
    );

    // 3. Newer version download flow with matching asset
    let action_dl = plan_upgrade("0.14.0", &new_release, false, false).unwrap();
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
    let action_no_asset = plan_upgrade("0.14.0", &no_asset_release, false, false).unwrap();
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
    let action_checksum = plan_upgrade("0.14.0", &release_with_checksum, false, false).unwrap();
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
    let action_invalid = plan_upgrade("0.14.0", &invalid_semver_release, false, false).unwrap();
    assert_eq!(
        action_invalid,
        UpgradeAction::InvalidVersion {
            raw_tag: "invalid_tag_123".to_string()
        }
    );

    // 6. Invalid local version
    assert!(plan_upgrade("invalid_local_version", &new_release, false, false).is_err());
}

/// Builds a `.tar.gz` holding a minimal executable for the host platform.
/// Returns `(archive_bytes, binary_bytes, binary_name)`.
fn fake_release_archive() -> (Vec<u8>, Vec<u8>, &'static str) {
    use flate2::write::GzEncoder;
    use flate2::Compression;
    use std::io::Write;

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

    let bin_name = if cfg!(target_os = "windows") {
        "justui.exe"
    } else {
        "justui"
    };
    let mut tar_bytes = vec![0u8; 1024];
    tar_bytes[0..bin_name.len()].copy_from_slice(bin_name.as_bytes());
    let octal_size = format!("{:011o} ", fake_binary.len());
    tar_bytes[124..136].copy_from_slice(octal_size.as_bytes());
    tar_bytes[156] = b'0';
    tar_bytes[512..512 + fake_binary.len()].copy_from_slice(&fake_binary);

    let mut encoder = GzEncoder::new(Vec::new(), Compression::default());
    encoder.write_all(&tar_bytes).unwrap();
    (encoder.finish().unwrap(), fake_binary, bin_name)
}

/// Serves the archive and its `SHA256SUMS` manifest for exactly two requests.
fn spawn_release_server(archive: Vec<u8>, manifest: String) -> (u16, std::thread::JoinHandle<()>) {
    use std::io::{Read, Write};
    use std::net::TcpListener;

    let listener = TcpListener::bind("127.0.0.1:0").unwrap();
    let port = listener.local_addr().unwrap().port();
    let handle = std::thread::spawn(move || {
        for _ in 0..2 {
            let Ok((mut stream, _)) = listener.accept() else {
                return;
            };
            let mut buf = [0u8; 1024];
            let n = stream.read(&mut buf).unwrap_or(0);
            let request = String::from_utf8_lossy(&buf[..n]);
            let body: &[u8] = if request.starts_with("GET /SHA256SUMS ") {
                manifest.as_bytes()
            } else {
                &archive
            };
            let header = format!(
                "HTTP/1.1 200 OK\r\nContent-Length: {}\r\nConnection: close\r\n\r\n",
                body.len()
            );
            let _ = stream.write_all(header.as_bytes());
            let _ = stream.write_all(body);
            let _ = stream.flush();
        }
    });
    (port, handle)
}

#[test]
fn test_execute_upgrade_to_path() {
    use sha2::{Digest, Sha256};

    let (archive_bytes, fake_binary, bin_name) = fake_release_archive();
    let manifest = format!(
        "{}  justui-other.tar.gz\n{}  justui.tar.gz\n",
        "0".repeat(64),
        hex::encode(Sha256::digest(&archive_bytes))
    );
    let (port, server_thread) = spawn_release_server(archive_bytes, manifest);

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
fn test_execute_upgrade_rejects_checksum_mismatch() {
    let (archive_bytes, _, bin_name) = fake_release_archive();
    let manifest = format!("{}  justui.tar.gz\n", "ab".repeat(32));
    let (port, server_thread) = spawn_release_server(archive_bytes, manifest);

    let client = reqwest::blocking::Client::builder().build().unwrap();
    let download_url = format!("http://127.0.0.1:{}/justui.tar.gz", port);

    let temp_dir = tempfile::tempdir().unwrap();
    let target_exe = temp_dir.path().join(bin_name);
    std::fs::write(&target_exe, b"old_binary_content").unwrap();

    let res = execute_upgrade_to_path(&client, &download_url, "9.9.9", &target_exe);
    let err = format!(
        "{:#}",
        res.expect_err("mismatched checksum must abort the upgrade")
    );
    assert!(
        err.contains("Checksum mismatch"),
        "unexpected error: {}",
        err
    );
    assert_eq!(std::fs::read(&target_exe).unwrap(), b"old_binary_content");

    server_thread.join().unwrap();
}

#[test]
fn test_checksum_manifest_location() {
    let (manifest, name) = checksum_manifest_location(
        "https://github.com/o/r/releases/download/v1.2.3/justui-x86_64-unknown-linux-gnu.tar.gz",
    )
    .unwrap();
    assert_eq!(
        manifest,
        "https://github.com/o/r/releases/download/v1.2.3/SHA256SUMS"
    );
    assert_eq!(name, "justui-x86_64-unknown-linux-gnu.tar.gz");

    let (manifest, name) =
        checksum_manifest_location("http://127.0.0.1:1/a/justui.zip?x=1").unwrap();
    assert_eq!(manifest, "http://127.0.0.1:1/a/SHA256SUMS");
    assert_eq!(name, "justui.zip");

    assert!(checksum_manifest_location("http://host/dir/").is_err());
}

#[test]
fn test_verify_sha256() {
    use sha2::{Digest, Sha256};

    let data = b"archive-bytes";
    let hash = hex::encode(Sha256::digest(data));

    let plain = format!("{}  justui.tar.gz\n", hash);
    assert!(verify_sha256(data, &plain, "justui.tar.gz").is_ok());

    let binary_mode_upper = format!("{} *justui.tar.gz\n", hash.to_uppercase());
    assert!(verify_sha256(data, &binary_mode_upper, "justui.tar.gz").is_ok());

    let dot_slash = format!("{}  ./justui.tar.gz\n", hash);
    assert!(verify_sha256(data, &dot_slash, "justui.tar.gz").is_ok());

    let err = verify_sha256(b"tampered", &plain, "justui.tar.gz").unwrap_err();
    assert!(err.to_string().contains("Checksum mismatch"));

    let err = verify_sha256(data, &plain, "justui.zip").unwrap_err();
    assert!(err.to_string().contains("not listed"));

    assert!(verify_sha256(data, "", "justui.tar.gz").is_err());
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
