#! /bin/bash

readonly debug_output='yes'


log() {
  printf '\e[0;33m[LOG]  %s\e[0m\n' "${*}" 1>&2
}

debug() {
  if [ "${debug_output}" = 'yes' ]; then
    printf '\e[0;36m[DBG] %s\e[0m\n' "${*}" 1>&2
  fi
}

error() {
  printf '\e[0;31m[ERR] %s\e[0m\n' "${*}" 1>&2
}


