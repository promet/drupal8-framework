#!/bin/bash
set -e
path=$(dirname "$0")
source $path/common.sh
# This was added because of upgrades like Rules 2.8 to 2.9 and Feeds alpha-9 to beta-1 where
# new code and database tables are added and running other code will cause white screen until
# the updates are run.
echo "Initial Update so updated modules can work.";
$drush updb -y;
echo "Enabling modules";
$drush en $(echo $DROPSHIP_SEEDS | tr ':' ' ')
echo "Clearing drush caches.";
$drush cc drush
# TO-DO: Upgrade kw_manifests and drop_ship to D8.
#echo "Running manifests"
#$drush kw-m
# TO-DO: Move setting of default theme to KW manifest.
#echo "Set default theme";
#$drush scr $base/build/scripts/default_set_theme.php
echo "Clearing caches one last time.";
$drush cr

chmod -R +w $base/cnf
chmod -R +w $base/www/sites/default
