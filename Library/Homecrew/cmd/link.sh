#!/bin/bash

function crew-link { # <packages>
  check-packages "$@" || exit
  local pkgs="$@"
  local pkg
  for pkg in $pkgs
  do
    create-sym-link $pkg
  done
}

function create-sym-link { # <package>[/version]
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

  cat "$pkg_formula/$pkg_version.lst" |
  awk '
    /\/$/ {
      print "mkdir -p \"" root "/" $0 "\""
    }
    /[^\/]$/ {
      origin_file = "\"" crew_celler "/" pkg_dir "/" $0 "\""
      symlink_file = "\"" root "/" $0 "\""
      create_link = "ln -sf " origin_file " " symlink_file
      print "",
        "if", "test -L", symlink_file, "||", "test ! -e", symlink_file "; then",
          create_link ";",
        "else",
          "echo file already exist:", root "/" $0, ";",
        "fi;"
    }
    ' root="$ROOT_DIR" crew_celler="$CREW_CELLER" pkg_dir="$pkg/$pkg_version" |
  sh &> /tmp/crew-link

  # check if success
  if grep -F 'file already exist:' /tmp/crew-link &>/dev/null; then
    warn "Some files cannot linked." \
      "If you want to override the original, type:\n" \
      "    crew override $pkg"
    return 1
  else
    success "Create symbolic links"
    return 0
  fi
}
