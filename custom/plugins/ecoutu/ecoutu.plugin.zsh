export DEV_ROOT="${HOME}/src"

export ECOUTU_ROOT="${HOME}/ecoutu"
export ECOUTU_SRC="${ECOUTU_ROOT}/src"

if (( ${+ECOUTU_OP_ENV_ENTRY} )); then
  OP_ENV_ENTRIES+=("${ECOUTU_OP_ENV_ENTRY}")
fi