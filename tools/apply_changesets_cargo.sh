#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CHANGESET_DIR="$PROJECT_ROOT/.changeset"
CARGO_TOML="$PROJECT_ROOT/packages/cli/Cargo.toml"
DRY_RUN=false

for arg in "$@"; do
  if [[ "$arg" == "--dry-run" ]]; then
    DRY_RUN=true
  fi
done

if [[ ! -d "$CHANGESET_DIR" ]]; then
  echo "No .changeset directory found. Nothing to do."
  exit 0
fi

# Cari bump tertinggi untuk justui_cli dari semua changeset files
HIGHEST_BUMP=""

order_value() {
  case "$1" in
    patch) echo 0 ;;
    minor) echo 1 ;;
    major) echo 2 ;;
    *) echo -1 ;;
  esac
}

for file in "$CHANGESET_DIR"/*.md; do
  [[ "$(basename "$file")" == "README.md" ]] && continue
  [[ ! -f "$file" ]] && continue

  in_frontmatter=false
  dash_count=0

  while IFS= read -r line; do
    if [[ "$line" == "---" ]]; then
      ((dash_count++)) || true
      if [[ $dash_count -eq 1 ]]; then
        in_frontmatter=true
      elif [[ $dash_count -eq 2 ]]; then
        break
      fi
      continue
    fi

    if [[ "$in_frontmatter" == true ]]; then
      if [[ "$line" =~ \"justui_cli\":[[:space:]]*(patch|minor|major) ]]; then
        bump="${BASH_REMATCH[1]}"
        if [[ -z "$HIGHEST_BUMP" ]] || \
           [[ $(order_value "$bump") -gt $(order_value "$HIGHEST_BUMP") ]]; then
          HIGHEST_BUMP="$bump"
        fi
      fi
    fi
  done < "$file"
done

if [[ -z "$HIGHEST_BUMP" ]]; then
  echo "No justui_cli bump found in changesets. Nothing to do."
  exit 0
fi

echo "justui_cli bump to apply: $HIGHEST_BUMP"

# Baca versi saat ini dari Cargo.toml
# Hanya match baris pertama `version = "x.y.z"` (bukan dependency versions)
CURRENT_VERSION=$(grep -m1 '^version = "[0-9]*\.[0-9]*\.[0-9]*"' "$CARGO_TOML" | \
  sed 's/version = "\(.*\)"/\1/')

if [[ -z "$CURRENT_VERSION" ]]; then
  echo "Error: Could not find version in $CARGO_TOML"
  exit 1
fi

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

case "$HIGHEST_BUMP" in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
echo "justui_cli: $CURRENT_VERSION → $NEW_VERSION ($HIGHEST_BUMP)"

if [[ "$DRY_RUN" == true ]]; then
  echo "[dry-run] Would update $CARGO_TOML"
  echo "Dry-run complete. No files were modified."
  exit 0
fi

# Update hanya baris pertama `version = "..."` di Cargo.toml
# Menggunakan temp file untuk kompatibilitas macOS dan Linux
TEMP_FILE=$(mktemp)
awk 'BEGIN{done=0} /^version = "[0-9]+\.[0-9]+\.[0-9]+"/ && !done {
  print "version = \"'"$NEW_VERSION"\""; done=1; next
} {print}' "$CARGO_TOML" > "$TEMP_FILE"

mv "$TEMP_FILE" "$CARGO_TOML"
echo "✔ Updated $CARGO_TOML"
echo ""
echo "Cargo version updated successfully."
