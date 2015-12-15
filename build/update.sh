#!/bin/bash
set -e
path="$(dirname "$0")"
source "$path/common.sh"

# Change to the Drupal Directory Just In Case
pushd "$drupal_base"

# This was added because of upgrades like Rules 2.8 to 2.9 and Feeds alpha-9 to beta-1 where
# new code and database tables are added and running other code will cause white screen until
# the updates are run.
echo "Initial Update so updated modules can work.";
$drush updb -y;
echo "Enabling modules";
$drush en $(echo $DROPSHIP_SEEDS | tr ':' ' ') -y
echo "Clearing drush caches.";
$drush cc drush
# In the future, use --force https://github.com/drush-ops/drush/pull/1635
if [[ ! -e "$base/cnf/drupal/system.site.yml" ]]; then
  echo "Exporting Configuration for BRAND NEW SITE."
  $drush cex -y
  echo "Commit these changes."
fi
echo "Reverting Configuration"
$drush cim sync -y
# Default Theme is now set up in Drupal Configuration.
echo "Clearing caches one last time.";
$drush cr

chmod -R +w "$base/cnf"
chmod -R +w "$base/www/sites/default"
