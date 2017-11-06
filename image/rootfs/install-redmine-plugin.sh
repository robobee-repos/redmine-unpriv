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
  mv "${NAME}" "${DEST}/plugins/${NAME}"
}

function install_gz() {
  cd /tmp
  download_file
  tar xf "${FILE}"
  rm "${FILE}"
  mv "${NAME}" "${DEST}/plugins/${NAME}"
}

function install_git() {
  cd /tmp
  git clone --depth 1 "$SRC" "$NAME"
  mv "$NAME" "${DEST}/plugins/${NAME}"
}

if [ -d "${DEST}/plugins/${NAME}" ]; then
  rm -rf "${DEST}/plugins/${NAME}"
fi

case $EXTENSION in
  zip?dl=0)
  install_zip
  ;;
  zip)
  install_zip
  ;;
  git)
  install_git
  ;;
  gz)
  install_gz
  ;;
  *)
  install_zip
  ;;
esac

if [[ "x$INSTALL_MODE" == "xdownloadOnly" ]]; then
  exit 0
fi

cd "${WEB_ROOT}"
bundle install
rake redmine:plugins:migrate RAILS_ENV=production
