# 1password-env Plugin Design

## Overview

An oh-my-zsh custom plugin that loads 1Password secret references and exports them as environment variables at shell startup.

## Configuration

**Config path:** `~/.config/op/env.zsh` (override via `OP_ENV_CONFIG`)

**Format:** Zsh associative array mapping env var names to `op://` references:

```zsh
typeset -gA OP_ENV_SECRETS=(
  [GITHUB_TOKEN]="op://Private/GitHub PAT/credential"
  [NPM_TOKEN]="op://Development/npm/token"
  [AWS_SECRET_ACCESS_KEY]="op://Work/AWS/secret-key"
)
```

## Plugin Files

```
custom/plugins/1password-env/
  1password-env.plugin.zsh   # Plugin logic
```

## Plugin Flow

1. Guard: exit if `op` not installed
2. Source config file (warn and return if missing)
3. Iterate `OP_ENV_SECRETS`: resolve each via `op read`, export on success, warn on failure
4. Unset `OP_ENV_SECRETS` array (don't leak refs)

## Helper Commands

- `op-env-reload` - Re-source config and re-resolve all secrets
- `op-env-list` - Show managed env var names (not values)

## Error Handling

- `op` missing: silent return
- Config missing: warning, return
- Per-secret failure: warn with var name and ref, continue
- `op` unauthenticated: per-secret warnings from failed `op read`

## Security

- Secrets only in env vars, never on disk
- `OP_ENV_SECRETS` unset after processing
- `op-env-list` shows names only
- Config contains refs, not secrets

## Plugin Placement in .zshrc

Must come after `1password` in the plugins list (depends on `op` completions being set up).
