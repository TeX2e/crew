#!/bin/bash

function crew-mirror {
  local mirror_url=$1
  if [ "$mirror_url" ]; then
    awk -i inplace '
      1
      /last-mirror/ {
        getline
        print "\t" mirror_url
      }
      ' mirror_url="$mirror_url" "$ROOT_DIR/etc/setup/setup.rc"
    echo "Mirror set to "$mirror_url"."
  else
    awk '
      /last-mirror/ {
        getline
        print $1
      }
      ' "$ROOT_DIR/etc/setup/setup.rc"
  fi
}


