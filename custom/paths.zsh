# Set the the list of directories that cd searches.
cdpath+=(
  ${HOME}
  ${DEV_ROOT}
  ${ECO_ROOT}
  ${ECO_SRC}
  ${EMPLOYER_ROOT}
  ${EMPLOYER_SRC}
)

# Set the list of directories that Zsh searches for programs.
path+=(
  ${HOME}/.local/{,s}bin
  ${HOME}/{,s}bin(N)
  /usr/local/{,s}bin(N)
)

case "$OSTYPE" in
  darwin*)
    path+=(
      /opt/{homebrew,local}/{,s}bin(N)
    )
    ;;
esac

PROJECT_PATHS=(
  "${ECO_SRC}"
  "${EMPLOYER_SRC}"
)

fpath+=(
  ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
  "${HOME}/.zsh/completions"
  "${HOME}/.local/share/mise/installs/zoxide/latest/completions"
)
