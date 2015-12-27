#!/bin/bash

function crew-update {
  update-setup-file

  # take diff
  diff \
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
      output[cnt] = "==> Updated Formulae"
      cnt++
    }
    /^< [^\n]/ {
      output[cnt++] = $2 " " $3 " -> "
    }
    /^> [^\n]/ {
      output[cnt-1] = output[cnt-1] $3
    }
    END {
      if (cnt == 1) {
        print "Already up-to-date."
      } else {
        for (i in output) {
          print output[i]
        }
      }
    }
    '
}
