#!/bin/bash
set -e

BASH_CMD="bash"
RSYNC_CMD="rsync"

function check_files_exists() {
  ls $1 1> /dev/null 2>&1
}

function copy_file() {
  file="$1"; shift
  dir="$1"; shift
  mod="$1"; shift
  if [ -e "$file" ]; then
    mkdir -p "$dir"
    cp "$file" "$dir/$file"
    chmod $mod "$dir/$file"
  fi
}

function copy_files() {
  dir="$1"; shift
  target="$1"; shift
  files="$1"; shift
  if [ ! -d "${dir}" ]; then
    return
  fi
  cd "${dir}"
  if ! check_files_exists "$files"; then
    return
  fi
  $RSYNC_CMD -Lv ${dir}/$files $target/
}

function sync_dir() {
  dir="$1"; shift
  target="$1"; shift
  skip=""
  if [[ $# -gt 0 ]]; then
    skip="$1"; shift
  fi
  if [ ! -d "${dir}" ]; then
    if [[ $skip != "skip" ]]; then
      echo "${dir} does not exists or is not a directory."
      return 1
    else
      return 0
    fi
  fi
  if [ ! -d "${target}" ]; then
    if [[ $skip != "skip" ]]; then
      echo "${target} does not exists or is not a directory."
      return 1
    else
      return 0
    fi
  fi
  cd "${target}"
  $RSYNC_CMD -rlDc ${dir}/. .
}

function do_sed() {
  ## TEMP File
  TFILE=`mktemp --tmpdir tfile.XXXXX`
  trap "rm -f $TFILE" EXIT

  file="$1"; shift
  search="$1"; shift
  replace="$1"; shift
  sed -r -e "s/^${search}.*/${replace}/g" $file > $TFILE
  cat $TFILE > $file
}

function do_sed_group() {
  ## TEMP File
  TFILE=`mktemp --tmpdir tfile.XXXXX`
  trap "rm -f $TFILE" EXIT

  file="$1"; shift
  search="$1"; shift
  replace="$1"; shift
  sed -r -e "s|^(${search}).*|${replace}|g" $file > $TFILE
  cat $TFILE > $file
}

function set_debug() {
  if [[ "$DEBUG" == "true" ]]; then
    set -x
    BASH_CMD="bash -x"
    RSYNC_CMD="rsync -v"
  fi
}

function is_sync_enabled() {
  if [[ "$SYNC_ENABLED" == "true" ]]; then
    return 0
  else
    return 1
  fi
}

function check_update_time() {
  dataDir="$1"; shift
  cd $dataDir
  if [[ -f ".last_update" ]]; then
    last_update=$(cat .last_update)
    current_time=$(date +%s)
    time_diff=$((current_time-last_update))
    if [[ $time_diff -gt $SYNC_TIME_S ]]; then
      return 0
    else
      return 1
    fi
  else
    return 0
  fi
}

function update_update_time() {
  dataDir="$1"; shift
  cd $dataDir
  echo -n "`date +%s`" > .last_update
}
