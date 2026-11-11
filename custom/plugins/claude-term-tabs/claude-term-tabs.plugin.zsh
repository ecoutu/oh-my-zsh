# Tab completion for claude-term-tabs (and its `ctt` alias), cached like the codex plugin.
if (( $+commands[claude-term-tabs] )); then
  # If the completion file doesn't exist yet, autoload it and bind it now;
  # otherwise compinit has already picked it up from $ZSH_CACHE_DIR/completions.
  if [[ ! -f "$ZSH_CACHE_DIR/completions/_claude-term-tabs" ]]; then
    typeset -g -A _comps
    autoload -Uz _claude-term-tabs
    _comps[claude-term-tabs]=_claude-term-tabs
    _comps[ctt]=_claude-term-tabs
  fi

  # Older claude-term-tabs has no `completion` subcommand and would treat the word as a
  # search (and switch tabs), so only ask for the script when --help lists it.
  (
    claude-term-tabs --help 2> /dev/null | command grep -q '^ *ctt completion' || exit
    script="$(claude-term-tabs completion zsh 2> /dev/null)" || exit
    [[ "$script" == '#compdef '* ]] || exit
    print -r -- "$script" >| "$ZSH_CACHE_DIR/completions/_claude-term-tabs"
  ) &|
fi
