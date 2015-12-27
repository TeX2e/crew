#!/bin/bash

function crew-override { # <packages>
  check-packages "$@" || exit
  local pkgs="$@"
  local pkg
  for pkg in $pkgs
  do
    override-original $pkg
  done
}

function override-original { # <package>[/version]
  echo "$1" > /tmp/crew-argument
  set -- $(cat /tmp/crew-argument | awk 'BEGIN { FS="/" } { print $1, $2 }')
  local pkg=$1
  local pkg_version=$2

  if [[ ! -d "$CREW_FORMULA/$pkg" ]]; then
    warn "no such a dir: $CREW_FORMULA/$pkg"
    error "Package $pkg is not installed"
  fi

  # if it isn't passed the argument <version>, find latest version.
  if [[ "$pkg_version" == "" ]]; then
    pkg_version=$(cd $CREW_FORMULA/$pkg && /bin/ls | sort | tail -n 1)
  fi

  if [[ ! -d "$CREW_FORMULA/$pkg/$pkg_version" ]]; then
    warn "no such a version: $pkg_version"
    error "Package version missing, cannot remove $pkg"
  fi

  local pkg_formula="$CREW_FORMULA/$pkg/$pkg_version"

  if [[ ! -f "$pkg_formula/$pkg_version.lst" ]]; then
    warn "no such a list file: $pkg_formula/$pkg_version.lst"
    error "Package manifest missing, cannot remove $pkg"
  fi

  # cat "$pkg_formula/$pkg_version.lst" |
  # awk '
  #   /\/$/ {
  #     print "mkdir -p \"" root "/" $0 "\""
  #   }
  #   /[^\/]$/ {
  #     print "cp", "\"" crew_celler "/" pkg_dir "/" $0 "\"", "\"" root "/" $0 "\""
  #   }
  #   ' root="$ROOT_DIR" crew_celler="$CREW_CELLER" pkg_dir="$pkg/$pkg_version" #|
  # # sh

  local working_dir="$CREW_FORMULA/$pkg/$pkg_version"
  cd "$working_dir"
  xz -cdv "$pkg_version.tar.xz" > "$pkg_version.tar"
  tar -x -C "$ROOT_DIR/" -f "$pkg_version.tar"
  rm "$pkg_version.tar"
}
