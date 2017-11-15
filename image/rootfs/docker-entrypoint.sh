#!/bin/bash
set -e

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

# see http://stackoverflow.com/a/2705678/433558
sed_escape_lhs() {
  echo "$@" | sed -e 's/[]\/$*.^|[]/\\&/g'
}

sed_escape_rhs() {
  echo "$@" | sed -e 's/[\/&]/\\&/g'
}

function replace_nginx() {
  cd /etc/passenger
  sed -i -e "s/worker_processes [[:digit:]]\+;/worker_processes ${NGINX_WORKER_PROCESSES};/" nginx.conf.erb
  sed -i -e "s/worker_connections [[:digit:]]\+;/worker_connections ${NGINX_WORKER_CONNECTIONS};/" nginx.conf.erb
  sed -i -e "s/client_max_body_size [[:digit:]]\+m;/client_max_body_size ${NGINX_CLIENT_MAX_BODY_SIZE};/" nginx.conf.erb
  local nginx_http_append=$(mktemp)
  trap "{ rm -f $nginx_http_append; }" EXIT
  cat > $nginx_http_append << "EOM"
    sendfile on;
    ### BEGIN your own configuration options ###
EOM
  sed -i -e "/    ### BEGIN your own configuration options ###/r $nginx_http_append" nginx.conf.erb
  local nginx_server_append=$(mktemp)
  trap "{ rm -f $nginx_server_append; }" EXIT
  cat > $nginx_server_append << "EOM"
        #
        location = /favicon.ico {
          log_not_found off;
          access_log off;
        }
        #
        location = /robots.txt {
          allow all;
          log_not_found off;
          access_log off;
        }
        # Deny all attempts to access hidden nginx_server_appends such as .htaccess, .htpasswd, .DS_Store (Mac).
        # Keep logging the requests to parse later (or to pass to firewall utilities such as fail2ban)
        location ~ /\. {
          deny all;
        }
        # Deny access to any nginx_server_appends with a .rb extension in the uploads directory
        # Works in sub-directory installs and also in multisite network
        # Keep logging the requests to parse later (or to pass to firewall utilities such as fail2ban)
        location ~* /(?:uploads|nginx_server_appends)/.*\.rb$ {
          deny all;
        }
        #
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|html|htm)$ {
          expires max;
          log_not_found off;
        }
        ### BEGIN your own configuration options ###
EOM
  sed -i -e "/        ### BEGIN your own configuration options ###/r $nginx_server_append" nginx.conf.erb
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

source /docker-entrypoint-utils.sh
set_debug
echo "Running as `id`"

case "$1" in
  rails|rake|passenger)
    sync_dir /usr/src/redmine ${WEB_ROOT}
    if [[ "x$REDMINE_SYNC_BUNDLES" == "true" ]]; then
      sync_dir /usr/local/bundle.dist /usr/local/bundle
    fi
    sync_dir /redmine-in ${WEB_ROOT}/config skip
    start_redmine
    setup_redmine
    ;;
esac

cd "$WEB_ROOT"
exec "$@"
