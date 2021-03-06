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

# https://github.com/akiko-pusu/redmine_issue_templates
src="https://github.com/akiko-pusu/redmine_issue_templates/archive/0.3.1.zip"
hash="0822b1452485d8043253e8e8bae2332ca2f546f0a8661c2943728c9304024282"
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

# https://github.com/AlphaNodes/additionals
src="https://github.com/AlphaNodes/additionals/archive/2.0.20.zip"
hash="fede1ff72dc7ea919f9ed25d9c169e3eeb82c4273beeaa33b94c8ef0bf66d630"
name="additionals"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

# Original https://github.com/gpstogis/redmine_oauth2_login
# https://github.com/devent/redmine_oauth2_login
src="https://github.com/devent/redmine_oauth2_login/archive/3.0.0.zip"
hash="3449b829b30d112c78219f8c8091d3c842102cffb6791d78347b99188d501a73"
name="redmine_oauth2_login"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

