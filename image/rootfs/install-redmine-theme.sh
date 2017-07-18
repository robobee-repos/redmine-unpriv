#!/bin/bash
set -xe
source /install-redmine-utils.sh

SRC="$1"; shift
NAME="$1"; shift
HASH="$1"; shift
if [[ "$#" > 0 ]]; then
  INSTALL_MODE="$1"; shift
fi
if [[ "x$INSTALL_MODE" == "xdownloadOnly" ]]; then
  DEST="/usr/src/redmine";
else
  DEST="${WEB_ROOT}"
fi
FILE=$(basename "$SRC")
EXTENSION="${FILE##*.}"
FILE="${NAME}.${EXTENSION}"

function install_zip() {
  cd /tmp
  download_file
  unzip_strip "${FILE}" "$NAME"
  rm "${FILE}"
  mv "$NAME" "${DEST}/public/themes/$NAME"
}

function install_git() {
  cd /tmp
  git clone --depth 1 "$SRC" "$NAME"
  mv "$NAME" "${DEST}/public/themes/$NAME"
}

if [ -d "${DEST}/themes/${NAME}" ]; then
  rm -rf "${DEST}/themes/${NAME}"
fi

case $EXTENSION in
  zip)
  install_zip
  ;;
  git)
  install_git
  ;;
esac

if [[ "x$INSTALL_MODE" == "xdownloadOnly" ]]; then
  exit 0
fi
