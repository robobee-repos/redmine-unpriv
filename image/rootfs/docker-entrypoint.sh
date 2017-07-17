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
  case "$1" in
    rails|rake|passenger)
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
      fi=- 
      
      # remove PID file to enable restarting the container
      rm -f tmp/pids/server.pid
      
      ;;
  esac
}

function replace_nginx() {
  cd /etc/passenger
  sed -i -e "s/worker_processes \d+;/worker_processes ${NGINX_WORKER_PROCESSES};/" nginx.conf.erb
  sed -i -e "s/worker_connections \d+;/worker_connections ${NGINX_WORKER_CONNECTIONS};/" nginx.conf.erb
  sed -i -e "s/client_max_body_size \d+m;/client_max_body_size ${NGINX_CLIENT_MAX_BODY_SIZE};/" nginx.conf.erb
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
  name="redmine_custom_css"
  /install-redmine-plugin.sh "$src" "$name" "$hash"

  src="https://bitbucket.org/haru_iida/redmine_theme_changer/downloads/redmine_theme_changer-0.2.0.zip"
  hash="c4710523982bd417e4cc586e8df02686f89a74cfce8b955e799f04af7aa4c4dd"
  name="redmine_theme_changer"
  /install-redmine-plugin.sh "$src" "$name" "$hash"

  src="https://github.com/paginagmbh/redmine_lightbox2/archive/v0.3.2.zip"
  hash="77dcc9cd133221b5fbbc8bd783468038ed1895d744f77412752b1267d4b8d4b1"
  name="redmine_lightbox2"
  /install-redmine-plugin.sh "$src" "$name" "$hash"

  src="https://bitbucket.org/dkuk/a_common_libs.git"
  name="a_common_libs"
  /install-redmine-plugin.sh "$src" "$name"

  src="https://bitbucket.org/dkuk/global_roles"
  name="global_roles"
  /install-redmine-plugin.sh "$src" "$name"

  src="https://bitbucket.org/dkuk/usability.git"
  name="usability"
  /install-redmine-plugin.sh "$src" "$name"

  src="https://bitbucket.org/dkuk/unread_issues.git"
  name="unread_issues"
  /install-redmine-plugin.sh "$src" "$name"
}

function install_themes() {
  src="https://github.com/oklas/redmine-color-tasks/archive/5106193e1f442cc4f019c61899aa212d2c5c3c32.zip"
  hash="0f15b8677d8ea8790e2ed9d8ce5969246fafb07c03cfbfac5f31cac74fc75d67"
  name="redmine-color-tasks"
  /install-redmine-plugin.sh "$src" "$name" "$hash"

  src="https://github.com/FabriceSalvaire/redmine-improved-theme/archive/63a2381f29a97147e9b7b370bc5b2be8a71f23a6.zip"
  hash="602f731af304f432616e076395a6254b8f1d60d748a583b1b4cd57444be97965"
  name="redmine-improved-theme"
  /install-redmine-plugin.sh "$src" "$name" "$hash"

  src="https://bitbucket.org/dkuk/redmine_alex_skin.git"
  name="redmine_alex_skin"
  /install-redmine-plugin.sh "$src" "$name"
}

cd "$WEB_ROOT"
echo "Running as `id`"
sync_redmine
start_redmine passenger start
setup_redmine
install_plugins
install_themes
exec "$@"
