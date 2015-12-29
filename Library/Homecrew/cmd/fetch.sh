#!/bin/bash

function crew-fetch { # [<packages>]
  check-packages "$@" || exit
  local pkgs="$@"
  local pkg
  for pkg in $pkgs
  do
    download $pkg
  done
}
