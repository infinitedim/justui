# Changesets

Folder ini berisi changeset files yang pending — perubahan yang belum di-apply ke versi package.

## Cara membuat changeset baru

Setiap kali kamu melakukan perubahan yang harus di-release (bukan internal tooling atau docs saja), buat changeset:

```bash
bun changeset
```

CLI akan menanyakan:
1. Package mana yang berubah (`just_ui_tokens`, `just_ui_core`, `justui_cli`)
2. Jenis bump: `patch` (bug fix), `minor` (fitur baru backward-compatible), `major` (breaking change)
3. Deskripsi singkat perubahan

File `.md` baru akan dibuat di folder ini. Commit file tersebut bersama PR kamu.

## Format changeset file

```
---
"just_ui_tokens": patch
"just_ui_core": minor
---

Tambah fungsi `logger::panel()` dan `logger::summary()` untuk output CLI yang lebih terstruktur.
```

## Kapan changeset diperlukan

- Perubahan di `packages/tokens/` → bump `just_ui_tokens`
- Perubahan di `packages/core/` → bump `just_ui_core`
- Perubahan di `packages/cli/` → bump `justui_cli`
- Perubahan di `apps/docs/` atau `tools/` → **tidak perlu changeset**
