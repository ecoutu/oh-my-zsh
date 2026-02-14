export DEV_ROOT="${HOME}/src"

export ECO_ROOT="${HOME}/ecoutu"
export ECO_SRC="${ECO_ROOT}/src"

export EMPLOYER_ROOT="${HOME}/${EMPLOYER}"
export EMPLOYER_SRC="${EMPLOYER_ROOT}/src"

if [[ -d "${HOME}/.zsh" ]]; then
  for file in ${HOME}/.zsh/*; do
    if [[ ! -d "${file}" ]]; then
      source "${file}"
    fi
  done
fi
