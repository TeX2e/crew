#!/bin/bash

function crew-desc { # <packages>
  check-packages "$@" || exit
  local pkgs=$@
  local pkg
  for pkg in $pkgs
  do
    awk '
      $1 == "@" && $2 == pkg {
        getline
        sub(/^sdesc: \"/, "", $0)
        sub(/\"$/, "", $0)
        print
        exit
      }
      ' pkg="$pkg" "$CREW_CACHE/setup.ini"
  done
}
