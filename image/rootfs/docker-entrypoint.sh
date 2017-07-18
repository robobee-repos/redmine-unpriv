#!/bin/bash
set -xe

function check_files_exists() {
  ls "$1" 1> /dev/null 2>&1
}

function copy_file() {
  file="$1"; shift
  dir="$1"; shift
  mod="$1"; shift
  if [ -e "$file" ]; then
    cp "$file" $dir/"$file"
    chmod $mod $dir/"$file"
  fi
}

function sync_redmine() {
  cd "$WEB_ROOT"
  rsync -rlD -u /usr/src/redmine/. .
}

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
function file_env() {
    local var="$1"
    local fileVar="${var}_FILE"
    local def="${2:-}"
    if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
      echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
      exit 1
    fi
    local val="$def"
    if [ "${!var:-}" ]; then
      val="${!var}"
    elif [ "${!fileVar:-}" ]; then
      val="$(< "${!fileVar}")"
    fi
    export "$var"="$val"
    unset "$fileVar"
}


function start_redmine() {
  cd "$WEB_ROOT"
  if [ ! -f './config/database.yml' ]; then
    file_env 'REDMINE_DB_MYSQL'
    file_env 'REDMINE_DB_POSTGRES'
    
    if [ "$MYSQL_PORT_3306_TCP" ] && [ -z "$REDMINE_DB_MYSQL" ]; then
      export REDMINE_DB_MYSQL='mysql'
    elif [ "$POSTGRES_PORT_5432_TCP" ] && [ -z "$REDMINE_DB_POSTGRES" ]; then
      export REDMINE_DB_POSTGRES='postgres'
    fi
    
    if [ "$REDMINE_DB_MYSQL" ]; then
      adapter='mysql2'
      host="$REDMINE_DB_MYSQL"
      file_env 'REDMINE_DB_PORT' '3306'
      file_env 'REDMINE_DB_USERNAME' "${MYSQL_ENV_MYSQL_USER:-root}"
      file_env 'REDMINE_DB_PASSWORD' "${MYSQL_ENV_MYSQL_PASSWORD:-${MYSQL_ENV_MYSQL_ROOT_PASSWORD:-}}"
      file_env 'REDMINE_DB_DATABASE' "${MYSQL_ENV_MYSQL_DATABASE:-${MYSQL_ENV_MYSQL_USER:-redmine}}"
      file_env 'REDMINE_DB_ENCODING' ''
    elif [ "$REDMINE_DB_POSTGRES" ]; then
      adapter='postgresql'
      host="$REDMINE_DB_POSTGRES"
      file_env 'REDMINE_DB_PORT' '5432'
      file_env 'REDMINE_DB_USERNAME' "${POSTGRES_ENV_POSTGRES_USER:-postgres}"
      file_env 'REDMINE_DB_PASSWORD' "${POSTGRES_ENV_POSTGRES_PASSWORD}"
      file_env 'REDMINE_DB_DATABASE' "${POSTGRES_ENV_POSTGRES_DB:-${REDMINE_DB_USERNAME:-}}"
      file_env 'REDMINE_DB_ENCODING' 'utf8'
    else
      echo >&2
      echo >&2 'warning: missing REDMINE_DB_MYSQL or REDMINE_DB_POSTGRES environment variables'
      echo >&2
      echo >&2 '*** Using sqlite3 as fallback. ***'
      echo >&2
      
      adapter='sqlite3'
      host='localhost'
      file_env 'REDMINE_DB_PORT' ''
      file_env 'REDMINE_DB_USERNAME' 'redmine'
      file_env 'REDMINE_DB_PASSWORD' ''
      file_env 'REDMINE_DB_DATABASE' 'sqlite/redmine.db'
      file_env 'REDMINE_DB_ENCODING' 'utf8'
      
      mkdir -p "$(dirname "$REDMINE_DB_DATABASE")"
      chown -R redmine:redmine "$(dirname "$REDMINE_DB_DATABASE")"
    fi
    
    REDMINE_DB_ADAPTER="$adapter"
    REDMINE_DB_HOST="$host"
    echo "$RAILS_ENV:" > config/database.yml
    for var in \
      adapter \
      host \
      port \
      username \
      password \
      database \
      encoding \
    ; do
      env="REDMINE_DB_${var^^}"
      val="${!env}"
      [ -n "$val" ] || continue
      echo "  $var: \"$val\"" >> config/database.yml
    done
  fi
  
  # ensure the right database adapter is active in the Gemfile.lock
  bundle install --without development test
  
  if [ ! -s config/secrets.yml ]; then
    file_env 'REDMINE_SECRET_KEY_BASE'
    if [ "$REDMINE_SECRET_KEY_BASE" ]; then
      cat > 'config/secrets.yml' <<-YML
        $RAILS_ENV:
          secret_key_base: "$REDMINE_SECRET_KEY_BASE"
YML
    elif [ ! -f config/initializers/secret_token.rb ]; then
      rake generate_secret_token
    fi
  fi
  if [ "$1" != 'rake' -a -z "$REDMINE_NO_DB_MIGRATE" ]; then
    rake db:migrate
      fi
  
  # remove PID file to enable restarting the container
  rm -f tmp/pids/server.pid
  # https://www.redmine.org/projects/redmine/wiki/RedmineInstall#Step-8-File-system-permissions
  chown -R redmine:redmine files log public/plugin_assets
  chmod -R 755 files log tmp public/plugin_assets
      
  if [ "$1" != 'rake' -a -n "$REDMINE_PLUGINS_MIGRATE" ]; then
  rake redmine:plugins:migrate
  fi
}

function replace_nginx() {
  cd /etc/passenger
  sed -i -e "s/worker_processes [[:digit:]]\+;/worker_processes ${NGINX_WORKER_PROCESSES};/" nginx.conf.erb
  sed -i -e "s/worker_connections [[:digit:]]\+;/worker_connections ${NGINX_WORKER_CONNECTIONS};/" nginx.conf.erb
  sed -i -e "s/client_max_body_size [[:digit:]]\+m;/client_max_body_size ${NGINX_CLIENT_MAX_BODY_SIZE};/" nginx.conf.erb
}

function setup_redmine() {
  cd /etc/passenger
  if [ -e /passenger-in/nginx.conf.erb ]; then
    cp /passenger-in/nginx.conf.erb .
  fi
  if [ ! -e nginx.conf.erb ]; then
    cp $(passenger-config about resourcesdir)/templates/standalone/config.erb nginx.conf.erb
    replace_nginx
  fi
  echo "Used nginx.conf.erb:"
  cat nginx.conf.erb
}

function install_plugins() {
  src="https://github.com/martin-denizet/redmine_custom_css/archive/0.1.6.zip"
  hash="48031a1975aca11fede5d17691d299764661bbd5f29a3a6d77a61737d96d1814"
  name="custom_css"
  /install-redmine-plugin.sh "$src" "$name" "$hash"

  src="https://github.com/haru/redmine_theme_changer/releases/download/0.3.0/redmine_theme_changer-0.3.0.zip"
  hash="8af1d3346dbd05e6644e243f7d969a21a498b924b0473bcb5c803e400f4ea0a4"
  name="redmine_theme_changer"
  /install-redmine-plugin.sh "$src" "$name" "$hash"

  src="https://github.com/paginagmbh/redmine_lightbox2/archive/v0.3.2.zip"
  hash="77dcc9cd133221b5fbbc8bd783468038ed1895d744f77412752b1267d4b8d4b1"
  name="lightbox2"
  /install-redmine-plugin.sh "$src" "$name" "$hash"

  # https://github.com/peclik/clipboard_image_paste
  src="https://github.com/peclik/clipboard_image_paste/archive/v1.12.zip"
  hash="372cee648645a408616e395ef0dc40be43e0cd5d0786983bfca2be9a0ec7a611"
  name="clipboard_image_paste"
  /install-redmine-plugin.sh "$src" "$name" "$hash"

  # https://www.r-labs.org/projects/r-labs/wiki/Wiki_Extensions_en
  #src="https://bitbucket.org/haru_iida/redmine_wiki_extensions/downloads/redmine_wiki_extensions-0.8.0.zip"
  #hash="978cd0f28a7063f01c0e997972987e841dc6e1be107accac14ec7298c13f87d8"
  #name="wiki_extensions"
  #/install-redmine-plugin.sh "$src" "$name" "$hash"

  # https://www.r-labs.org/projects/issue-template
  src="https://github.com/akiko-pusu/redmine_issue_templates/archive/0.1.6.zip"
  hash="d5d568aefe8f8e7407cc2e824d13c3903fc82583fd769512668563a5bebdbf57"
  name="issue_templates"
  /install-redmine-plugin.sh "$src" "$name" "$hash"

  src="https://github.com/bradbeattie/redmine-graphs-plugin/archive/3d44b4f44295b22ec4ba50e0ca1ff7af44da7379.zip"
  hash="670e1856a1978c1fcc76be54b6e5106cb0b09033f787d4c2c8c6bb53e8f762df"
  name="graphs"
  /install-redmine-plugin.sh "$src" "$name" "$hash"
}

function install_themes() {
  return
}

echo "Running as `id`"

case "$1" in
  rails|rake|passenger)
    sync_redmine
    start_redmine
    setup_redmine
    install_plugins
    install_themes
    ;;
esac

cd "$WEB_ROOT"
exec "$@"
