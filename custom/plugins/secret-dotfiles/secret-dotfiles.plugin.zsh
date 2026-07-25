if [[ -d "${HOME}/.zsh" ]]; then
  for file in ${HOME}/.zsh/*; do
    if [[ ! -d "${file}" ]]; then
      source "${file}"
    fi
  done
fi
