gcloud-auth-status() {
  if (( ! $+commands[gcloud] )); then
    print -u2 "gcloud-auth: gcloud is not installed"
    return 2
  fi
  local -a dead
  gcloud auth print-access-token --quiet </dev/null >/dev/null 2>&1 || dead+=(user)
  gcloud auth application-default print-access-token --quiet </dev/null >/dev/null 2>&1 || dead+=(adc)
  (( $#dead )) || return 0
  print -u2 "gcloud-auth: expired or missing credentials: ${(j:, :)dead}"
  return 1
}

gcloud-auth-ensure() {
  gcloud-auth-status
  case $? in
    0) return 0 ;;
    2) return 1 ;;
  esac
  gcloud auth login --update-adc --brief
}

_gcloud_auth_prelaunch() {
  gcloud-auth-ensure || print -u2 "gcloud-auth: still unauthenticated; gcloud, BigQuery and pg-* MCP calls will fail"
}

typeset -ga claude_prelaunch_functions
claude_prelaunch_functions+=(_gcloud_auth_prelaunch)
