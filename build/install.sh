#!/bin/bash
set -e
path=$(dirname "$0")
true=`which true`
source $path/common.sh

echo "Installing Drupal minimal profile."
echo "Installing site...";
sqlfile=$base/build/ref/$PROJECT.sql
gzipped_sqlfile=$sqlfile.gz
if [ -e "$gzipped_sqlfile" ]; then
  echo "...from reference database."
  $drush sql-drop -y
  zcat "$gzipped_sqlfile" | $drush sqlc
elif [ -e "$sqlfile" ]; then
  echo "...from reference database."
  $drush sql-drop -y
  $drush sqlc < $sqlfile
else
  echo "...from scratch, with Drupal minimal profile.";
  # Setting PHP Options so that we don't fail while sending mail if a mail system
  # doesn't exist.
  PHP_OPTIONS="-d sendmail_path=`which true`" $drush si minimal --account-name=admin --account-pass=drupaladm1n -y
  if [[ -e "$base/cnf/drupal/system.site.yml" ]]; then
    # Without this, our import would fail in update.sh. See https://github.com/drush-ops/drush/pull/1635
    site_uuid="$(grep "uuid: " "$base/cnf/drupal/system.site.yml" | sed "s/uuid: //")"
    $drush cset system.site uuid $site_uuid -y
  fi
fi
source $path/update.sh
