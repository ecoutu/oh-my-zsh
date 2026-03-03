# 1password-env: Load 1Password secrets into environment variables
#
# Config: Define OP_ENV_SECRETS in ~/.config/op/env.zsh (or set OP_ENV_CONFIG)
# Example:
#   typeset -gA OP_ENV_SECRETS=(
#     [GITHUB_TOKEN]="op://Private/GitHub PAT/credential"
#   )

# Bail silently if op is not installed
(( ${+commands[op]} )) || return

# Track which env vars we manage (names only, for op-env-list)
typeset -ga _OP_ENV_MANAGED_VARS=()

function _op_env_load() {
  local config="${OP_ENV_CONFIG:-${HOME}/.config/op/env.zsh}"

  if [[ ! -f "$config" ]]; then
    echo "[1password-env] Config not found: $config" >&2
    echo "[1password-env] Create it with a typeset -gA OP_ENV_SECRETS=(...) array." >&2
    return 1
  fi

  source "$config"

  if (( ! ${+OP_ENV_SECRETS} )) || (( ${#OP_ENV_SECRETS} == 0 )); then
    echo "[1password-env] OP_ENV_SECRETS is empty or not defined in $config" >&2
    return 1
  fi

  _OP_ENV_MANAGED_VARS=()

  local name ref value
  for name ref in "${(@kv)OP_ENV_SECRETS}"; do
    value="$(op read "$ref" 2>/dev/null)"
    if (( $? != 0 )); then
      echo "[1password-env] Failed to read ${name} from ${ref}" >&2
      continue
    fi
    export "${name}=${value}"
    _OP_ENV_MANAGED_VARS+=("$name")
  done

  unset OP_ENV_SECRETS
}

function op-env-reload() {
  echo "[1password-env] Reloading secrets..."
  _op_env_load
  echo "[1password-env] Done. ${#_OP_ENV_MANAGED_VARS} secrets loaded."
}

function op-env-list() {
  if (( ${#_OP_ENV_MANAGED_VARS} == 0 )); then
    echo "[1password-env] No managed environment variables."
    return
  fi
  echo "[1password-env] Managed environment variables:"
  local name
  for name in "${_OP_ENV_MANAGED_VARS[@]}"; do
    echo "  $name"
  done
}

# Load secrets on plugin init
_op_env_load
