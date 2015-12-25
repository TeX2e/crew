#!/bin/bash

function crew-install { # <packages>
  local pkgs=$@
  local pkg
  for pkg in $pkgs
  do
    mkdir -p "$CREW_FORMULA/$pkg"
    download $pkg | tee /tmp/crew-download

    # pkg.tar.xz must be deployed

    local download_file=$(cat /tmp/crew-download | awk '/Download/ {print $3}')
    local pkg_version=${download_file%.tar.xz}
    local working_dir="$CREW_FORMULA/$pkg/$pkg_version"
    cd "$working_dir"
    mkdir -p "$CREW_CELLER/$pkg/$pkg_version"

    # decompress
    xz -cdv "$pkg_version.tar.xz" > "$pkg_version.tar"
    tar -x -C "$CREW_CELLER/$pkg/$pkg_version" -f "$pkg_version.tar"
    tar tf "$pkg_version.tar.xz" | gzip > "$pkg_version.lst.gz"

    rm "$pkg_version.tar"
  done
}


function download { # <package>
  local pkg=$1
  local cache_dir=$CREW_CACHE
  local mirror=$(crew-mirror | sed -e 's,/$,,')

  if (( ! $# )); then
    error "no packages given"
  fi

  if ! [[ -e "$cache_dir/setup.ini" ]]; then
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

  if ! [ -e "$download_file" ] || ! $hash -c <<< "$digest $download_file" &>/dev/null; then
    info "fetch $mirror/$download_dir/$download_file"
    wget -O "$download_file" "$mirror/$download_dir/$download_file" | info
    $hash -c <<< "$digest $download_file" &>/dev/null || exit
  fi

  success "Download ${download_file}"

  # download file is put on Formula
  local pkg_version="${download_file%.tar.xz}"
  mkdir -p "$CREW_FORMULA/$pkg/$pkg_version"
  mv "$cache_dir/$download_dir/$download_file" "$CREW_FORMULA/$pkg/$pkg_version/$download_file"
}


function sha512sum {
  case `uname` in
    Darwin )
      openssl dgst -sha512 "$@" ;;
    * )
      command sha512sum "$@" ;;
  esac
}

