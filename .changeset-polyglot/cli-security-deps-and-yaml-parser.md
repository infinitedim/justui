---
"justui_cli": patch
---

fix(cli): pick up TLS security fixes and replace the unmaintained YAML parser

- Update rustls (0.23.46), rustls-webpki (0.103.16), webpki-roots (1.0.10) and tokio (1.53.3) for RUSTSEC-2026-0346/0347/0348/0349/0381/0382/0386.
- Parse `justui.config.yaml` and `pubspec.yaml` with serde-saphyr (safe Rust) instead of serde_yaml_ng, which depended on the unmaintained unsafe-libyaml (RUSTSEC-2024-0449). Parsing behavior is unchanged.
