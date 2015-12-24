#!/bin/bash

function crew-update {
  if find-workspace; then
    get-setup-file
  fi
}

function crew-download {
  local pkg digest digactual
  local cache_dir=$(crew-cache-dir)
  local arch_dir=$(uname -m)
  local mirror=$(crew-mirror | sed -e 's,/$,,')
  local pkg=$1

  if (( ! $# )); then
    error "no packages given"
  fi
  
  # look for package and save desc file

  awk '$1 == pc' RS='\n\n@ ' FS='\n' pc="$pkg" "$cache_dir/$arch_dir/setup.ini" > "$cache_dir/$arch_dir/desc"
  if [ ! -s "$cache_dir/$arch_dir/desc" ]; then
    echo Unable to locate package $pkg
    exit 1
  fi

  # download and unpack the bz2 or xz file

  # pick the latest version, which comes first
  set -- $(awk '$1 == "install:"' "$cache_dir/$arch_dir/desc")

  if (( ! $# )); then
    echo 'Could not find "install" in package description: obsolete package?'
    exit 1
  fi

  local download_dir=$(dirname $2)
  local download_file=$(basename $2)
  

  # check the md5
  digest=$4
  case ${#digest} in
   32) hash=md5sum    ;;
  128) hash=sha512sum ;;
  esac
  
  mkdir -p "$cache_dir/$download_dir"
  cd "$cache_dir/$download_dir"

  if ! [ -e "$download_file" ] || ! $hash -c <<< "$digest $download_file" &>/dev/null; then
    echo "fetch $mirror/$download_dir/$download_file"
    wget -O "$download_file" "$mirror/$download_dir/$download_file"
    $hash -c <<< "$digest $download_file" || exit
  fi

  mkdir -p "$CREW_FORMULA/$pkg"
  tar tf "$download_file" | gzip > "$CREW_FORMULA/$pkg/$pkg.lst.gz"
  echo "download file is put on $CREW_FORMULA/$pkg/$pkg.lst.gz"

  # cd ~-
  # mv "$cache_dir/desc" "$cache/$mirrordir/$download_dir"
  # echo "$download_dir $download_file" > /tmp/dwn
}


function sha512sum {
  case `uname` in
    Darwin )
      openssl dgst -sha512 "$@" ;;
    * )
      command sha512sum "$@" ;;
  esac
}

