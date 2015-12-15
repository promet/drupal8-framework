#!/bin/bash

set -e
project=$1
path=$(dirname "$0")
base=$(cd $path/.. && pwd)

echo "Get Composer"
[[ -z `which composer` ]] && curl -sS https://getcomposer.org/installer | php && cp composer.phar /usr/bin/composer && rm composer.phar || true
composer self-update
if [[ ! -f /opt/phantomjs ]]
then
  echo "Downloading PhantomJS"
  wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.7-linux-x86_64.tar.bz2 -O - 2>/dev/null | tar xj -C /tmp
  sudo cp /tmp/phantom*/bin/phantomjs /opt
  # We should also do this on machine boot
  sudo sed -i '$i/opt/phantomjs --webdriver=8643 &> /dev/null &' /etc/rc.local
fi

echo "Starting up PhantomJS"
[[ -z `pgrep phantomjs` ]] && /opt/phantomjs --webdriver=8643 &> /dev/null &

if [[ -z $project ]]
then
  exit
fi

cd $base

[[ ! -z "$(grep 'PROJECT="default"' env.dist)" ]] && sed -i "s/default/$project/" env.dist

if [[ ! -f .env ]]
then
  echo "Creating Environment File"
  echo "source env.dist" > .env
fi
source .env
if [[ -d www/modules/custom/default ]]
then
  echo "Setting up Default Project Modules."
  if [[ ! -d www/modules/custom/$project ]]
  then
    mkdir www/modules/custom/$project
  fi
  mv www/modules/custom/default/default.module www/modules/custom/$project/$project.module
  mv www/modules/custom/default/default.info.yml www/modules/custom/$project/$project.info.yml
  rm -r www/modules/custom/default
  sed -i s/default/$project/g www/modules/custom/$project/$project.* ./composer.json
  echo "*****************************************"
  echo "* Don't forget to Commit these changes. *"
  echo "*****************************************"
fi

if [[ ! -z `grep "# Promet Drupal 8 Framework" README.md` ]]
then
  sed -i "1s/^# Promet Drupal 8 Framework/# $project/" README.md
  sed -i "s/drupalproject/$project/" README.md
fi
