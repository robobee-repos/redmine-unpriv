# Redmine Puma

## Description

It uses the official [Redmine image](https://hub.docker.com/_/redmine/) as the base. Enhances the base in the following ways:

- runs [Puma](http://puma.io/) as a non-privileged user;
- accepts input configuration files to override the Redmine and Puma configuration, allowing for [Kubernetes config maps](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#add-configmap-data-to-a-volume);
- includes additional plugins and themes;
- includes [piwik_analytics](https://github.com/berkes/piwik_analytics);

## Updating

The files in `WEB_ROOT` are updated with `rsync` from the docker image.
To avoid endless a loop of a restarting container a timeout for updating
can be set in the variables `UPDATE_TIME_S`. No `rsync` will be called if
the restart time was less than this timeout. While `rsync` should not write
files that do not need to be updated, `rsync` is still making read requests.

## Environment Parameters

To configure the database backend see the official [Redmine image](https://hub.docker.com/_/redmine/).

| Variable | Default | Description |
| ------------- | ------------- | ----- |
| `SYNC_ENABLED`  | `true` | Set to `false` to deactivate the application will be done. |
| `SYNC_TIME_S`  | `300` | Set to the seconds that will be waited before a full update of the application will be done. |
| `DEBUG`  |  | Set to `true` for additional debug output. |
| `PUMA_MIN_THREADS` | `8` | Minimum number of threads. See the Puma [documentation](https://github.com/puma/puma/blob/master/examples/config.rb) for a detailed description. |
| `PUMA_MAX_THREADS` | `16` | Maximum number of threads. |
| `PUMA_CLUSTER_WORKERS` | `2` | Puma worker processes. |
| `PUMA_WORKER_TIMEOUT` | `120` | `worker_timeout` |
| `PUMA_WORKER_BOOT_TIMEOUT` | `120` | `worker_boot_timeout` |
| `PIWIK_ID_SITE` | `1` | |
| `PIWIK_URL` | `localhost`  | |
| `PIWIK_USE_ASYNC` | `false` | |
| `PIWIK_DISABLED` | `true` | |

## Exposed Ports

| Port | Description |
| ------------- | ----- |
| 3000  | http |
| 9293  | Puma control app TCP socket. |

## Input Configration

| Source | Destination |
| ------------- | ------------- |
| /redmine-in/* | /var/www/html/config/ |

# Redmine

## Directories

| Path | Description |
| ------------- | ----- |
| /var/www/html  | www-root directory. |
| /usr/local/bundle | Bundles directory. |

## Plugins

Not all plugins are working with a particular Redmine version. Extended testing is always required to make sure that a plugin works. Those plugins are tested with the packaged Redmine version.

| Plugin | Version |
| --- | --- |
| [redmine_custom_css](https://github.com/martin-denizet/redmine_custom_css) | 0.1.7 |
| [redmine_theme_changer](https://github.com/haru/redmine_theme_changer) | 0.4.0 |
| [redmine_lightbox2](https://github.com/paginagmbh/redmine_lightbox2) | 0.5.0 |
| [clipboard_image_paste](https://github.com/Utopism/clipboard_image_paste) | Commit Nov 20, 2018 |
| [redmine_graphs](https://github.com/Utopism/redmine-graphs-plugin) | Commit Nov 19, 2018 |
| [redmine_issue_templates](https://github.com/akiko-pusu/redmine_issue_templates) | 0.3.0 |
| [redmine_dashboard](https://github.com/jgraichen/redmine_dashboard) | Commit from Jan 20, 2019 |
| [redmine_tags](https://github.com/ixti/redmine_tags) | 4.0.0 |
| [additionals](https://github.com/AlphaNodes/additionals) | 2.0.19 |
| [redmine_oauth2_login](https://github.com/devent/redmine_oauth2_login) | 3.0.0 |

## Themes

Not all themes are working with a particular Redmine version. Extended testing is always required to make sure that a plugin works. Those themes are tested with the packaged Redmine version.

| Plugin | URL |
| --- | --- |
| [redmine-color-tasks](https://github.com/oklas/redmine-color-tasks) |  03/02/2017 |
| [redmine-improved-theme](https://github.com/FabriceSalvaire/redmine-improved-theme) | 25/06/2017  |
| [redmine-theme-minimalflat2](https://github.com/akabekobeko/redmine-theme-minimalflat2) | 1.3.6 |
| [Dwarf](https://github.com/themondays/Dwarf) |  02/10/2016 |
| [devent-Dwarf](https://github.com/devent/Dwarf) | 07/11/2017  |

## Test

The docker-compose file `test.yaml` can be used to startup MySQL and the Redmine base containers. Redmine can be then accessed from `localhost:8080`.
```
docker-compose -f test.yaml up
```

## License

Redmine is licensed under the [GNU General Public License v2](http://www.redmine.org/) license.

Phusion Passenger is licensed under the [MIT](https://github.com/phusion/passenger/blob/stable-5.1/LICENSE) license.

Puma is licensed under the [BSD-3-Clause](https://github.com/puma/puma/blob/master/LICENSE) license.

This Docker image is licensed under the [MIT](https://opensource.org/licenses/MIT) license.

Copyright 2017-2019 Erwin Müller

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
