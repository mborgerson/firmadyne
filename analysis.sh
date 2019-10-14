#!/bin/bash

# How to run:
#    $ docker run --privileged --rm -v $PWD:/work -w /work -it --net=host firmadyne
#    $ /work/example_analysis.sh /path/to/fw

set -e
set -x
cd /firmadyne

URL=$1
FW_FILE=$(basename $URL)
wget $URL

echo "Attempting to analyze firmware file \"$FW_FILE\""

# Extract contents
python3 ./sources/extractor/extractor.py -b Netgear -sql 127.0.0.1 -np -nk "$FW_FILE" images

# Determine architecture
./scripts/getArch.sh ./images/1.tar.gz
./scripts/tar2db.py -i 1 -f ./images/1.tar.gz

# FIXME: Why does the following command return error status?
set +e
echo "firmadyne" | sudo -SE ./scripts/makeImage.sh 1
set -e

echo "Detecting network configuration"
./scripts/inferNetwork.sh 1

#echo "Booting..."
#./scratch/1/run.sh
