#!/bin/bash

function crew-remove { # <packages>
  check-packages "$@" || exit
  local pkgs=$@
  local pkg
  for pkg in $pkgs
  do
    if [[ ! -d "$CREW_CELLER/$pkg" ]]; then
      warn "no such a dir: $CREW_FORMULA/$pkg"
      error "Package $pkg is not installed"
    fi
    crew-unlink "$@"
    rm -r "$CREW_CELLER/$pkg"
  done
}
