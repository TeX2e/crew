#!/bin/bash

function crew-install { # <packages>
  local pkgs=$@
  local pkg
  for pkg in $pkgs
  do
    download $pkg
  done
  # pkg.tar.xz must be deployed
}


function download { # <package>
  local pkg=$1
  local cache_dir=$CREW_CACHE
  local arch_dir=$(uname -m)
  local mirror=$(crew-mirror | sed -e 's,/$,,')

  if (( ! $# )); then
    error "no packages given"
  fi

  if ! [[ -e "$cache_dir/$arch_dir/setup.ini" ]]; then
    error "setup.ini is not found in $cache_dir/$arch_dir/"
  fi
  
  # look for package and save desc file

  awk '$1 == pc' RS='\n\n@ ' FS='\n' pc="$pkg" "$cache_dir/$arch_dir/setup.ini" \
    > "$cache_dir/$arch_dir/desc"

  if [ ! -s "$cache_dir/$arch_dir/desc" ]; then
    error "Unable to locate package $pkg"
  fi

  # download and unpack the bz2 or xz file

  # pick the latest version, which comes first
  set -- $(awk '$1 == "install:"' "$cache_dir/$arch_dir/desc")

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
    wget -O "$download_file" "$mirror/$download_dir/$download_file"
    $hash -c <<< "$digest $download_file" &>/dev/null || exit
  fi

  # decompress
  # xz -cdv "${download_file}" > "${download_file%.xz}"
  # tar -xf "${download_file%.xz}"
  # local download_file_with_version=${download_file%.tar.xz}
  # mkdir -p "$CREW_FORMULA/$pkg"
  # tar tf "$download_file" | gzip > "$CREW_FORMULA/$pkg/$download_file_with_version.lst.gz"

  success "Download ${download_file}"
  # return value
  echo "download to: $cache_dir/$download_dir/$download_file"
}


function sha512sum {
  case `uname` in
    Darwin )
      openssl dgst -sha512 "$@" ;;
    * )
      command sha512sum "$@" ;;
  esac
}

