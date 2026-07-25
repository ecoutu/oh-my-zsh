# 1password-env: Resolve 1Password secrets from template files and source them
#
# Each entry is "account|template|output":
#   account  - the 1Password account passed to `op inject --account`
#   template - a file with op:// references (standard .env format works:
#              KEY=op://Vault/Item/field). `op inject` substitutes only the
#              op:// tokens, leaving KEY= intact, so the output stays sourceable.
#   output   - the resolved env file (generated, sourced on every shell)
#
# Example template (~/.env.vn.tpl):
#   GITHUB_TOKEN=op://Private/GitHub PAT/credential
#   NPM_TOKEN=op://Development/npm/token

# Bail silently if op is not installed
(( ${+commands[op]} )) || return

# account|template|output  (override in ~/.zshrc before this plugin loads)
typeset -ga OP_ENV_ENTRIES

# _op_env_generate <account> <template> <output>
function _op_env_generate() {
  local account="$1" template="$2" output="$3"

  if [[ ! -f "$template" ]]; then
    echo "[1password-env] Template not found: $template" >&2
    return 1
  fi

  if ! op inject --account "$account" -i "$template" -o "$output" --force 2>/dev/null; then
    echo "[1password-env] Failed to inject ${template} (account ${account})" >&2
    return 1
  fi

  chmod 600 "$output"
}

# _op_env_source <output>
function _op_env_source() {
  local output="$1"
  [[ -f "$output" ]] || return 1

  local line key value
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue

    key="${line%%=*}"
    value="${line#*=}"

    # Strip a single layer of surrounding quotes the template may have added
    value="${value#\"}"; value="${value%\"}"
    value="${value#\'}"; value="${value%\'}"

    export "$key=$value"
  done < "$output"
}

function op-env-reload() {
  echo "[1password-env] Regenerating secrets..."
  local entry account template output
  for entry in "${OP_ENV_ENTRIES[@]}"; do
    local parts=("${(@s:|:)entry}")
    account="${parts[1]}" template="${parts[2]}" output="${parts[3]}"
    command rm -f "$output"
    _op_env_generate "$account" "$template" "$output" && _op_env_source "$output"
  done
  echo "[1password-env] Done."
}

function op-env-list() {
  local entry output line found=0
  for entry in "${OP_ENV_ENTRIES[@]}"; do
    local parts=("${(@s:|:)entry}")
    output="${parts[3]}"
    [[ -f "$output" ]] || continue
    found=1
    echo "[1password-env] ${output}:"
    while IFS= read -r line; do
      [[ -z "$line" || "$line" == \#* ]] && continue
      echo "  ${line%%=*}"
    done < "$output"
  done
  (( found )) || echo "[1password-env] No generated env files found."
}

# Plugin init: per entry, (re)generate if missing or template changed, then source
() {
  local entry account template output
  for entry in "${OP_ENV_ENTRIES[@]}"; do
    local parts=("${(@s:|:)entry}")
    account="${parts[1]}" template="${parts[2]}" output="${parts[3]}"

    if [[ -f "$template" ]] && [[ ! -f "$output" || "$template" -nt "$output" ]]; then
      _op_env_generate "$account" "$template" "$output" && _op_env_source "$output"
    elif [[ -f "$output" ]]; then
      _op_env_source "$output"
    fi
  done
}
