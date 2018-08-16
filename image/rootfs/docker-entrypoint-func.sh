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

function wait_mysql() {
  while ! MYSQL_PWD=${REDMINE_DB_PASSWORD} \
  mysql -u ${REDMINE_DB_USERNAME} \
  -h ${REDMINE_DB_MYSQL} \
  -P ${REDMINE_DB_PORT} \
  -D ${REDMINE_DB_DATABASE} \
  -e "SELECT 1;"; do
    echo "Wait for ${REDMINE_DB_MYSQL}:${REDMINE_DB_PORT}"
    sleep 3
  done
}

function wait_postgres() {
  while ! PGPASSWORD=${REDMINE_DB_PASSWORD} \
  psql "postgresql://${REDMINE_DB_USERNAME}@${REDMINE_DB_POSTGRES}:${REDMINE_DB_PORT}" -c "SELECT 1;"; do
    echo "Wait for ${REDMINE_DB_POSTGRES}:${REDMINE_DB_PORT}"
    sleep 3
  done
}

function start_redmine() {
  cd "$WEB_ROOT"
  if [ ! -f './config/database.yml' ]; then
    file_env 'REDMINE_DB_MYSQL'
    file_env 'REDMINE_DB_POSTGRES'
    file_env 'REDMINE_DB_SQLSERVER'
    
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
      wait_mysql
    elif [ "$REDMINE_DB_POSTGRES" ]; then
      adapter='postgresql'
      host="$REDMINE_DB_POSTGRES"
      file_env 'REDMINE_DB_PORT' '5432'
      file_env 'REDMINE_DB_USERNAME' "${POSTGRES_ENV_POSTGRES_USER:-postgres}"
      file_env 'REDMINE_DB_PASSWORD' "${POSTGRES_ENV_POSTGRES_PASSWORD}"
      file_env 'REDMINE_DB_DATABASE' "${POSTGRES_ENV_POSTGRES_DB:-${REDMINE_DB_USERNAME:-}}"
      file_env 'REDMINE_DB_ENCODING' 'utf8'
      wait_postgres
    elif [ "$REDMINE_DB_SQLSERVER" ]; then
        adapter='sqlserver'
        host="$REDMINE_DB_SQLSERVER"
        file_env 'REDMINE_DB_PORT' '1433'
        file_env 'REDMINE_DB_USERNAME' ''
        file_env 'REDMINE_DB_PASSWORD' ''
        file_env 'REDMINE_DB_DATABASE' ''
        file_env 'REDMINE_DB_ENCODING' ''
    else
      echo >&2
      echo >&2 'warning: missing REDMINE_DB_MYSQL, REDMINE_DB_POSTGRES, or REDMINE_DB_SQLSERVER environment variables'
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
    else
      # parse the database config to get the database adapter name
      # so we can use the right Gemfile.lock
      adapter="$(
        ruby -e "
          require 'yaml'
          conf = YAML.load_file('./config/database.yml')
          puts conf['$RAILS_ENV']['adapter']
        "
      )"
  fi
  
  # ensure the right database adapter is active in the Gemfile.lock
  cp "Gemfile.lock.${adapter}" Gemfile.lock
  # install additional gems for Gemfile.local and plugins
  bundle check || bundle install --without development test
  
  if [ ! -s config/secrets.yml ]; then
    file_env 'REDMINE_SECRET_KEY_BASE'
    if [ "$REDMINE_SECRET_KEY_BASE" ]; then
      cat > 'config/secrets.yml' <<-YML
        $RAILS_ENV:
          secret_key_base: "$REDMINE_SECRET_KEY_BASE"
YML
    elif [ ! -f /usr/src/redmine/config/initializers/secret_token.rb ]; then
      rake generate_secret_token
    fi
  fi
  if [ "$1" != 'rake' -a -z "$REDMINE_NO_DB_MIGRATE" ]; then
    rake db:migrate
  fi
  
  # https://www.redmine.org/projects/redmine/wiki/RedmineInstall#Step-8-File-system-permissions
  chown -R redmine:redmine files log public/plugin_assets
  # directories 755, files 644:
  chmod -R ugo-x,u+rwX,go+rX,go-w files log tmp public/plugin_assets
      
  if [ "$1" != 'rake' -a -n "$REDMINE_PLUGINS_MIGRATE" ]; then
    rake redmine:plugins:migrate
    rails g piwik_analytics:install -s
  fi

  # remove PID file to enable restarting the container
  rm -f /usr/src/redmine/tmp/pids/server.pid
}

function puma_config() {
  cd "$WEB_ROOT"
  if [[ -f config/config.rb ]]; then
    return
  fi
  cat << EOF > config/config.rb
#!/usr/bin/env puma
environment 'production'
daemonize false
quiet
threads ${PUMA_MIN_THREADS}, ${PUMA_MAX_THREADS}
bind 'tcp://0.0.0.0:3000'
workers ${PUMA_CLUSTER_WORKERS}
preload_app!
on_worker_boot do
   puts 'On worker boot...'
   ActiveSupport.on_load(:active_record) do
    config = ActiveRecord::Base.configurations[Rails.env] || Rails.application.config.database_configuration[Rails.env]
    config['pool'] = ENV['RAILS_MAX_THREADS'] || 5
    ActiveRecord::Base.establish_connection(config)
  end
end
worker_timeout ${PUMA_WORKER_TIMEOUT}
worker_boot_timeout ${PUMA_WORKER_BOOT_TIMEOUT}
activate_control_app 'tcp://0.0.0.0:9293', { no_token: true }
EOF
}

function setup_piwik() {
  cd "$WEB_ROOT"
  cat << EOF > config/piwik.yml
production:
  piwik:
    id_site: ${PIWIK_ID_SITE}
    url: ${PIWIK_URL}
    use_async: ${PIWIK_USE_ASYNC}
    disabled: ${PIWIK_DISABLED}

EOF
  tmp=$(mktemp)
  trap "{ rm -f $tmp; }" EXIT
  cat > $tmp << "EOM"

<%= piwik_tracking_tag %>

EOM

  file=app/views/layouts/base.html.erb
  sed -i -e "/<%= call_hook :view_layouts_base_body_bottom %>/r $tmp" /usr/src/redmine/$file
}
