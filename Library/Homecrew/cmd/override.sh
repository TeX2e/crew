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

  local working_dir="$CREW_FORMULA/$pkg/$pkg_version"
  cd "$working_dir"
  local download_file=$(ls | grep '\.tar\.xz\|\.tar\.bz2' | head -1)
  
  decompress_from_root "$pkg" "$download_file"
}

function decompress_at_root {
  local pkg=$1
  local download_file=$2
  local pkg_version=$(extract-version-from $download_file)
  if [[ "$download_file" =~ \.tar\.xz$ ]]; then
    tar -Jx -C "$ROOT_DIR" -f "$pkg_version.tar.xz"
    tar tf "$pkg_version.tar.xz" > "$pkg_version.lst"
  elif [[ "$download_file" =~ \.tar\.bz2$ ]]; then
    tar -jx -C "$ROOT_DIR" -f "$pkg_version.tar.bz2"
    tar tf "$pkg_version.tar.bz2" > "$pkg_version.lst"
  else
    error "unexpected extention: $download_file"
  fi
}
