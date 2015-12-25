#!/bin/bash
# crew: install tool for Cygwin similar to Mac OS brew
#
# The MIT License (MIT)

ROOT_DIR="$HOME/Documents/pgm/bash/cygwin64"
CREW_DIR="$ROOT_DIR/usr/local"
CREW_CELLER="$CREW_DIR/Celler"
CREW_LIBRARY="$CREW_DIR/Library"
CREW_CMD="$CREW_LIBRARY/Homecrew/cmd"
CREW_UTILS="$CREW_LIBRARY/Homecrew/utils"
CREW_FORMULA="$CREW_LIBRARY/Formula"
SETUP_DIR="$ROOT_DIR/etc/setup"
CREW_CACHE="$CREW_DIR/crew-cache"

function include {
  for file in $@; do
    test -f "$file" && source "$file"
  done
}

include "$CREW_LIBRARY/Homecrew/common.sh"
include "$CREW_LIBRARY/Homecrew/cmd/*.sh"

function crew-debug {
  :
}


SUBCOMMAND=""
DRY_RUN=false
INITIAL_ARGS=( "$@" )
ARGS=()
while [ $# -gt 0 ]
do
  case "$1" in
  --dry-run)
    DRY_RUN=1
    shift
    ;;
  --help)
    crew-help
    exit 0
    ;;
  --version|-v)
    crew-version
    exit 0
    ;;
  *)
    if [ -z "$SUBCOMMAND" ]; then
      SUBCOMMAND="$1"
    else
      ARGS+=( "$1" )
    fi
    shift
    ;;
  esac
done

function invoke-subcommand {
  local SUBCOMMAND="${@:1:1}"
  local ARGS=( "${@:2}" )
  local ACTION="crew-${SUBCOMMAND:-help}"
  if type "$ACTION" &>/dev/null; then
    "$ACTION" "${ARGS[@]}"
  else
    echo "unknown command: $SUBCOMMAND"
    exit 1
  fi
}

invoke-subcommand "$SUBCOMMAND" "${ARGS[@]}"
