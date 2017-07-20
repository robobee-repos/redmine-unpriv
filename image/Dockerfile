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
  && gem install bundler -v 1.15.2 \
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
ENV NGINX_CLIENT_MAX_BODY_SIZE 128m

# Install plugins and themes.

ADD rootfs/install-redmine-plugin.sh /install-redmine-plugin.sh
ADD rootfs/install-redmine-theme.sh /install-redmine-theme.sh
ADD rootfs/install-redmine-utils.sh /install-redmine-utils.sh

RUN set -x \
  && chmod +x /install-redmine-plugin.sh \
  && chmod +x /install-redmine-theme.sh \
  && chmod +x /install-redmine-utils.sh \
  && chown -R ${WEB_USER} /usr/src/redmine/public \
  && chown -R ${WEB_USER} /usr/src/redmine/plugins

# Finishing up.

ADD rootfs/docker-entrypoint.sh /docker-entrypoint.sh

RUN set -x \
  && chmod +x /docker-entrypoint.sh

USER ${WEB_USER}

RUN set -x \
  && src="https://github.com/martin-denizet/redmine_custom_css/archive/0.1.6.zip" \
  && hash="48031a1975aca11fede5d17691d299764661bbd5f29a3a6d77a61737d96d1814" \
  && name="redmine_custom_css" \
  && /install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

RUN set -x \
  && src="https://github.com/haru/redmine_theme_changer/releases/download/0.3.0/redmine_theme_changer-0.3.0.zip" \
  && hash="8af1d3346dbd05e6644e243f7d969a21a498b924b0473bcb5c803e400f4ea0a4" \
  && name="redmine_theme_changer" \
  && /install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

RUN set -x \
  && src="https://github.com/paginagmbh/redmine_lightbox2/archive/v0.3.2.zip" \
  && hash="77dcc9cd133221b5fbbc8bd783468038ed1895d744f77412752b1267d4b8d4b1" \
  && name="redmine_lightbox2" \
  && /install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

RUN set -x \
  # https://github.com/peclik/clipboard_image_paste
  && src="https://github.com/peclik/clipboard_image_paste/archive/v1.12.zip" \
  && hash="372cee648645a408616e395ef0dc40be43e0cd5d0786983bfca2be9a0ec7a611" \
  && name="clipboard_image_paste" \
  && /install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

RUN set -x \
  # redmine_issue_templates
  && src="https://github.com/akiko-pusu/redmine_issue_templates/archive/0.1.6.zip" \
  && hash="d5d568aefe8f8e7407cc2e824d13c3903fc82583fd769512668563a5bebdbf57" \
  && name="redmine_issue_templates" \
  && /install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

RUN set -x \
  # https://www.r-labs.org/projects/r-labs/wiki/Wiki_Extensions_en
  && src="https://cloud.muellerpublic.de/s/sJJRQxzg7Z0ODND/download" \
  && hash="978cd0f28a7063f01c0e997972987e841dc6e1be107accac14ec7298c13f87d8" \
  && name="redmine_wiki_extensions" \
  && /install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

RUN set -x \
  # redmine_issue_templates
  && src="https://github.com/akiko-pusu/redmine_issue_templates/archive/0.1.6.zip" \
  && hash="d5d568aefe8f8e7407cc2e824d13c3903fc82583fd769512668563a5bebdbf57" \
  && name="redmine_issue_templates"

RUN set -x \
  # https://github.com/oklas/redmine-color-tasks
  && src="https://github.com/oklas/redmine-color-tasks/archive/5106193e1f442cc4f019c61899aa212d2c5c3c32.zip" \
  && hash="0f15b8677d8ea8790e2ed9d8ce5969246fafb07c03cfbfac5f31cac74fc75d67" \
  && name="redmine-color-tasks" \
  && /install-redmine-theme.sh "$src" "$name" "$hash" downloadOnly

RUN set -x \
  && src="https://github.com/FabriceSalvaire/redmine-improved-theme/archive/63a2381f29a97147e9b7b370bc5b2be8a71f23a6.zip" \
  && hash="602f731af304f432616e076395a6254b8f1d60d748a583b1b4cd57444be97965" \
  && name="redmine-improved-theme" \
  && /install-redmine-theme.sh "$src" "$name" "$hash" downloadOnly

RUN set -x \
  && src="https://github.com/akabekobeko/redmine-theme-minimalflat2/releases/download/v1.3.0/minimalflat2-1.3.0.zip" \
  && hash="8382e93ad58e3b5092ae60f161014230b9bf41129ef3cdb3137f8d0af3dfd05b" \
  && name="redmine-theme-minimalflat2" \
  && /install-redmine-theme.sh "$src" "$name" "$hash" downloadOnly

RUN set -x \
  && src="https://github.com/themondays/Dwarf/archive/bcb66f895db7baa07b16bfc65a00f0853e5e210f.zip" \
  && hash="84be43a3f139774eb2c693c7bc571026e2dfcc4e08697c47096e8059d9995179" \
  && name="dwarf" \
  && /install-redmine-theme.sh "$src" "$name" "$hash" downloadOnly \
  && cd /usr/src/redmine/public/themes \
  && mv dwarf/production/dwarf dwarf-theme \
  && rm -rf dwarf \
  && mv dwarf-theme dwarf

WORKDIR ${WEB_ROOT}

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["passenger", "start", "--nginx-config-template", "/etc/passenger/nginx.conf.erb"]
