# 1password-env: Resolve 1Password secrets into ~/.env and source it
#
# Template: ~/.env.op (standard .env format with op:// references as values)
# Output:   ~/.env (resolved secrets, generated once, sourced on every shell)
#
# Example ~/.env.op:
#   GITHUB_TOKEN=op://Private/GitHub PAT/credential
#   NPM_TOKEN="op://Development/npm/token"

# Bail silently if op is not installed
(( ${+commands[op]} )) || return

typeset -g _OP_ENV_TEMPLATE="${HOME}/.env.op"
typeset -g _OP_ENV_FILE="${HOME}/.env"

function _op_env_generate() {
  if [[ ! -f "$_OP_ENV_TEMPLATE" ]]; then
    echo "[1password-env] Template not found: $_OP_ENV_TEMPLATE" >&2
    return 1
  fi

  local lines=()
  local line key ref value

  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue

    key="${line%%=*}"
    ref="${line#*=}"

    # Strip surrounding quotes from reference
    ref="${ref#\"}"
    ref="${ref%\"}"
    ref="${ref#\'}"
    ref="${ref%\'}"

    value="$(op read "$ref" 2>/dev/null)"
    if (( $? != 0 )); then
      echo "[1password-env] Failed to read ${key} from ${ref}" >&2
      continue
    fi

    # Single-quote value, escaping any embedded single quotes
    lines+=("${key}='${value//\'/\'\\\'\'}'")
  done < "$_OP_ENV_TEMPLATE"

  printf '%s\n' "${lines[@]}" > "$_OP_ENV_FILE"
  chmod 600 "$_OP_ENV_FILE"
}

function _op_env_source() {
  [[ -f "$_OP_ENV_FILE" ]] || return 1

  local line
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    export "$line"
  done < "$_OP_ENV_FILE"
}

function op-env-reload() {
  echo "[1password-env] Regenerating secrets..."
  command rm -f "$_OP_ENV_FILE"
  _op_env_generate && _op_env_source
  echo "[1password-env] Done."
}

function op-env-list() {
  if [[ ! -f "$_OP_ENV_FILE" ]]; then
    echo "[1password-env] No generated env file found."
    return
  fi

  echo "[1password-env] Managed environment variables:"
  local line
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    echo "  ${line%%=*}"
  done < "$_OP_ENV_FILE"
}

# Plugin init: generate if missing or template changed, then source
if [[ -f "$_OP_ENV_TEMPLATE" ]] && [[ ! -f "$_OP_ENV_FILE" || "$_OP_ENV_TEMPLATE" -nt "$_OP_ENV_FILE" ]]; then
  _op_env_generate
elif [[ -f "$_OP_ENV_FILE" ]]; then
  _op_env_source
fi
