#!/bin/bash

function crew-deps { # <packages>
  check-packages "$@" || exit
  local pkgs=$@
  local pkg
  for pkg in $pkgs
  do
    awk '
      /^@ / {
        pkg_name = $2
        next
      }
      /^requires: / {
        DEPS[pkg_name] = substr($0, length("requires: ")+1)
      }
      ENDFILE {
        # for (i in DEPS) {
        #   print i, "=>", DEPS[i]
        # }
        show_pkg_deps(top_pkg, "")
      }
      function show_pkg_deps(my_pkg, indent,    require_pkgs) {
        if (MARKED_PKG[my_pkg]) return
        print indent my_pkg
        MARKED_PKG[my_pkg] = 1
        indent = indent "  "
        split(DEPS[my_pkg], require_pkgs, " ")
        for (i in require_pkgs) {
          show_pkg_deps(require_pkgs[i], indent)
        }
      }
      ' top_pkg="$pkg" "$CREW_CACHE/setup.ini"
  done
}

