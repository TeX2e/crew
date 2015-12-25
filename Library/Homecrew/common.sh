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
  # color:red
  echo -e "\033[31mError\033[m" "$*"
  exit -1
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

# function crew-cache-dir {
#   local cache_dir=$CREW_CACHE
#   local mirror_dir=$(
#     awk '
#       /last-mirror/ {
#         getline
#         print $1
#       }
#       ' "$SETUP_DIR/setup.rc" |\
#     sed -e 's,ftp://,,' -e 's,http://,,' -e 's,/$,,' )
#   echo "$cache_dir/$mirror_dir"
# }

function find-workspace {
  # default working directory and mirror
  local mirror=$(crew-mirror | sed -e 's,/$,,')
  local cache_dir=$CREW_CACHE
  local arch_dir=$(uname -m)

  echo "workspace: $cache_dir/$arch_dir"
  echo "mirror: $mirror"

  mkdir -p "$cache_dir/$arch_dir"
  cd "$cache_dir/$arch_dir"

  if [ -e setup.ini ]; then
    return 0
  else
    warn "setup.ini is not exist, getting from $mirror"
    get-setup-file
    return 1
  fi
}

function get-setup-file {
  local mirror=$(crew-mirror | sed -e 's,/$,,')
  local arch=$(uname -m)
  echo "fetch $mirror/$arch/setup.bz2"
  mv setup.ini setup.ini-save &> /dev/null
  wget -N "$mirror/$arch/setup.bz2"
  if [ -e setup.bz2 ]; then
    bunzip2 setup.bz2
    mv setup setup.ini
    success "Updated setup.ini"
    return 0
  else
    error "Error updating setup.ini, reverting"
    mv setup.ini-save setup.ini
    return 1
  fi
}

function check-packages {
  if [[ $pks ]]; then
    return 0
  else
    echo No packages found.
    return 1
  fi
}

