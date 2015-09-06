#!/bin/sh

# Prepare the services file for installation
if [ ! -f www/sites/default/services.yml ]
  then
    cp www/sites/default/default.services.yml www/sites/default/services.yml
    chmod 777 www/sites/default/services.yml
fi

# Prepare the files directory for installation
if [ ! -d www/sites/default/files ]
  then
    mkdir -m777 www/sites/default/files
fi
