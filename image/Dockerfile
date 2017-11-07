FROM redmine:3.4.3-passenger
LABEL maintainer "Erwin Mueller <erwin.mueller@deventm.com>"

ARG APT_CACHE

ENV WEB_ROOT="/var/www/html" \
  WEB_USER="redmine" \
  SRC_DIR="/usr/src/redmine"

RUN set -x \
  # Optional add proxy entries for apt.
  && if [ -n "${APT_CACHE}" ]; then \
  echo Acquire::ftp::Proxy \"$APT_CACHE\"; >> /etc/apt/apt.conf.d/08proxy;\
  echo Acquire::http::Proxy \"$APT_CACHE\"; >> /etc/apt/apt.conf.d/08proxy;\
  echo Acquire::https::Proxy \"$APT_CACHE\"; >> /etc/apt/apt.conf.d/08proxy;\
  fi

RUN set -x \
  && DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y \
    rsync \
    unzip \
    coreutils \
    curl \
  && rm -rf /var/lib/apt/lists/* \
  && gem install bundler -v 1.15.4 \
  && gem install yard \
  && chmod o+rwX /var/log

# redmine

RUN set -x \
  && mkdir -p $WEB_ROOT \
  && chown -R ${WEB_USER}.${WEB_USER} $SRC_DIR \
  && chown -R ${WEB_USER}.${WEB_USER} $WEB_ROOT \
  && chown -R ${WEB_USER} /usr/local/bundle \
  && mkdir -p /etc/passenger \
  && chown -R ${WEB_USER} /etc/passenger \
  && mkdir -p /passenger-in \
  && chown -R ${WEB_USER} /passenger-in

# passender

ENV NGINX_WORKER_PROCESSES="2" \
  NGINX_WORKER_CONNECTIONS="4096" \
  NGINX_CLIENT_MAX_BODY_SIZE="128m"

# Install plugins and themes.

ADD rootfs/ /

RUN set -x \
  && chmod +x /*.sh

RUN set -x \
  && /install_plugins.sh

RUN set -x \
  && /install_themes.sh

RUN set -x \
&& curl -sL https://deb.nodesource.com/setup_8.x | bash - \
&& apt-get install -y nodejs build-essential \
&& rm -rf /var/lib/apt/lists/* \
# https://github.com/jgraichen/redmine_dashboard
&& src="https://github.com/jgraichen/redmine_dashboard/archive/a528531580b7d4c4b1dc465a8e65e9068aeb77b2.zip" \
&& hash="0eaf381cbef92297939355f9ffa56eaac181a89083e569d4ef4e675d6474c38c" \
&& name="redmine_dashboard" \
&& /install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

RUN set -x \
  && mkdir -p /home/redmine \
  && chown ${WEB_USER}.${WEB_USER} -R /home/redmine

# Finishing up.

VOLUME /var/www/html

USER ${WEB_USER}

WORKDIR ${WEB_ROOT}

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["passenger", "start", "--nginx-config-template", "/etc/passenger/nginx.conf.erb"]
