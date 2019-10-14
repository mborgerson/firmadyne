#!/bin/bash
set -e
set -x

# Move to firmadyne dir
FIRMADYNE_INSTALL_DIR=/firmadyne
pushd $FIRMADYNE_INSTALL_DIR

# Set up binwalk
pushd binwalk
sudo ./deps.sh --yes
sudo python3 ./setup.py install
popd

# Install additional deps
sudo pip3 install git+https://github.com/ahupp/python-magic
sudo pip3 install git+https://github.com/sviehb/jefferson

# Set up database
sudo service postgresql start
sudo -u postgres createuser firmadyne
sudo -u postgres createdb -O firmadyne firmware
sudo -u postgres psql -d firmware < ./database/schema
echo "ALTER USER firmadyne PASSWORD 'firmadyne'" | sudo -u postgres psql

# Set up firmadyne
./download.sh

# Set FIRMWARE_DIR in firmadyne.config
mv firmadyne.config firmadyne.config.orig
echo -e '#!/bin/sh' "\nFIRMWARE_DIR=$(pwd)/" > firmadyne.config
cat firmadyne.config.orig >> firmadyne.config

# Make sure firmadyne user owns this dir
sudo chown -R firmadyne:firmadyne $FIRMADYNE_INSTALL_DIR
