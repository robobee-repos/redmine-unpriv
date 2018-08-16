#!/bin/bash
set -e
source /docker-entrypoint-utils.sh
set_debug

# https://github.com/martin-denizet/redmine_custom_css
src="https://github.com/martin-denizet/redmine_custom_css/archive/0.1.7.zip"
hash="4cf7aeee98fe9c74bd3e5f32149d96af8e7c081748acc818254a63be81dfd633"
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
src="https://github.com/akiko-pusu/redmine_issue_templates/archive/0.2.0.zip"
hash="5ed7c8f525cb39a1efac0584416b1ae216b0f0977cc68c9d8014ce3c7db907db"
name="redmine_issue_templates"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

# https://github.com/jgraichen/redmine_dashboard
src="https://github.com/jgraichen/redmine_dashboard/releases/download/v2.7.1/redmine_dashboard-v2.7.1.tar.gz"
hash="738a6b0da5ce3124f369043df3441fe8bdbbb32838f4714bb90e7842c7ffce78"
name="redmine_dashboard"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

# https://github.com/ixti/redmine_tags
src="https://github.com/ixti/redmine_tags/archive/3.2.2.zip"
hash="516849e3e26556074a0f67c6439e17ad06b91c45e217464ccba4fc7be91da46c"
name="redmine_tags"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly
