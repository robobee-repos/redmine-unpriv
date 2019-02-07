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
src="https://github.com/paginagmbh/redmine_lightbox2/archive/v0.4.4.zip"
hash="b005617a876f64f8b56139649e86d1e344a7b646194f624b8c0752b9367beebd"
name="redmine_lightbox2"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

# https://github.com/peclik/clipboard_image_paste
src="https://github.com/peclik/clipboard_image_paste/archive/v1.13.zip"
hash="76b6e2c2b77edfb6182ab1829e8c22b302983a7ecae45e37186196f39924c57e"
name="clipboard_image_paste"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

# https://www.r-labs.org/projects/r-labs/wiki/Wiki_Extensions_en
src="https://www.dropbox.com/s/4ffd2o0a2sxcfrm/redmine_wiki_extensions-0.8.0.zip?dl=0"
hash="978cd0f28a7063f01c0e997972987e841dc6e1be107accac14ec7298c13f87d8"
name="redmine_wiki_extensions"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

# https://github.com/akiko-pusu/redmine_issue_templates
src="https://github.com/akiko-pusu/redmine_issue_templates/archive/0.2.1.zip"
hash="cc1a820d7ed07f3a11d7cdf258a07fb38ae4b02570780823e45b156fbfad0118"
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
