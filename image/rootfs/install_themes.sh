#!/bin/bash
set -e
source /docker-entrypoint-utils.sh
set_debug

# https://github.com/oklas/redmine-color-tasks
src="https://github.com/oklas/redmine-color-tasks/archive/5106193e1f442cc4f019c61899aa212d2c5c3c32.zip"
hash="0f15b8677d8ea8790e2ed9d8ce5969246fafb07c03cfbfac5f31cac74fc75d67"
name="color-tasks"
/install-redmine-theme.sh "$src" "$name" "$hash" downloadOnly

# https://github.com/FabriceSalvaire/redmine-improved-theme
src="https://github.com/FabriceSalvaire/redmine-improved-theme/archive/15bc4d0bc76d89ea2f81bc49ebe5cf5fc2b2974e.zip"
hash="c6379948deedd9b03858c64b6e1a6099995d9294db5189898592ef55dcae037a"
name="improved-theme"
/install-redmine-theme.sh "$src" "$name" "$hash" downloadOnly

# https://github.com/akabekobeko/redmine-theme-minimalflat2
src="https://github.com/akabekobeko/redmine-theme-minimalflat2/releases/download/v1.4.0/minimalflat2-1.4.0.zip"
hash="4563cfe7796a5c7657293066128570348814fda09408a3c2278aa140e3745b14"
name="minimalflat2"
/install-redmine-theme.sh "$src" "$name" "$hash" downloadOnly

# https://github.com/themondays/Dwarf
src="https://github.com/themondays/Dwarf/archive/bcb66f895db7baa07b16bfc65a00f0853e5e210f.zip"
hash="84be43a3f139774eb2c693c7bc571026e2dfcc4e08697c47096e8059d9995179"
name="dwarf"
/install-redmine-theme.sh "$src" "$name" "$hash" downloadOnly
cd /usr/src/redmine/public/themes
mv dwarf/production/dwarf dwarf-theme
rm -rf dwarf
mv dwarf-theme dwarf

# https://github.com/devent/Dwarf
src="https://github.com/devent/Dwarf/archive/4a6654822a8d092e1c5e0a8c4154a18079248853.zip"
hash="4b79bacb921d6907c5d7f2bcb57c8d86b0d11a267082f71fcf95f2a6163cea85"
name="dwarf-simple"
/install-redmine-theme.sh "$src" "$name" "$hash" downloadOnly
cd /usr/src/redmine/public/themes
mv dwarf-simple/production/dwarf dwarf-theme
rm -rf dwarf-simple
mv dwarf-theme dwarf-simple
