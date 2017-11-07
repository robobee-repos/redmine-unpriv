# Redmine

## Description

It uses the official [Redmine image](https://hub.docker.com/_/redmine/) as the base. Enhances the base in the following ways:

- runs Passenger as a non-privileged user;
- accepts input configuration files to override the Redmine and Passenger configuration, allowing for Kubernetes config maps;
- includes additional plugins and themes;

## Environment Parameters

To configure the database backend see the official [Redmine image](https://hub.docker.com/_/redmine/).

| Variable | Default | Description |
| ------------- | ------------- | ----- |
| DEBUG  |  | Set to `true` for additional debug output. |
| NGINX_WORKER_PROCESSES | 2 | worker_processes |
| NGINX_WORKER_CONNECTIONS | 4096 | worker_connections |
| NGINX_CLIENT_MAX_BODY_SIZE | 128m | client_max_body_size |

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
