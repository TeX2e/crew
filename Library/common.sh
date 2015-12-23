#!/bin/bash

function get-fullpath {
  echo $(cd $(dirname $0); pwd)
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
    warn wget is not installed, using lynx as fallback
    set "${*: -1}"
    lynx -source "$1" > "${1##*/}"
  fi
}

function find-workspace {
  # default working directory and mirror
  test $mirror || mirror="ftp.iij.ad.jp/pub/cygwin"
  test $cache  || cache="$CREW_DIR/crew-cache"
  arch="$(uname -m)"

  echo "workspace: $cache/$mirror/$arch"
  
  # # work wherever setup worked last, if possible
  # cache=$(awk '
  # BEGIN {
  #   RS = "\n\\<"
  #   FS = "\n\t"
  # }
  # $1 == "last-cache" {
  #   print $2
  # }
  # ' /etc/setup/setup.rc)

  # mirror=$(awk '
  # /last-mirror/ {
  #   getline
  #   print $1
  # }
  # ' /etc/setup/setup.rc)
  # mirrordir=$(sed '
  # s / %2f g
  # s : %3a g
  # ' <<< "$mirror")

  mkdir -p "$cache/$mirror/$arch"
  cd "$cache/$mirror/$arch"
  if [ -e setup.ini ]; then
    return 0
  else
    warn "setup.ini is not exist, getting from ftp://$mirror"
    get-setup
    return $?
  fi
}

function get-setup {
  mv setup.ini setup.ini-save &> /dev/null
  wget -N "ftp://$mirror/$arch/setup.bz2"
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

