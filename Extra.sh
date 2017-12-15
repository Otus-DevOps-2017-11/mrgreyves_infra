#!/bin/bash
apt update -y
apt install -y build-essential ruby-full ruby-bundler
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
apt update -y
apt install -y mongodb-org
systemctl start mongod
systemctl enable mongod
cd /root
git clone https://github.com/Otus-DevOps-2017-11/reddit.git
cd /root/reddit/ && bundle install
puma -d
