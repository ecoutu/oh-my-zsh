if (( ! $+commands[claude] )); then
  return
fi

typeset -g CLAUDE_OPS_SETTINGS='{"enabledPlugins":{"typescript-lsp@claude-plugins-official":false}}'

claude-ops() {
  command claude --dangerously-skip-permissions --settings "$CLAUDE_OPS_SETTINGS" "$@"
}

(( $+functions[compdef] )) && compdef claude-ops=claude

claude-mcp-status() {
  "$HOME/.claude/scripts/mcp-status.sh" "$@"
}

typeset -ga claude_prelaunch_functions

claude() {
  (
    local fn
    for fn in $claude_prelaunch_functions; do
      (( $+functions[$fn] )) && $fn
    done
    command claude "$@"
  )
}
