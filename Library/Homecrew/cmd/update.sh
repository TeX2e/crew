#!/bin/bash

function crew-update {
  update-setup-file

  # take diff
  awk -f "$CREW_UTILS/take-diff.awk" \
    <(
      grep '^@\|^version:' $CREW_CACHE/setup.ini-save |
      awk 'BEGIN { RS = "\n@ " } { print $1, $3 }'
    ) \
    <(
      grep '^@\|^version:' $CREW_CACHE/setup.ini |
      awk 'BEGIN { RS = "\n@ " } { print $1, $3 }'
    )
}
