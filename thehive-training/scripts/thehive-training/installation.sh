#! /usr/bin/env bash

 echo "LANG=en_US.UTF-8" >> /etc/environment
 echo "LANGUAGE=en_US.UTF-8" >> /etc/environment
 echo "LC_ALL=en_US.UTF-8" >> /etc/environment
 echo "LC_CTYPE=en_US.UTF-8" >> /etc/environment

echo "--- Installing OpenJDK"

add-apt-repository ppa:openjdk-r/ppa -y > /dev/null 2>&1 
apt-get update > /dev/null 2>&1
apt-get install -y openjdk-11-jre-headless > /dev/null 2>&1


echo "--- Adding Elasticsearch repository for Cortex"


# PGP key installation
#apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key D88E42B4 
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch |  apt-key add - > /dev/null 2>&1
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" |  tee -a /etc/apt/sources.list.d/elastic-6.x.list > /dev/null 2>&1
# Install https support for apt
 apt-get install apt-transport-https > /dev/null 2>&1

# ElasticSearch installation
echo "--- Installing Elasticsearch"
 apt-get update > /dev/null 2>&1
 apt-get install elasticsearch > /dev/null 2>&1

 mkdir -p /opt/backup
 chown elasticsearch:elasticsearch /opt/backup

echo "--- Configuring Elasticsearch"
 cat >> /etc/elasticsearch/elasticsearch.yml <<EOF
http.host: 127.0.0.1
transport.host: 127.0.0.1
cluster.name: hive
thread_pool.index.queue_size: 100000
thread_pool.search.queue_size: 100000
thread_pool.bulk.queue_size: 100000
path.repo: ["/opt/backup"]
EOF
echo "--- Starting Elasticsearch"
 systemctl enable elasticsearch.service > /dev/null 2>&1
 systemctl start elasticsearch.service > /dev/null 2>&1
#  systemctl status elasticsearch.service


echo "--- Adding TheHive and Cortex repository"

wget -O- "https://raw.githubusercontent.com/TheHive-Project/TheHive/master/PGP-PUBLIC-KEY"  | sudo apt-key add -
echo 'deb https://deb.thehive-project.org beta main' | sudo tee -a /etc/apt/sources.list.d/thehive-project.list
sudo apt-get update > /dev/null 2>&1


# Cortex

## install docker
echo "--- Installing Docker"
apt-get update > /dev/null 2>&1
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
wget -O- https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-get update > /dev/null 2>&1
apt-get install -y docker-ce

##  Install Cortex
echo "--- Installing Cortex"
apt-get install -y  cortex > /dev/null 2>&1
sleep 20

## Install TheHive
echo "--- Installing TheHive"
mkdir -p /opt/thp_data/berkeleydb/thehive
mkdir -p /opt/thp_data/files/thehive
apt-get install -y  thehive4 > /dev/null 2>&1
sleep 20
chown -R thehive:thehive /opt/thp_data


# Cortex-Analyzers
## Giving user cortex rights to run docker
usermod -a -G docker cortex

echo "--- Installing python tools"
# apt-get install -y  git > /dev/null 2>&1
apt-get install -y python-pip-whl python2.7-dev python3-pip ssdeep libfuzzy-dev libfuzzy2 libimage-exiftool-perl libmagic1 build-essential libssl-dev >  /dev/null 2>&1
/usr/bin/python2 -m pip install -U pip > /dev/null 2>&1
pip install thehive4py > /dev/null 2>&1
pip3 install thehive4py > /dev/null 2>&1
pip install cortex4py > /dev/null 2>&1
pip3 install cortex4py > /dev/null 2>&1

