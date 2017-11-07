#!/bin/bash
set -e
source /docker-entrypoint-utils.sh
set_debug

# https://github.com/martin-denizet/redmine_custom_css
src="https://github.com/martin-denizet/redmine_custom_css/archive/0.1.6.zip"
hash="48031a1975aca11fede5d17691d299764661bbd5f29a3a6d77a61737d96d1814"
name="redmine_custom_css"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

# https://github.com/haru/redmine_theme_changer
src="https://github.com/haru/redmine_theme_changer/releases/download/0.3.1/redmine_theme_changer-0.3.1.zip"
hash="3ceedaafae55a575d415c009283f44b89e0160378962ed64b20e4c622ca3f61c"
name="redmine_theme_changer"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

# https://github.com/paginagmbh/redmine_lightbox2
src="https://github.com/paginagmbh/redmine_lightbox2/archive/v0.4.3.zip"
hash="108540476aa71904f96ba5abfa65c7b48c33c19b7226fface0b84d91ae2a8dba"
name="redmine_lightbox2"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

# https://github.com/peclik/clipboard_image_paste
src="https://github.com/peclik/clipboard_image_paste/archive/v1.12.zip"
hash="372cee648645a408616e395ef0dc40be43e0cd5d0786983bfca2be9a0ec7a611"
name="clipboard_image_paste"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

# https://www.r-labs.org/projects/r-labs/wiki/Wiki_Extensions_en
src="https://www.dropbox.com/s/4ffd2o0a2sxcfrm/redmine_wiki_extensions-0.8.0.zip?dl=0"
hash="978cd0f28a7063f01c0e997972987e841dc6e1be107accac14ec7298c13f87d8"
name="redmine_wiki_extensions"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

# https://github.com/akiko-pusu/redmine_issue_templates
src="https://github.com/akiko-pusu/redmine_issue_templates/archive/0.1.8.zip"
hash="17d56479df2d3242f14375dd706a97e6b3d6f838949f80a67af9e6d03b0ecf97"
name="redmine_issue_templates"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

# https://github.com/jgraichen/redmine_dashboard
src="https://github.com/jgraichen/redmine_dashboard/releases/download/v2.7.1/redmine_dashboard-v2.7.1.tar.gz"
hash="738a6b0da5ce3124f369043df3441fe8bdbbb32838f4714bb90e7842c7ffce78"
name="redmine_dashboard"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly
