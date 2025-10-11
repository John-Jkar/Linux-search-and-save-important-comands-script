#!/usr/bin/env bash
set -euo pipefail

DB_FILE="/home/fsociety/commands.json"

# Ensure database exists and is a JSON array
if [[ ! -f "$DB_FILE" ]]; then
  echo "[]" > "$DB_FILE"
fi

# === Function: Add new command ===
add_command() {
  echo "➕ Add a new command entry"
  read -rp "Title: " title
  read -rp "Command: " command
  read -rp "Tags (comma-separated): " tags_line

  tmp=$(mktemp)
  cat "$DB_FILE" | jq --arg t "$title" --arg c "$command" --arg tags "$tags_line" \
     '. += [ { title: $t, command: $c, tags: ($tags|split(",")) } ]' \
     > "$tmp" && mv "$tmp" "$DB_FILE"
  echo "✅ Added: $title"
  exit 0
}

# === Function: List all commands ===
list_commands() {
  cat "$DB_FILE" | jq -r '.[] | [.title, .command, (.tags|join(","))] | @tsv' | column -t -s$'\t'
  exit 0
}

# === Function: Copy command to clipboard ===
copy_to_clipboard() {
  command -v wl-copy >/dev/null 2>&1 && { wl-copy; return; }
  command -v xclip   >/dev/null 2>&1 && { xclip -selection clipboard; return; }
  command -v xsel    >/dev/null 2>&1 && { xsel --clipboard --input; return; }
  command -v clip.exe >/dev/null 2>&1 && { clip.exe; return; }
  command -v pbcopy   >/dev/null 2>&1 && { pbcopy; return; }
  echo "⚠️ No clipboard tool found (tried wl-copy, xclip, xsel, clip.exe, pbcopy)" >&2
  return 1
}

# === Handle arguments ===
case "${1:-}" in
  --add) add_command ;;
  --list) list_commands ;;
esac

# === FZF selection ===
jq_tsv='.[] | [.title, .command, (.tags|join(","))] | @tsv'

selected="$(cat "$DB_FILE" | jq -r "$jq_tsv" | fzf \
  --with-nth=1,3 \
  --delimiter=$'\t' \
  --header='type to filter • Enter=copy • Ctrl-P=print' \
  --preview='printf "⟪ %s ⟫\n\n%s\n" {1} {2}' \
  --bind 'ctrl-p:execute-silent(echo -n {2} >&2)+accept')"

cmd="$(printf '%s' "$selected" | awk -F'\t' '{print $2}')"
[ -n "${cmd:-}" ] || exit 0

# === Copy or print ===
if [ "${PRINT:-0}" -eq 1 ]; then
  printf '%s\n' "$cmd"
else
  printf '%s' "$cmd" | copy_to_clipboard || {
    echo '❌ Failed to copy to clipboard. Install wl-clipboard, xclip, or xsel.' >&2
    exit 1
  }
  echo "📋 Copied: $cmd"
fi



