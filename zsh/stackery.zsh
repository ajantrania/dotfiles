alias stackery="nocorrect stackery"

# Update GOPATH for Stackery CLI
export GOPATH="/Users/ajantrania/Documents/work/Stackery/codebase/cli"

STACKERY_DIR="${${(%):-%x}:A:h}"          # directory of stackery.zsh
STACKERY_ENV_ENC="$STACKERY_DIR/stackery.env"        # encrypted, tracked
STACKERY_ENV="$STACKERY_DIR/stackery.env.local"      # decrypted, gitignored

if command -v sops >/dev/null && [[ -f "$STACKERY_ENV_ENC" ]]; then
  if [[ ! -f "$STACKERY_ENV" || "$STACKERY_ENV_ENC" -nt "$STACKERY_ENV" ]]; then
    mkdir -p "${STACKERY_ENV:h}"
    tmp_env="$(mktemp)"
    if sops -d --input-type binary --output-type binary "$STACKERY_ENV_ENC" >"$tmp_env" 2>/dev/null; then
      mv "$tmp_env" "$STACKERY_ENV"
      chmod 600 "$STACKERY_ENV"
    else
      rm -f "$tmp_env"
    fi
  fi
fi

[[ -f "$STACKERY_ENV" ]] && source "$STACKERY_ENV"
