#!/bin/bash
# sops-env-sync.sh
# Purpose:
# - Encrypt zsh/*.env.local -> zsh/*.env for git-tracked secrets.
# - Decrypt zsh/*.env -> zsh/*.env.local for local use.
#
# Usage:
#   ./scripts/sops-env-sync.sh encrypt zsh/work
#   ./scripts/sops-env-sync.sh decrypt zsh/work
#
# Expectations:
# - Targets should be path prefixes or .env/.env.local files.
# - Uses ~/.config/sops/age/keys.txt by default (override via SOPS_AGE_KEY_FILE).
# - Assumes the key exists locally (run setup-sops-age.sh first; can bootstrap from 1Password).
# - Requires: sops.
# - Uses whole-file (binary) sops mode to preserve formatting/newlines exactly.

set -euo pipefail

MODE="${1:-}"
TARGET="${2:-}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"
TARGET_REL=""

usage() {
    cat <<EOF
Usage:
  $0 encrypt <path-to-file.env.local|path-prefix>
  $0 decrypt <path-to-file.env|path-prefix>

Examples:
  $0 encrypt zsh/work
  $0 encrypt zsh/work.env.local
  $0 decrypt zsh/work
  $0 decrypt zsh/work.env
EOF
}

if [[ -z "$MODE" || -z "$TARGET" ]]; then
    usage
    exit 1
fi

if ! command -v sops >/dev/null 2>&1; then
    echo "sops is not installed. Install it first (brew install sops)." >&2
    exit 1
fi

if [[ "$TARGET" == /* ]]; then
    if [[ "$TARGET" == "$ROOT_DIR"/* ]]; then
        TARGET_REL="${TARGET#${ROOT_DIR}/}"
    else
        echo "Target must be inside repo: $ROOT_DIR" >&2
        exit 1
    fi
else
    TARGET_REL="$TARGET"
fi

if [[ "$TARGET_REL" == *.env.local ]]; then
    LOCAL_FILE_REL="$TARGET_REL"
    ENCRYPTED_FILE_REL="${TARGET_REL%.local}"
elif [[ "$TARGET_REL" == *.env ]]; then
    ENCRYPTED_FILE_REL="$TARGET_REL"
    LOCAL_FILE_REL="${TARGET_REL}.local"
else
    ENCRYPTED_FILE_REL="${TARGET_REL}.env"
    LOCAL_FILE_REL="${TARGET_REL}.env.local"
fi

LOCAL_FILE="${ROOT_DIR}/${LOCAL_FILE_REL}"
ENCRYPTED_FILE="${ROOT_DIR}/${ENCRYPTED_FILE_REL}"

mkdir -p "$(dirname "$ENCRYPTED_FILE")"
mkdir -p "$(dirname "$LOCAL_FILE")"

case "$MODE" in
    encrypt)
        if [[ ! -f "$LOCAL_FILE" ]]; then
            echo "Missing local file: $LOCAL_FILE" >&2
            exit 1
        fi
        (
            cd "$ROOT_DIR"
            SOPS_AGE_KEY_FILE="$KEY_FILE" sops --encrypt --input-type binary --output-type binary --filename-override "$ENCRYPTED_FILE_REL" --output "$ENCRYPTED_FILE_REL" "$LOCAL_FILE_REL"
        )
        echo "Wrote encrypted file: ${ENCRYPTED_FILE_REL}"
        ;;
    decrypt)
        if [[ ! -f "$ENCRYPTED_FILE" ]]; then
            echo "Missing encrypted file: $ENCRYPTED_FILE" >&2
            exit 1
        fi
        (
            cd "$ROOT_DIR"
            SOPS_AGE_KEY_FILE="$KEY_FILE" sops -d --input-type binary --output-type binary --output "$LOCAL_FILE_REL" "$ENCRYPTED_FILE_REL"
        )
        chmod 600 "$LOCAL_FILE"
        echo "Wrote local file: ${LOCAL_FILE_REL}"
        ;;
    *)
        usage
        exit 1
        ;;
esac
