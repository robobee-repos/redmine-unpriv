FROM redmine:4.0.2
LABEL maintainer "Erwin Mueller <erwin.mueller@deventm.com>"

ARG APT_CACHE

RUN set -x \
  # Optional add proxy entries for apt.
  && if [ -n "${APT_CACHE}" ]; then \
  echo Acquire::ftp::Proxy \"$APT_CACHE\"; >> /etc/apt/apt.conf.d/08proxy;\
  echo Acquire::http::Proxy \"$APT_CACHE\"; >> /etc/apt/apt.conf.d/08proxy;\
  echo Acquire::https::Proxy \"$APT_CACHE\"; >> /etc/apt/apt.conf.d/08proxy;\
  fi

ENV WEB_ROOT="/var/www/html" \
  WEB_USER="redmine" \
  SRC_DIR="/usr/src/redmine"

# Need to install additional gems and packages

RUN set -eux; \
  apt-get update \
  && mkdir -p /usr/share/man/man1 \
  && mkdir -p /usr/share/man/man7 \
  && apt-get install -y \
    rsync \
    unzip \
    coreutils \
    curl \
  ; \
  apt-get install -y --no-install-recommends \
    mariadb-client \
    postgresql-client \
  ; \
  savedAptMark="$(apt-mark showmanual)"; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    dpkg-dev \
    gcc \
    libmagickcore-dev \
    libmagickwand-dev \
    libmariadbclient-dev \
    libpq-dev \
    libsqlite3-dev \
    make \
    patch \
    \
# tiny_tds 1.0.x requires OpenSSL 1.0
# see https://github.com/rails-sqlserver/tiny_tds/commit/3269dd3bcfbe4201ab51aa2870a6aaddfcbdfa5d (tiny_tds 1.2.x+ is required for OpenSSL 1.1 support)
    libssl1.0-dev \
  ; \
  rm -rf /var/lib/apt/lists/*; \
  \
  sed -ie "s/gem 'puma', '~> 3.7'/gem 'puma', '= 3.12.0'/" Gemfile; \
  echo 'gem "puma", "= 3.12.0"' >> Gemfile; \
  echo 'gem "piwik_analytics", "~> 1.0.2"' >> Gemfile; \
  echo 'gem "temple", "~> 0.8.0"' >> Gemfile; \
  echo 'gem "dalli", "~> 2.7.9"' >> Gemfile; \
# https://github.com/travis-ci/travis-ci/issues/9391 (can't let "tiny_tds" download FreeTDS for us because FTP)
# https://github.com/rails-sqlserver/tiny_tds/pull/384 (newer version uses HTTP!)
# https://github.com/rails-sqlserver/tiny_tds/pull/345 (... but then can't download it for us)
# http://www.freetds.org/files/stable/?C=M;O=D
# (if/when we update to Debian Buster and thus get FreeTDS newer than 0.95 in the distro, we can switch back to simply installing "freetds-dev" from Debian)
  wget -O freetds.tar.bz2 'http://www.freetds.org/files/stable/freetds-1.00.91.tar.bz2'; \
  echo '8d71f9f29be0fe0637e443dd3807b3fd *freetds.tar.bz2' | md5sum -c -; \
  mkdir freetds; \
  tar -xf freetds.tar.bz2 -C freetds --strip-components=1; \
  rm freetds.tar.bz2; \
  ( cd freetds && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" && ./configure --build="$gnuArch" --enable-silent-rules && make -j "$(nproc)" && make -C src install && make -C include install ); \
  rm -rf freetds; \
  gosu redmine gem install json -v '2.2.0'; \
  gosu redmine bundle config build.tiny_tds --enable-system-freetds; \
  gosu redmine bundle install --without development test; \
  for adapter in mysql2 postgresql sqlserver sqlite3; do \
    echo "$RAILS_ENV:" > ./config/database.yml; \
    echo "  adapter: $adapter" >> ./config/database.yml; \
    gosu redmine bundle install --without development test; \
    cp Gemfile.lock "Gemfile.lock.${adapter}"; \
  done; \
  rm ./config/database.yml; \
# fix permissions for running as an arbitrary user
  chmod -R ugo=rwX Gemfile.lock "$GEM_HOME"; \
  rm -rf ~redmine/.bundle; \
  \
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
  apt-mark auto '.*' > /dev/null; \
  [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
  find /usr/local -type f -executable -exec ldd '{}' ';' \
    | awk '/=>/ { print $(NF-1) }' \
    | sort -u \
    | grep -v '^/usr/local/' \
    | xargs -r dpkg-query --search \
    | cut -d: -f1 \
    | sort -u \
    | xargs -r apt-mark manual \
  ; \
apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

RUN set -x \
  && mkdir -p $WEB_ROOT \
  && chown -R ${WEB_USER}.${WEB_USER} $WEB_ROOT \
  && chown -R ${WEB_USER} /usr/local/bundle \
  && mkdir -p /home/redmine \
  && chown -R ${WEB_USER}.${WEB_USER} /home/redmine \
  && mkdir -p /var/run/puma \
  && chown -R ${WEB_USER}.${WEB_USER} /var/run/puma

ADD rootfs/ /

RUN set -x \
  && chmod +x /*.sh

RUN set -x \
  && export DEBUG=false \
  && /install_plugins.sh

RUN set -x \
  && export DEBUG=false \
  && /install_themes.sh

ENV DEBUG="false" \
  SYNC_ENABLED="true" \
  SYNC_TIME_S="300" \
  BUNDLE_GEMFILE=/var/www/html/Gemfile \
  PUMA_MIN_THREADS=8 \
  PUMA_MAX_THREADS=16 \
  PUMA_CLUSTER_WORKERS=2 \
  PUMA_WORKER_TIMEOUT=120 \
  PUMA_WORKER_BOOT_TIMEOUT=120 \
  PIWIK_ID_SITE=1 \
  PIWIK_URL=localhost \
  PIWIK_USE_ASYNC=false \
  PIWIK_DISABLED=true

# Puma Control App TCP Socket
EXPOSE 9293

VOLUME ["/var/www/html"]

USER ${WEB_USER}

WORKDIR ${WEB_ROOT}

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["puma", "-C", "./config/config.rb"]
