#!/bin/bash
set -xe
source /install-redmine-utils.sh

SRC="$1"; shift
HASH="$1"; shift
NAME="$1"; shift
FILE=$(basename "$SRC")
EXTENSION="${FILE##*.}"
FILE="${NAME}.${EXTENSION}"

function install_zip() {
  cd /tmp
  download_file
  unzip_strip "${FILE}" "$NAME"
  mv "$NAME" "${WEB_ROOT}/public/themes/$NAME"
}

function install_git() {
  cd /tmp
  git clone --depth 1 "$SRC" "$NAME"
  mv "$NAME" "${WEB_ROOT}/public/themes/$NAME"
}

case $EXTENSION in
  zip)
  HASH="$1"; shift
  install_zip
  ;;
  git)
  install_git
  ;;
esac

