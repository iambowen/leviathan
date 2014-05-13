#!/bin/bash
# Source function library.
sudo cp ./assets/configserver /etc/init.d/
sudo chmod +x /etc/init.d/configserver
chkconfig configserver on
service configserver start
