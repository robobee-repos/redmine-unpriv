#!/bin/bash
set -e

source /docker-entrypoint-utils.sh
source /docker-entrypoint-func.sh
set_debug
echo "Running as `id`"

case "$1" in
  puma|rails|rake|passenger)
    if is_sync_enabled && check_update_time ${WEB_ROOT}; then
      sync_dir /usr/src/redmine ${WEB_ROOT}
      update_update_time ${WEB_ROOT}
    fi
    bundle config gemfile `realpath Gemfile`
    sync_dir /redmine-in ${WEB_ROOT}/config skip
    puma_config
    setup_piwik
    start_redmine
    ;;
esac

cd "$WEB_ROOT"
exec "$@"
