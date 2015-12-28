#!/bin/bash

function crew-install { # <packages>
  check-packages "$@" || exit
  local pkgs=$@
  local pkg
  for pkg in $pkgs
  do
    if [ ! $FORCE ] && already-installed "$pkg"; then
      error "Package $pkg is already installed, skipping"
    fi
    if [ ! $FORCE ] && already-installed-at-default "$pkg"; then
      error "Package $pkg is already installed at default, skipping"
    fi

    mkdir -p "$CREW_FORMULA/$pkg"
    download $pkg | tee /tmp/crew-download

    # download file $pkg_version.tar.xz must be deployed

    local download_file=$(cat /tmp/crew-download | awk '/Download/ {print $3}')
    local pkg_version=$(extract-version-from $download_file)
    local working_dir="$CREW_FORMULA/$pkg/$pkg_version"
    cd "$working_dir"
    mkdir -p "$CREW_CELLER/$pkg/$pkg_version"
    if [[ "$download_file" =~ \.tar\.xz$ ]]; then
      mv "$pkg-$pkg_version.tar.xz" "$pkg_version.tar.xz"
    elif [[ "$download_file" =~ \.tar\.bz2$ ]]; then
      mv "$pkg-$pkg_version.tar.bz2" "$pkg_version.tar.bz2"
    else
      error "unexpected extention: $download_file"
    fi

    decompress "$pkg" "$download_file"
    crew-link $pkg

    local requires="$(crew-deps $pkg | awk 'NR == 1 { next } { print }')"
    for req_pkg in $requires; do
      echo "require: $req_pkg"
    done
  done
}


function download { # <package>
  local pkg=$1
  local cache_dir=$CREW_CACHE
  local mirror=$(crew-mirror | sed -e 's,/$,,')

  if (( ! $# )); then
    error "no packages given"
  fi

  if [[ ! -e "$cache_dir/setup.ini" ]]; then
    error "setup.ini is not found in $cache_dir/"
  fi
  
  # look for package and save desc file

  awk '$1 == pc' RS='\n\n@ ' FS='\n' pc="$pkg" "$cache_dir/setup.ini" \
    > "$cache_dir/desc"

  if [ ! -s "$cache_dir/desc" ]; then
    error "Unable to locate package $pkg"
  fi

  # download and unpack the bz2 or xz file

  # pick the latest version, which comes first
  set -- $(awk '$1 == "install:"' "$cache_dir/desc")

  if (( ! $# )); then
    error 'Could not find "install" in package description: obsolete package?'
  fi

  local download_dir=$(dirname $2)
  local download_file=$(basename $2)
  
  # check the md5
  local digest=$4
  case ${#digest} in
   32) hash=md5sum    ;;
  128) hash=sha512sum ;;
  esac
  
  mkdir -p "$cache_dir/$download_dir"
  cd "$cache_dir/$download_dir"

  if [ ! -e "$download_file" ] || ! $hash -c <<< "$digest $download_file" &>/dev/null; then
    debug "fetch $mirror/$download_dir/$download_file"
    wget -O "$download_file" "$mirror/$download_dir/$download_file"
    $hash -c <<< "$digest $download_file" &>/dev/null || exit
  fi

  success "Download ${download_file}"

  # download file is put on Formula
  local pkg_version=$(extract-version-from $download_file)
  mkdir -p "$CREW_FORMULA/$pkg/$pkg_version"
  mv "$cache_dir/$download_dir/$download_file" "$CREW_FORMULA/$pkg/$pkg_version/$download_file"
}

function extract-version-from { # <download-file>
  local download_file=$1
  echo $download_file | sed -e 's/'$pkg'-//' -e 's/\.tar.*//'
}

function sha512sum {
  case `uname` in
    Darwin )
      openssl dgst -sha512 "$@" ;;
    * )
      command sha512sum "$@" ;;
  esac
}

function decompress {
  local pkg=$1
  local download_file=$2
  local pkg_version=$(extract-version-from $download_file)
  if [[ "$download_file" =~ \.tar\.xz$ ]]; then
    tar -Jx -C "$CREW_CELLER/$pkg/$pkg_version" -f "$pkg_version.tar.xz"
    tar tf "$pkg_version.tar.xz" > "$pkg_version.lst"
  elif [[ "$download_file" =~ \.tar\.bz2$ ]]; then
    tar -jx -C "$CREW_CELLER/$pkg/$pkg_version" -f "$pkg_version.tar.bz2"
    tar tf "$pkg_version.tar.bz2" > "$pkg_version.lst"
  else
    error "unexpected extention"
  fi
}
