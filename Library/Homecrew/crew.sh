#!/bin/bash
# crew: install tool for Cygwin similar to Mac OS brew
#
# The MIT License (MIT)
# 
# Copyright (c) 2015 TeX2e.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

export ROOT_DIR="$HOME/Documents/pgm/bash/cygwin64"
export CREW_DIR="$ROOT_DIR/usr/local"
export CREW_CELLER="$CREW_DIR/Celler"
export CREW_LIBRARY="$CREW_DIR/Library"
export CREW_CMD="$CREW_LIBRARY/Homecrew/cmd"
export CREW_UTILS="$CREW_LIBRARY/Homecrew/utils"
export CREW_FORMULA="$CREW_LIBRARY/Formula"
export SETUP_DIR="$ROOT_DIR/etc/setup"
export CREW_CACHE="$CREW_DIR/crew-cache"

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
