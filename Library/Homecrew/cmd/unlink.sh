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
  :
}
