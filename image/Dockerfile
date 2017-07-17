FROM redmine:3.4.1-passenger
LABEL maintainer "Erwin Mueller <erwin.mueller@deventm.com>"

ARG APT_CACHE
ENV WEB_ROOT /var/www/html
ENV WEB_USER redmine
ENV SRC_DIR /usr/src/redmine

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
  && rm -rf /var/lib/apt/lists/* \
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

ENV NGINX_WORKER_PROCESSES 2
ENV NGINX_WORKER_CONNECTIONS 4096
ENV NGINX_CLIENT_MAX_BODY_SIZE 1g

# Finishing up.

ADD rootfs/docker-entrypoint.sh /docker-entrypoint.sh
ADD rootfs/install-redmine-plugin.sh /install-redmine-plugin.sh
ADD rootfs/install-redmine-theme.sh /install-redmine-theme.sh
ADD rootfs/install-redmine-utils.sh /install-redmine-utils.sh

RUN set -x \
  && chmod +x /docker-entrypoint.sh \
  && chmod +x /install-redmine-plugin.sh \
  && chmod +x /install-redmine-theme.sh \
  && chmod +x /install-redmine-utils.sh

USER ${WEB_USER}

WORKDIR ${WEB_ROOT}

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["passenger", "start", "--nginx-config-template", "/etc/passenger/nginx.conf.erb"]
