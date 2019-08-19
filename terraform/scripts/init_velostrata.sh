#!/bin/bash
wget -O 'velostrata-prep.deb' 'https://storage.googleapis.com/velostrata-release/4.5/4.5.0_build_26748/velostrata-prep.deb'
sudo dpkg -i velostrata-prep.deb
sudo apt-get install -f -y
sudo dpkg -i velostrata-prep.deb