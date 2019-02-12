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
src="https://github.com/haru/redmine_theme_changer/releases/download/0.4.0/redmine_theme_changer-0.4.0.zip"
hash="74aa6551d399fd8800e034ad79b624631c684a29939e9100b63fc2bf795adb36"
name="redmine_theme_changer"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

# https://github.com/paginagmbh/redmine_lightbox2
src="https://github.com/paginagmbh/redmine_lightbox2/archive/v0.5.0.zip"
hash="367d78c34cb9d249c56a90adb808df0ae0ca22cd5edeae3814aec07332cc7f5e"
name="redmine_lightbox2"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

# https://github.com/peclik/clipboard_image_paste
# Fork https://github.com/Utopism/clipboard_image_paste
# Commit from Nov 20, 2018
src="https://github.com/Utopism/clipboard_image_paste/archive/1031117e0cf60d08f8f50e6c215fcd8abe1829c5.zip"
hash="946d67172f1d3f83f2266d28e2ac1eec21c108273bf13b6e9edd090d9a01a589"
name="clipboard_image_paste"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

# https://github.com/Utopism/redmine-graphs-plugin
# Commit from  19 Nov 2018
src="https://github.com/Utopism/redmine-graphs-plugin/archive/51e3fe2944ed3543efa3f3b9bbc4e28d8d418048.zip"
hash="c1a1992dd15b7587330adcfe1d43ee2e239a87665a8989e0f4e38078b115db33"
name="redmine_graphs"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

# https://github.com/akiko-pusu/redmine_issue_templates
src="https://github.com/akiko-pusu/redmine_issue_templates/archive/0.3.0.zip"
hash="3277b3fa93a144bd79456f29241b5f0ff4f763fb9a18af33fe6662fe1cab1461"
name="redmine_issue_templates"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

# https://github.com/jgraichen/redmine_dashboard
# Commit from Jan 20, 2019
src="https://github.com/jgraichen/redmine_dashboard/archive/7631921e18079ed3757d730c0c073e837a2d2ca6.zip"
hash="ed714b247a77a74ed006a55f3383240025b7b48599fc572c5e0207b0eef84832"
name="redmine_dashboard"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

# https://github.com/ixti/redmine_tags
src="https://github.com/ixti/redmine_tags/archive/4.0.0.zip"
hash="b43be4cd1f5a084485edc86ee8293d852d93fd5a50501678dd516d0fbb6889d1"
name="redmine_tags"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly
