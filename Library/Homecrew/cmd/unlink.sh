#!/bin/bash

function crew-unlink { # <packages>
  local pkgs=$@
  local pkg
  for pkg in $pkgs
  do
    remove-sym-link $pkg
  done
}

function remove-sym-link { # <package>
  echo "$1" > /tmp/crew-sym-link
  set -- $(cat /tmp/crew-sym-link | awk 'BEGIN { FS="/" } { print $1, $2 }')
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

  cat "$pkg_formula/$pkg_version.lst" |\
  awk '
    BEGIN {
      dirs_num = 0
    }
    /\/$/ {
      dirs[dirs_num] = "\"" root "/" $0 "\""
      dirs_num++
    }
    /[^\/]$/ {
      print "test -L \"" root "/" $0 "\" && rm \"" root "/" $0 "\""
    }
    END {
      for (i = dirs_num - 1; i >= 0; i--) {
        print "rmdir " dirs[i], "&>/dev/null"
      }
    }
    ' root="$ROOT_DIR" crew_celler="$CREW_CELLER" |\
  sh
}
