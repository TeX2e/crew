#!/bin/bash

function get-fullpath {
  echo $(cd $(dirname $0) && pwd)
}

function debug {
  [ $DEBUG ] && echo "$*"
}

function red {
  echo -ne "\033[31m$*\033[m"
}
function yellow {
  echo -ne "\033[33m$*\033[m"
}
function green {
  echo -ne "\033[32m$*\033[m"
}

function error {
  local exit_this=true
  if [[ $1 = -c ]]; then
    shift
    exit_this=false
  fi
  red "Error"; echo -e " $*"
  $exit_this && exit -1
}

function warn {
  yellow "Warning"; echo -e " $*"
}

function success {
  green "Success"; echo -e " $*"
}

function wget {
  if command wget -h &>/dev/null; then
    command wget --quiet --show-progress "$@"
  else
    warn "wget is not installed, using lynx as fallback"
    set "${*: -1}"
    lynx -source "$1" > "${1##*/}"
  fi
}

function find-workspace {
  local cache_dir=$CREW_CACHE
  test -e "$cache_dir" && return 0 || return 1
}

function create-workspace {
  # default working directory and mirror
  local cache_dir=$CREW_CACHE

  echo "workspace: $cache_dir"

  mkdir -p "$cache_dir"
  cd "$cache_dir"

  if [ -e setup.ini ]; then
    return 0
  else
    return 1
  fi
}

function get-setup-file {
  local mirror=$(crew-mirror | sed -e 's,/$,,')
  local arch=$(uname -m)
  debug "fetch $mirror/$arch/setup.bz2"

  mkdir -p "$CREW_CACHE/"
  cd "$CREW_CACHE/"

  mv setup.ini setup.ini-save &> /dev/null
  wget -N "$mirror/$arch/setup.bz2"
  if [ -e setup.bz2 ]; then
    bunzip2 setup.bz2
    mv setup setup.ini
    success "Updated setup.ini"
    return 0
  else
    mv setup.ini-save setup.ini
    error "Error updating setup.ini, reverting"
    return 1
  fi
}

function update-setup-file {
  find-workspace || create-workspace
  get-setup-file
}

function check-packages {
  pks="$@"
  if [[ $pks ]]; then
    return 0
  else
    echo No packages found.
    return 1
  fi
}

# returns ture or false
function already-installed { # <package>
  local pkg=$1
  (ls "$CREW_FORMULA/" | grep '^'"$pkg") &>/dev/null
  return $?
}

# returns ture or false
function already-installed-at-default { # <package>
  local pkg=$1
  grep '^'"$pkg"' ' "$SETUP_DIR/installed.db" &>/dev/null
  return $?
}

function ask_user {
  local question=$1
  read -p "$question (y/n) " answer
  case ${answer:0:1} in
    y|Y )
      echo Yes && return 0 ;;
    * )
      echo No  && return 1 ;;
  esac
}

function progress-bar {
  if test $# != 2; then
    error "progress-bar requires two arguments of number"
  fi
  # process data
  let _progress=$(( (${1}*100 / ${2}*100) / 100 ))
  let _done=$(( (${_progress}*7) / 10 ))
  let _left=$(( 70 - $_done ))
  # build progressbar string lengths
  _fill=$(printf "%${_done}s")
  _empty=$(printf "%${_left}s")
  # build progressbar strings
  # Output example:
  # ######################################## 100%
  printf "\r${_fill// /#}${_empty} ${_progress}%%"
}
