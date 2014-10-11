# Eric Coutu's theme, based off pygmalion

prompt_setup_pygmalion(){
  ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}:%{$fg[magenta]%}("
  ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}%{$fg[magenta]%})%{$reset_color%} "
  ZSH_THEME_GIT_PROMPT_DIRTY="%{$reset_color%}%{$fg[red]%}Δ%{$reset_color%}"
  ZSH_THEME_GIT_PROMPT_CLEAN=""

  base_prompt='%{$fg[green]%}%n@%m%{$reset_color%}:%{$fg[cyan]%}${PWD/#$HOME/~}'
  post_prompt='%{$fg[cyan]%}$%{$reset_color%} '

  base_prompt_nocolor=$(echo "$base_prompt" | perl -pe "s/%\{[^}]+\}//g")
  post_prompt_nocolor=$(echo "$post_prompt" | perl -pe "s/%\{[^}]+\}//g")

  # add-zsh-hook precmd prompt_pygmalion_precmd
  precmd_functions+=(prompt_pygmalion_precmd)
}

prompt_pygmalion_precmd(){
  local gitinfo=$(git_prompt_info)
  local gitinfo_nocolor=$(echo "$gitinfo" | perl -pe "s/%\{[^}]+\}//g")
  local exp_nocolor="$(print -P \"$base_prompt_nocolor$gitinfo_nocolor$post_prompt_nocolor\")"
  local prompt_length=${#exp_nocolor}
  local swiq_env_prompt=""
  local virtual_env_prompt=""
  local nl=""

  if [[ $prompt_length -gt 40 ]]; then
    nl=$'\n%{\r%}';
  fi

  if [[ ! -z "$SWIQ_ENV" ]]; then
    swiq_env_prompt="%{$fg[magenta]%}($SWIQ_ENV)%{$reset_color%}"
  fi

  if [[ ! -z "$VIRTUAL_ENV" ]]; then
    virtual_env_prompt="($(basename "$VIRTUAL_ENV"))"
  fi

  PROMPT="$(virtualenv_prompt_info)$swiq_env_prompt$base_prompt$gitinfo$nl$post_prompt"
}

prompt_setup_pygmalion


