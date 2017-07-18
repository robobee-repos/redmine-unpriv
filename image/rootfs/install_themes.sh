#!/bin/bash
set -ex

# https://github.com/oklas/redmine-color-tasks
src="https://github.com/oklas/redmine-color-tasks/archive/5106193e1f442cc4f019c61899aa212d2c5c3c32.zip"
hash="0f15b8677d8ea8790e2ed9d8ce5969246fafb07c03cfbfac5f31cac74fc75d67"
name="color-tasks"
/install-redmine-theme.sh "$src" "$name" "$hash" downloadOnly

src="https://github.com/FabriceSalvaire/redmine-improved-theme/archive/63a2381f29a97147e9b7b370bc5b2be8a71f23a6.zip"
hash="602f731af304f432616e076395a6254b8f1d60d748a583b1b4cd57444be97965"
name="improved-theme"
/install-redmine-theme.sh "$src" "$name" "$hash" downloadOnly

src="https://github.com/akabekobeko/redmine-theme-minimalflat2/releases/download/v1.3.0/minimalflat2-1.3.0.zip"
hash="8382e93ad58e3b5092ae60f161014230b9bf41129ef3cdb3137f8d0af3dfd05b"
name="minimalflat2"
/install-redmine-theme.sh "$src" "$name" "$hash" downloadOnly

src="https://github.com/themondays/Dwarf/archive/bcb66f895db7baa07b16bfc65a00f0853e5e210f.zip"
hash="84be43a3f139774eb2c693c7bc571026e2dfcc4e08697c47096e8059d9995179"
name="dwarf"
/install-redmine-theme.sh "$src" "$name" "$hash" downloadOnly
cd /usr/src/redmine/public/themes
mv dwarf/production/dwarf dwarf-theme
rm -rf dwarf
mv dwarf-theme dwarf
