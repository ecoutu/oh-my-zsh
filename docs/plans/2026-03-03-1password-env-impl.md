# 1password-env Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create an oh-my-zsh plugin that reads 1Password secret references from a config file and exports them as environment variables at shell startup.

**Architecture:** A single plugin file sources a user config (zsh associative array mapping env var names to `op://` refs), iterates the entries calling `op read` for each, and exports the resolved values. Helper functions allow reloading and listing managed vars.

**Tech Stack:** Zsh, 1Password CLI (`op` v2+), oh-my-zsh plugin conventions

---

### Task 1: Core plugin — guard clauses and config loading

**Files:**
- Modify: `custom/plugins/1password-env/1password-env.plugin.zsh`

**Step 1: Write the plugin skeleton with guard and config sourcing**

```zsh
# 1password-env: Load 1Password secrets into environment variables
#
# Config: Define OP_ENV_SECRETS in ~/.config/op/env.zsh (or set OP_ENV_CONFIG)
# Example:
#   typeset -gA OP_ENV_SECRETS=(
#     [GITHUB_TOKEN]="op://Private/GitHub PAT/credential"
#   )

# Bail silently if op is not installed (matches built-in 1password plugin behavior)
(( ${+commands[op]} )) || return

local _op_env_config="${OP_ENV_CONFIG:-${HOME}/.config/op/env.zsh}"

if [[ ! -f "$_op_env_config" ]]; then
  echo "[1password-env] Config not found: $_op_env_config" >&2
  echo "[1password-env] Create it with a typeset -gA OP_ENV_SECRETS=(...) array." >&2
  return 1
fi

source "$_op_env_config"

if (( ! ${+OP_ENV_SECRETS} )) || (( ${#OP_ENV_SECRETS} == 0 )); then
  echo "[1password-env] OP_ENV_SECRETS is empty or not defined in $_op_env_config" >&2
  return 1
fi
```

**Step 2: Verify manually**

Open a new terminal without the config file present. Expected:
```
[1password-env] Config not found: /Users/ecoutu/.config/op/env.zsh
[1password-env] Create it with a typeset -gA OP_ENV_SECRETS=(...) array.
```

**Step 3: Commit**

```bash
git add custom/plugins/1password-env/1password-env.plugin.zsh
git commit -m "feat(1password-env): add plugin skeleton with guard clauses and config loading"
```

---

### Task 2: Secret resolution loop

**Files:**
- Modify: `custom/plugins/1password-env/1password-env.plugin.zsh`

**Step 1: Add the secret resolution loop after config sourcing**

Append after the config validation block from Task 1:

```zsh
# Track which env vars we manage (names only, for op-env-list)
typeset -ga _OP_ENV_MANAGED_VARS=()

local _op_env_name _op_env_ref _op_env_value
for _op_env_name _op_env_ref in "${(@kv)OP_ENV_SECRETS}"; do
  _op_env_value="$(op read "$_op_env_ref" 2>/dev/null)"
  if (( $? != 0 )); then
    echo "[1password-env] Failed to read ${_op_env_name} from ${_op_env_ref}" >&2
    continue
  fi
  export "${_op_env_name}=${_op_env_value}"
  _OP_ENV_MANAGED_VARS+=("$_op_env_name")
done

# Clean up — don't leak refs into environment
unset OP_ENV_SECRETS
```

**Step 2: Create the config file for testing**

```bash
mkdir -p ~/.config/op
```

Write `~/.config/op/env.zsh`:
```zsh
typeset -gA OP_ENV_SECRETS=(
  # Add one real ref you have access to for testing, e.g.:
  # [TEST_SECRET]="op://Private/Test Item/password"
)
```

**Step 3: Verify manually**

Open a new terminal with a valid secret ref in the config. Run:
```bash
echo $TEST_SECRET  # should print the resolved value
```

With an invalid ref, expected stderr:
```
[1password-env] Failed to read BAD_VAR from op://Nonexistent/item/field
```

**Step 4: Commit**

```bash
git add custom/plugins/1password-env/1password-env.plugin.zsh
git commit -m "feat(1password-env): add secret resolution loop with per-entry error handling"
```

---

### Task 3: Helper commands — op-env-reload and op-env-list

**Files:**
- Modify: `custom/plugins/1password-env/1password-env.plugin.zsh`

**Step 1: Extract the core logic into a function and add helpers**

Refactor the plugin so the resolution logic lives in `_op_env_load` (called at source time and by `op-env-reload`). Add `op-env-list` and `op-env-reload` as user-facing commands.

The full final plugin file should be:

```zsh
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
```

**Step 2: Verify manually**

```bash
# In a new terminal:
op-env-list          # Should list managed var names
op-env-reload        # Should re-resolve all secrets
op-env-list          # Should still list the same vars
```

**Step 3: Commit**

```bash
git add custom/plugins/1password-env/1password-env.plugin.zsh
git commit -m "feat(1password-env): add op-env-reload and op-env-list helper commands"
```

---

### Task 4: Add plugin to .zshrc and create example config

**Files:**
- Modify: `.zshrc` (add `1password-env` to plugins list)

**Step 1: Add `1password-env` to plugins list after `1password`**

In `.zshrc`, add `1password-env` right after the `1password` entry in the plugins array.

**Step 2: Create example config**

Create `~/.config/op/env.zsh` with your actual secret mappings. Example structure:

```zsh
typeset -gA OP_ENV_SECRETS=(
  # Format: [ENV_VAR_NAME]="op://vault/item/field"
  #
  # Find refs with: op item list --vault <vault> --format json
  # Test a ref with: op read "op://vault/item/field"
)
```

**Step 3: Verify end-to-end**

```bash
# Open a new terminal
op-env-list    # Should show your managed vars (or "No managed" if config is empty)
```

**Step 4: Commit**

```bash
git add .zshrc
git commit -m "feat(zshrc): add 1password-env plugin"
```
