#!/bin/bash
set -ex

src="https://github.com/martin-denizet/redmine_custom_css/archive/0.1.6.zip"
hash="48031a1975aca11fede5d17691d299764661bbd5f29a3a6d77a61737d96d1814"
name="redmine_custom_css"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

src="https://github.com/haru/redmine_theme_changer/releases/download/0.3.0/redmine_theme_changer-0.3.0.zip"
hash="8af1d3346dbd05e6644e243f7d969a21a498b924b0473bcb5c803e400f4ea0a4"
name="redmine_theme_changer"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

src="https://github.com/paginagmbh/redmine_lightbox2/archive/v0.3.2.zip"
hash="77dcc9cd133221b5fbbc8bd783468038ed1895d744f77412752b1267d4b8d4b1"
name="redmine_lightbox2"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

# https://github.com/peclik/clipboard_image_paste
src="https://github.com/peclik/clipboard_image_paste/archive/v1.12.zip"
hash="372cee648645a408616e395ef0dc40be43e0cd5d0786983bfca2be9a0ec7a611"
name="clipboard_image_paste"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

# https://www.r-labs.org/projects/r-labs/wiki/Wiki_Extensions_en
src="https://cloud.muellerpublic.de/s/sJJRQxzg7Z0ODND/download"
hash="978cd0f28a7063f01c0e997972987e841dc6e1be107accac14ec7298c13f87d8"
name="redmine_wiki_extensions"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

# https://www.r-labs.org/projects/issue-template
src="https://github.com/akiko-pusu/redmine_issue_templates/archive/0.1.6.zip"
hash="d5d568aefe8f8e7407cc2e824d13c3903fc82583fd769512668563a5bebdbf57"
name="redmine_issue_templates"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly

src="https://github.com/bradbeattie/redmine-graphs-plugin/archive/3d44b4f44295b22ec4ba50e0ca1ff7af44da7379.zip"
hash="670e1856a1978c1fcc76be54b6e5106cb0b09033f787d4c2c8c6bb53e8f762df"
name="redmine-graphs-plugin"
/install-redmine-plugin.sh "$src" "$name" "$hash" downloadOnly
