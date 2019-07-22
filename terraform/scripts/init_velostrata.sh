#!/bin/bash
wget -O 'velostrata-prep_4.2.0.deb' 'https://storage.googleapis.com/velostrata-release/V4.2.0/Latest/velostrata-prep_4.2.0.deb'
sudo dpkg -i velostrata-prep_4.2.0.deb
sudo apt-get install -f -y
sudo dpkg -i velostrata-prep_4.2.0.deb