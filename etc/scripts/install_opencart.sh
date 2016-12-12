#!/bin/bash

# Clone the current opencart repo
git clone https://github.com/opencart/opencart.git tmp/

# Move files from tmp directory
mv tmp/upload/* www/
mv www/config-dist.php www/config.php
mv www/admin/config-dist.php www/admin/config.php

# Update permissions
chmod 0755 www/system/storage/cache/
chmod 0755 www/system/storage/logs/
chmod 0755 www/system/storage/download/
chmod 0755 www/system/storage/upload/
chmod 0755 www/system/storage/modification/
chmod 0755 www/image
chmod 0755 www/image/cache/
chmod 0755 www/image/catalog/
chmod 0755 www/config.php 
chmod 0755 www/admin/config.php

# Remove tmp directory
rm -rf tmp

# Restart nginx
docker-compose restart nginx

# Restart php
docker-compose restart php