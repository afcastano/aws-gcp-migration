#!/bin/bash
echo '############################## Installing mysql...'
sudo apt-get update
echo 'mysql-server mysql-server/root_password password passw' | sudo debconf-set-selections
echo 'mysql-server mysql-server/root_password_again password passw' | sudo debconf-set-selections
sudo apt-get -y install mysql-server
echo '############################## Creating mysql user...'
mysql -uroot -ppassw -e 'GRANT ALL ON *.* TO "wpdemo"@"%" IDENTIFIED BY "wpdemo";'
echo '############################## Allow remote connections...'
sudo sh -c "echo '[mysqld]' >> /etc/mysql/my.cnf"
sudo sh -c "echo 'bind-address = 0.0.0.0' >> /etc/mysql/my.cnf"
sudo sh -c "echo '[client]' >> /etc/mysql/my.cnf"
sudo sh -c "echo 'port = 3306' >> /etc/mysql/my.cnf"
sudo cat /etc/mysql/my.cnf
echo '############################## Restarting service'
sudo service mysql restart
echo '############################## Done'
sleep 20