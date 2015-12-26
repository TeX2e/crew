#!/bin/bash

LF='\
'

function crew-info { # <packages>
  check-packages "$@" || exit
  local pkgs=$@
  local pkg
  for pkg in $pkgs
  do
    awk '
      BEGIN {
        RS = "\n\n@ "
      }
      $1 == pkg {
        sub(/\n\[prev\].*/, "", $0)
        print
        exit
      }
      ENDFILE {
        print "Unable to locate package " pkg
      }
      ' pkg="$pkg" "$CREW_CACHE/setup.ini"                   |
    sed -e 's,^sdesc: "\([^"]*\)",\1,'                       |
    sed -e 's,^ldesc: ",==> Description'"$LF"',' -e 's,"$,,' |
    sed -e 's,^category: ,==> Category'"$LF"','              |
    sed -e 's,^requires: ,==> Dependencies'"$LF"','          |
    sed -e 's,^version: ,==> Version'"$LF"','                |
    awk '/^install:/, /^$/ { next } { print }'               |
    sed -e 's,^==>,[34m==>[m,g'
    echo -e "\033[34m==>\033[m Status"
    if [[ -d "$CREW_CELLER/$pkg" ]]; then
      echo "Installed:"
      for dir in "$CREW_CELLER/$pkg/"*
      do
        echo $dir
      done
    else
      echo "Not installed"
    fi
  done
}


