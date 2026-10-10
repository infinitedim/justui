---
"justui_cli": patch
---

feat(cli): verify build provenance attestations in install scripts and attach to releases

- Install scripts `install.sh` and `install.ps1` now verify build provenance attestations via `gh attestation verify` when `gh` is authenticated.
- Fallback instructions in `upgrade` command now reference the docs route.
- Release workflow now bundles installer scripts directly in GitHub release assets.
