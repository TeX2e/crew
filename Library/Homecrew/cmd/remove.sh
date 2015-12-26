#!/bin/bash

function crew-remove { # <packages>
  check-packages "$@" || exit
  crew-unlink "$@" || exit
}
