#!/bin/bash

function crew-update {
  update-setup-file

  # take diff
  diff --speed-large-files \
    <(
      grep '^@\|^version:' $CREW_CACHE/setup.ini-save |
      awk 'BEGIN { RS = "\n@ " } { print $1, $3, "\n" }'
    ) \
    <(
      grep '^@\|^version:' $CREW_CACHE/setup.ini |
      awk 'BEGIN { RS = "\n@ " } { print $1, $3, "\n" }'
    ) |
  awk '
    BEGIN {
      print "==> Updated Formulae"
    }
    /^</ {
      printf "%s %s -> ", $2, $3
    }
    /^>/ {
      print $3
    }
    '
}
