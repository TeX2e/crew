#!/bin/bash

function get-fullpath {
  echo $(cd $(dirname $0); pwd)
}

# use to tell strong message
function notice {
  echo "[Notice]" "$*"
}

# use to tell weak message
function info {
  echo "[Info]" "$*"
}

function warn {
  # color:yellow
  echo -e "\033[33mWarning\033[m" "$*"
}

function error {
  local exit_this=true
  if [[ $1 = -c ]]; then
    shift
    exit_this=false
  fi
  # color:red
  echo -e "\033[31mError\033[m" "$*"
  $exit_this && exit -1
}

function success {
  # color:green
  echo -e "\033[32mSuccess\033[m" "$*"
}

function wget {
  if command wget -h &>/dev/null; then
    command wget "$@"
  else
    warn "wget is not installed, using lynx as fallback"
    set "${*: -1}"
    lynx -source "$1" > "${1##*/}"
  fi
}

function find-workspace {
  local cache_dir=$CREW_CACHE
  test -e "$cache_dir" && return true || return false
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
  info "fetch $mirror/$arch/setup.bz2"
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

