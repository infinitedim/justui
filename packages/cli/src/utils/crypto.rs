use anyhow::{Context, Result};
use ed25519_compact::{KeyPair, PublicKey, Seed, Signature};

/// Deterministic 32-byte seed used for official JustUI registry signing in releases.
pub const OFFICIAL_REGISTRY_SEED: &[u8; 32] = b"JustUI-Official-Registry-Key-32b";

/// Official JustUI registry public key (32 bytes).
/// Derived deterministically from OFFICIAL_REGISTRY_SEED.
pub const JUSTUI_REGISTRY_PUBKEY: &[u8; 32] = &[
    0x43, 0xdb, 0x72, 0x97, 0x7f, 0x8c, 0x00, 0x97, 0x98, 0xd2, 0x4e, 0x92, 0x47, 0x95, 0xde, 0x29,
    0xe3, 0xc2, 0x1b, 0xb8, 0x67, 0x0b, 0x4f, 0x13, 0xdf, 0xe7, 0xd4, 0x6f, 0x6f, 0x2a, 0x51, 0x92,
];

/// Generates the official KeyPair from the official release seed.
pub fn official_keypair() -> KeyPair {
    let seed = Seed::from_slice(OFFICIAL_REGISTRY_SEED).expect("Invalid seed length");
    KeyPair::from_seed(seed)
}

/// Signs content using the given KeyPair and returns a 128-character lowercase hex string.
pub fn sign_content(content: &[u8], keypair: &KeyPair) -> String {
    let signature = keypair.sk.sign(content, None);
    hex::encode(signature.as_ref())
}

/// Verifies that content matches an Ed25519 signature in hex format against a public key.
pub fn verify_signature(
    content: &[u8],
    signature_str: &str,
    pubkey_bytes: &[u8; 32],
) -> Result<()> {
    let clean_sig = signature_str.trim();
    let sig_bytes = hex::decode(clean_sig)
        .context("Invalid hex in registry signature (expected 128 hex characters)")?;

    let pk = PublicKey::from_slice(pubkey_bytes).context("Invalid Ed25519 public key")?;
    let sig = Signature::from_slice(&sig_bytes)
        .context("Invalid Ed25519 signature format (expected 64 bytes)")?;

    pk.verify(content, &sig).context(
        "Cryptographic signature verification failed! The registry index has been tampered with or is corrupted.",
    )?;

    Ok(())
}

/// Checks whether a registry URL is an official JustUI repository URL.
pub fn is_official_registry(url: &str) -> bool {
    let trimmed = url.trim();
    trimmed.starts_with("https://raw.githubusercontent.com/infinitedim/justui/")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_official_keypair_and_verification() {
        let keypair = official_keypair();
        assert_eq!(keypair.pk.as_ref(), JUSTUI_REGISTRY_PUBKEY);

        let data = b"{\"version\": \"0.14.0\", \"components\": []}";
        let sig_hex = sign_content(data, &keypair);
        assert_eq!(sig_hex.len(), 128);

        // Valid signature verifies
        let verify_res = verify_signature(data, &sig_hex, JUSTUI_REGISTRY_PUBKEY);
        assert!(verify_res.is_ok());

        // Tampered data fails verification
        let tampered_data = b"{\"version\": \"0.14.0\", \"components\": [\"malicious\"]}";
        let fail_res = verify_signature(tampered_data, &sig_hex, JUSTUI_REGISTRY_PUBKEY);
        assert!(fail_res.is_err());
        let err_msg = fail_res.unwrap_err().to_string();
        assert!(err_msg.contains("tampered with"));
    }

    #[test]
    fn test_invalid_signature_formats() {
        let data = b"test payload";

        // Bad hex string
        let bad_hex = verify_signature(data, "not-valid-hex-zzz", JUSTUI_REGISTRY_PUBKEY);
        assert!(bad_hex.is_err());
        assert!(bad_hex.unwrap_err().to_string().contains("Invalid hex"));

        // Hex string but wrong length (not 64 bytes / 128 hex)
        let short_hex = verify_signature(data, "0011223344", JUSTUI_REGISTRY_PUBKEY);
        assert!(short_hex.is_err());
        assert!(short_hex
            .unwrap_err()
            .to_string()
            .contains("expected 64 bytes"));
    }

    #[test]
    fn test_is_official_registry() {
        assert!(is_official_registry(
            "https://raw.githubusercontent.com/infinitedim/justui/main/registry"
        ));
        assert!(is_official_registry(
            "https://raw.githubusercontent.com/infinitedim/justui/v0.14.0/registry"
        ));
        assert!(!is_official_registry("https://evil.com/registry"));
        assert!(!is_official_registry("/tmp/local-registry"));
    }
}
