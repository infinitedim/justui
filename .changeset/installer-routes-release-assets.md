---
"docs": patch
---

fix(docs): serve release asset installers in install route handlers

- Point `/install.sh` and `/install.ps1` route handlers to the published GitHub release assets on `releases/latest/download/`.
