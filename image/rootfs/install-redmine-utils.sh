#!/bin/bash
set -e
source /docker-entrypoint-utils.sh
set_debug
UNZIP_QUIETLY="-q"
if [[ "x$DEBUG" == "xtrue" ]]; then
  UNZIP_QUIETLY=""
fi

function download_file() {
  cd /tmp
  wget -O "${FILE}" -nv "${SRC}"
  echo "${HASH} ${FILE}" | sha256sum -c
}

function unzip_strip() (
    local zip=$1
    local dest=${2:-.}
    local temp=$(mktemp -d)
    unzip $UNZIP_QUIETLY -d "$temp" "$zip"
    if [[ -d "${temp}/__MACOSX" ]]; then
        rm -rf "${temp}/__MACOSX"
    fi
    mkdir -p "$dest"
    shopt -s dotglob
    local f=("$temp"/*)
    if (( ${#f[@]} == 1 )) && [[ -d "${f[0]}" ]] ; then
        mv "$temp"/*/* "$dest"
    else
        mv "$temp"/* "$dest"
    fi
    rmdir "$temp"/* "$temp"
)
