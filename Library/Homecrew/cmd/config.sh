#!/bin/bash

function crew-config {
  echo "HOMECREW_PREFIX: $CREW_DIR"
  echo "HOMECREW_CELLER: $CREW_CELLER"
  echo "HOMECREW_FORMULA: $CREW_FORMULA"
  echo "HOMECREW_CACHE: $CREW_CACHE"
  which git &>/dev/null && echo "Git: $(which git)"
}
