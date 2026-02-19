#!/bin/bash
# sync-encrypted-envs.sh
# Synchronize encrypted *.env files with plaintext *.env.local sources.
#
# Behavior:
# - Finds all '*.env.local' files in the repo.
# - Compares each to decrypted sibling '*.env'.
# - Re-encrypts and stages '*.env' when missing/stale/different.

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

SYNC_SCRIPT="$ROOT_DIR/scripts/sops-env-sync.sh"
KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"

if [[ ! -x "$SYNC_SCRIPT" ]]; then
    echo "sync-encrypted-envs: missing executable sync script: $SYNC_SCRIPT" >&2
    exit 1
fi

if ! command -v sops >/dev/null 2>&1; then
    echo "sync-encrypted-envs: sops is not installed (brew install sops)." >&2
    exit 1
fi

updated_count=0

while IFS= read -r -d '' local_file; do
    encrypted_file="${local_file%.local}"
    needs_encrypt=0

    if [[ ! -f "$encrypted_file" ]]; then
        needs_encrypt=1
    else
        tmp_decrypted="$(mktemp)"
        if ! SOPS_AGE_KEY_FILE="$KEY_FILE" sops -d --input-type binary --output-type binary "$encrypted_file" >"$tmp_decrypted" 2>/dev/null; then
            needs_encrypt=1
        elif ! cmp -s "$local_file" "$tmp_decrypted"; then
            needs_encrypt=1
        fi
        rm -f "$tmp_decrypted"
    fi

    if [[ "$needs_encrypt" -eq 1 ]]; then
        echo "sync-encrypted-envs: syncing ${local_file} -> ${encrypted_file}"
        "$SYNC_SCRIPT" encrypt "$local_file"
        git add "$encrypted_file"
        updated_count=$((updated_count + 1))
    fi
done < <(find . -type f -name '*.env.local' -not -path './.git/*' -print0)

if [[ "$updated_count" -gt 0 ]]; then
    echo "sync-encrypted-envs: updated and staged $updated_count encrypted file(s)."
fi
