#!/bin/bash
set -ex

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
src="https://github.com/akabekobeko/redmine-theme-minimalflat2/releases/download/v1.3.4/minimalflat2-1.3.4.zip"
hash="48ceded317cc7536612b574ac0ac40b1dc81b4123f4e0fc1bae01feb10247d41"
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
