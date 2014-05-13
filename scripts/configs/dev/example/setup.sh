#!/bin/bash

dd-apt-repository ppa:chris-lea/node.js
apt-get update
apt-get install -y nodejs phantomjs

npm install -g grunt-cli bower karma

cd /home/vagrant/example

npm install
bower install
grunt bower
