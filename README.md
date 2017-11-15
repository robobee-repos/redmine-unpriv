# Redmine

## Description

It uses the official [Redmine image](https://hub.docker.com/_/redmine/) as the base. Enhances the base in the following ways:

- runs [Phusion Passenger](https://www.phusionpassenger.com/) as a non-privileged user;
- accepts input configuration files to override the Redmine and Passenger configuration, allowing for [Kubernetes config maps](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#add-configmap-data-to-a-volume);
- includes additional plugins and themes;

## Environment Parameters

To configure the database backend see the official [Redmine image](https://hub.docker.com/_/redmine/).

| Variable | Default | Description |
| ------------- | ------------- | ----- |
| DEBUG  |  | Set to `true` for additional debug output. |
| NGINX_WORKER_PROCESSES | 2 | worker_processes |
| NGINX_WORKER_CONNECTIONS | 4096 | worker_connections |
| NGINX_CLIENT_MAX_BODY_SIZE | 128m | client_max_body_size |
| REDMINE_SYNC_BUNDLES | `true` | If the bundles directory `/usr/local/bundle` is a persistent volume then the variable determines if the bundled `/usr/local/bundle.dist` should be syncted to the volume. Set to `false` to skip the synchronization. This can be used to bundle all required bundles in the docker image. |

## Exposed Ports

| Port | Description |
| ------------- | ----- |
| 3000  | http |

## Directories

| Path | Description |
| ------------- | ----- |
| /var/www/html  | www-root directory. |
| /usr/local/bundle | Bundles directory. |

## Input Configration

| Source | Destination |
| ------------- | ------------- |
| /passenger-in/nginx.conf.erb | /etc/passenger/nginx.conf.erb |
| /redmine-in/* | /var/www/html/config/ |

## Plugins

Not all plugins are working with a particular Redmine version. Extended testing is always required to make sure that a plugin works. Those plugins are tested with the packaged Redmine version.

| Plugin | URL |
| --- | --- |
| [redmine_custom_css](https://github.com/martin-denizet/redmine_custom_css) | https://github.com/martin-denizet/redmine_custom_css/archive/0.1.6.zip |
| [redmine_theme_changer](https://github.com/haru/redmine_theme_changer) | https://github.com/haru/redmine_theme_changer/releases/download/0.3.1/redmine_theme_changer-0.3.1.zip |
| [redmine_lightbox2](https://github.com/paginagmbh/redmine_lightbox2) | https://github.com/paginagmbh/redmine_lightbox2/archive/v0.4.3.zip |
| [clipboard_image_paste](https://github.com/peclik/clipboard_image_paste) | https://github.com/peclik/clipboard_image_paste/archive/v1.12.zip |
| [Wiki_Extensions_en](https://www.r-labs.org/projects/r-labs/wiki/Wiki_Extensions_en) | https://www.dropbox.com/s/4ffd2o0a2sxcfrm/redmine_wiki_extensions-0.8.0.zip |
| [redmine_issue_templates](https://github.com/akiko-pusu/redmine_issue_templates) | https://github.com/akiko-pusu/redmine_issue_templates/archive/0.1.8.zip |
| [redmine_dashboard](https://github.com/jgraichen/redmine_dashboard) | https://github.com/jgraichen/redmine_dashboard/releases/download/v2.7.1/redmine_dashboard-v2.7.1.tar.gz |

## Themes

Not all themes are working with a particular Redmine version. Extended testing is always required to make sure that a plugin works. Those themes are tested with the packaged Redmine version.

| Plugin | URL |
| --- | --- |
| [redmine-color-tasks](https://github.com/oklas/redmine-color-tasks) | https://github.com/oklas/redmine-color-tasks/archive/5106193e1f442cc4f019c61899aa212d2c5c3c32.zip |
| [redmine-improved-theme](https://github.com/FabriceSalvaire/redmine-improved-theme) | https://github.com/FabriceSalvaire/redmine-improved-theme/archive/15bc4d0bc76d89ea2f81bc49ebe5cf5fc2b2974e.zip |
| [redmine-theme-minimalflat2](https://github.com/akabekobeko/redmine-theme-minimalflat2) | https://github.com/akabekobeko/redmine-theme-minimalflat2/releases/download/v1.3.4/minimalflat2-1.3.4.zip |
| [Dwarf](https://github.com/themondays/Dwarf) | https://github.com/themondays/Dwarf/archive/bcb66f895db7baa07b16bfc65a00f0853e5e210f.zip |
| [devent-Dwarf](https://github.com/devent/Dwarf) | https://github.com/devent/Dwarf/archive/4a6654822a8d092e1c5e0a8c4154a18079248853.zip |

## Test

The docker-compose file `test.yaml` can be used to startup MySQL and the Redmine base containers. Redmine can be then accessed from `localhost:8080`.
```
docker-compose -f test.yaml up
```

## License

Redmine is licensed under the [GNU General Public License v2](http://www.redmine.org/) license.

This Docker image is licensed under the [MIT](https://opensource.org/licenses/MIT) license.

Copyright 2017 Erwin Müller

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
