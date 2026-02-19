#!/bin/bash
# setup-sops-age.sh
# Purpose:
# - Keep one shared age key in 1Password and mirror it locally for sops usage.
# - Ensure this machine's public key is present in .sops.yaml for zsh/*.env files.
# - Update recipients on existing encrypted zsh/*.env files.
#
# Usage:
#   ./scripts/setup-sops-age.sh
#
# Workflow:
# - If `Private/age encryption key` exists in 1Password:
#   - Read `private-key` and write it to ~/.config/sops/age/keys.txt
# - If it does not exist:
#   - Use local key if present, otherwise create one
#   - Create the 1Password item with `private-key` and `public-key`
#
# Defaults:
# - Vault: Private
# - Item title: age encryption key
# - Fields: private-key (concealed), public-key (text)
#
# Requirements:
# - age (age-keygen), 1Password CLI (`op`), and `eval $(op signin)` beforehand.
# - Safe to run repeatedly.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOPS_CONFIG_FILE="${SOPS_CONFIG_FILE:-${ROOT_DIR}/.sops.yaml}"
TARGET_RULE_REGEX='^zsh/.*\.env$'
DEFAULT_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"
DEFAULT_KEY_DIR="$(dirname "$DEFAULT_KEY_FILE")"
OP_VAULT="${OP_VAULT:-Private}"
OP_ITEM_TITLE="${OP_ITEM_TITLE:-age encryption key}"
OP_PRIVATE_FIELD="${OP_PRIVATE_FIELD:-private-key}"
OP_PUBLIC_FIELD="${OP_PUBLIC_FIELD:-public-key}"
KEY_LABEL="${KEY_LABEL:-${OP_VAULT}/${OP_ITEM_TITLE}}"

add_public_key_to_existing_rule() {
    local config_file="$1"
    local public_key="$2"
    local key_label="$3"
    local tmp_file

    tmp_file="$(mktemp)"
    awk -v key="$public_key" -v label="$key_label" '
    BEGIN {
        in_target_rule = 0
        in_age_list = 0
        found_target_rule = 0
        found_key = 0
        inserted = 0
    }
    function is_target_rule(line, value) {
        value = line
        sub(/^[[:space:]]*-[[:space:]]*path_regex:[[:space:]]*/, "", value)
        sub(/[[:space:]]*$/, "", value)
        gsub(/\\/, "", value)
        return (value == "^zsh/.*.env$")
    }
    function parse_key_value(line, value) {
        value = line
        sub(/^[[:space:]]*-[[:space:]]*/, "", value)
        sub(/[[:space:]]*(#.*)?$/, "", value)
        return value
    }
    function maybe_insert_key() {
        if (!found_key && !inserted) {
            if (label != "") {
                print "      # " label
            }
            print "      - " key
            inserted = 1
        }
    }
    {
        if ($0 ~ /^[[:space:]]*-[[:space:]]*path_regex:[[:space:]]*/) {
            if (in_age_list) {
                maybe_insert_key()
            }

            if (is_target_rule($0)) {
                in_target_rule = 1
                found_target_rule = 1
            } else {
                in_target_rule = 0
            }

            in_age_list = 0
            print
            next
        }

        if (in_target_rule && $0 ~ /^[[:space:]]*age:[[:space:]]*$/) {
            in_age_list = 1
            print
            next
        }

        if (in_target_rule && in_age_list) {
            if ($0 ~ /^[[:space:]]*-[[:space:]]*age1[0-9a-z]+([[:space:]]*#.*)?$/) {
                if (parse_key_value($0) == key) {
                    found_key = 1
                }
                print
                next
            }
            if ($0 ~ /^[[:space:]]*#.*$/ || $0 ~ /^[[:space:]]*$/) {
                print
                next
            }
            maybe_insert_key()
            in_age_list = 0
            print
            next
        }

        print
    }
    END {
        if (in_target_rule && in_age_list) {
            maybe_insert_key()
        }
        if (!found_target_rule) {
            exit 11
        }
    }
    ' "$config_file" >"$tmp_file" || {
        rm -f "$tmp_file"
        return 1
    }

    mv "$tmp_file" "$config_file"
}

if ! command -v age-keygen >/dev/null 2>&1; then
    echo "age-keygen is not installed. Install age first (brew install age)." >&2
    exit 1
fi

if ! command -v op >/dev/null 2>&1; then
    echo "1Password CLI is not installed. Install it first (brew install 1password-cli)." >&2
    exit 1
fi

extract_private_key_line() {
    local raw_value="$1"
    printf '%s\n' "$raw_value" | awk '/^AGE-SECRET-KEY-/{print; exit}'
}

load_key_from_1password() {
    local private_key_raw
    local private_key_line

    private_key_raw="$(op read "op://${OP_VAULT}/${OP_ITEM_TITLE}/${OP_PRIVATE_FIELD}" 2>/dev/null || true)"
    private_key_line="$(extract_private_key_line "$private_key_raw")"
    if [[ -z "$private_key_line" ]]; then
        echo "1Password field ${OP_PRIVATE_FIELD} is missing a valid age private key." >&2
        return 1
    fi
    printf '%s\n' "$private_key_line" >"$DEFAULT_KEY_FILE"
    chmod 600 "$DEFAULT_KEY_FILE"
    return 0
}

ensure_local_key() {
    if [[ -f "$DEFAULT_KEY_FILE" ]]; then
        chmod 600 "$DEFAULT_KEY_FILE"
        echo "Using existing local age key at ${DEFAULT_KEY_FILE}"
        return 0
    fi
    age-keygen -o "$DEFAULT_KEY_FILE" >/dev/null 2>&1
    chmod 600 "$DEFAULT_KEY_FILE"
    echo "Created new age private key at ${DEFAULT_KEY_FILE}"
}

ensure_key_in_1password() {
    local private_key_line
    local public_key_local

    if op item get "$OP_ITEM_TITLE" --vault "$OP_VAULT" >/dev/null 2>&1; then
        load_key_from_1password
        echo "Loaded age private key from 1Password (${OP_VAULT}/${OP_ITEM_TITLE})"
    else
        ensure_local_key
        private_key_line="$(extract_private_key_line "$(cat "$DEFAULT_KEY_FILE")")"
        if [[ -z "$private_key_line" ]]; then
            echo "Local key file does not contain a valid age private key line." >&2
            return 1
        fi
        public_key_local="$(age-keygen -y "$DEFAULT_KEY_FILE")"
        op item create \
            --vault "$OP_VAULT" \
            --category "Secure Note" \
            --title "$OP_ITEM_TITLE" \
            "${OP_PRIVATE_FIELD}[concealed]=$private_key_line" \
            "${OP_PUBLIC_FIELD}[text]=$public_key_local" >/dev/null
        echo "Created 1Password item ${OP_VAULT}/${OP_ITEM_TITLE}"
    fi
}

ensure_op_session() {
    if op whoami >/dev/null 2>&1; then
        return 0
    fi
    local signin_cmd
    signin_cmd='eval $(op signin)'
    echo "1Password CLI is not signed in. Run '$signin_cmd' and rerun this script." >&2
    if [[ "$(uname -s)" == "Darwin" ]] && command -v pbcopy >/dev/null 2>&1; then
        printf '%s' "$signin_cmd" | pbcopy
        echo "  [Copied to clipboard]" >&2
    fi
    return 1
}

mkdir -p "$DEFAULT_KEY_DIR"
ensure_op_session
ensure_key_in_1password

if [[ ! -f "$DEFAULT_KEY_FILE" ]]; then
    echo "Missing local age private key at ${DEFAULT_KEY_FILE} after 1Password sync." >&2
    exit 1
fi

PUBLIC_KEY="$(age-keygen -y "$DEFAULT_KEY_FILE")"
echo "Public key: ${PUBLIC_KEY}"
echo "Using key label: ${KEY_LABEL}"

if [[ ! -f "$SOPS_CONFIG_FILE" ]]; then
    cat >"$SOPS_CONFIG_FILE" <<EOF
creation_rules:
  - path_regex: ${TARGET_RULE_REGEX}
    age:
      # ${KEY_LABEL}
      - ${PUBLIC_KEY}
EOF
    echo "Created ${SOPS_CONFIG_FILE} with an env file rule."
else
    if add_public_key_to_existing_rule "$SOPS_CONFIG_FILE" "$PUBLIC_KEY" "$KEY_LABEL"; then
        echo "Ensured public key exists in ${SOPS_CONFIG_FILE} target rule."
    else
        cat >>"$SOPS_CONFIG_FILE" <<EOF
  - path_regex: ${TARGET_RULE_REGEX}
    age:
      # ${KEY_LABEL}
      - ${PUBLIC_KEY}
EOF
        echo "Appended rule with your public key to ${SOPS_CONFIG_FILE}"
    fi
fi

if command -v sops >/dev/null 2>&1; then
    while IFS= read -r env_file; do
        if SOPS_AGE_KEY_FILE="$DEFAULT_KEY_FILE" sops updatekeys -y "$env_file" >/dev/null 2>&1; then
            echo "Updated recipients in ${env_file#${ROOT_DIR}/}"
        fi
    done < <(find "${ROOT_DIR}/zsh" -type f -name '*.env')
fi
