#!/bin/bash
sudo apt-get update
mkdir ~/src
cd ~/src
wget https://artifacts.elastic.co/downloads/kibana/kibana-7.3.2-amd64.deb
wget https://artifacts.elastic.co/downloads/logstash/logstash-7.3.2.deb
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.3.2-amd64.deb
sudo apt-get update
sudo apt-get install openjdk-8-jre
sudo dpkg -i *.deb
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service logstash.service kibana.service
sudo systemctl start elasticsearch.service kibana.service logstash.service

echo config.reload.automatic: true |sudo tee -a /etc/logstash/logstash.yml
echo config.reload.interval: 3s |sudo tee -a /etc/logstash/logstash.yml
sudo systemctl restart logstash.service

##
sudo apt -y install cmake make gcc g++ flex bison libpcap-dev python-dev swig zlib1g-dev libgeoip-dev  autoconf python-pip python3-pip jq curl wget libsasl2-dev libhtp-dev libssl-dev
mkdir src
cd ~/src
echo "Bro install..."
#wget https://www.zeek.org/downloads/bro-2.6.4.tar.gz
wget https://www.zeek.org/downloads/zeek-3.0.0.tar.gz
tar -xvf zeek-3.0.0.tar.gz
cd zeek-3.0.0
echo "install libmaxminddb"
sudo apt-get install libmaxminddb-dev -y

#download City database
wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz
tar zxf GeoLite2-City.tar.gz
wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz
tar zxf GeoLite2-Country.tar.gz
for cityfile in ./GeoLite2-City_2019*; do
      echo ${cityfile##*/}
done
sudo mv ${cityfile}/GeoLite2-City.mmdb /usr/share/GeoIP
#mv GeoIPcountry
for ctfile in ./GeoLite2-Country_2019*; do
      echo ${ctfile##*/}
done
sudo mv ${ctfile}/GeoLite2-Country.mmdb /usr/share/GeoIP
# the file "GeoLite2-City_YYYYMMDD/GeoLite2-City.mmdb" needs to be moved to the GeoIP database directory.
#* /usr/share/GeoIP/GeoLite2-City.mmdb
#* /usr/share/GeoIP/GeoLite2-Country.mmdb
#dowload Country database
./configure --with-geoip=/usr/share/GeoIP
make -j 4
sudo make install
sudo ln -s /usr/local/zeek/bin/zeek* /usr/local/bin
#Test Bro GeoIp
sudo zeek -e "print lookup_location(8.8.8.8);"
..
echo "Broker install..."
wget https://www.zeek.org/downloads/broker-1.2.0.tar.gz
tar -xvf broker-1.2.0.tar.gz
cd broker-1.2.0
./configure
sudo make -j4 install
echo "=== Broker Installation finished ==="

#

### if you git issue for nop, just put this command "sudo npm rebuild"

#echo "ELK-Script install..."

# cd /usr/share/kibana/src/core_plugins
# sudo git clone https://github.com/JuanCarniglia/area3d_vis
# cd area3d_vis
# cd releases/5.5/
# sudo npm install vis
# sudo npm install
# cd ..
# sudo git clone https://github.com/dlumbrer/kbn_network.git network_vis -b 6-dev
# cd network_vis
# sudo rm -rf images/
# sudo npm install

cd ~/src
wget https://github.com/edenhill/librdkafka/archive/v1.2.1.tar.gz
sudo tar -xvf v1.2.1.tar.gz
cd librdkafka-1.2.1/
sudo ./configure --enable-sasl
sudo make
sudo make install
cd ~/src/
git clone https://github.com/apache/metron-bro-plugin-kafka.git --depth=1
cd metron-bro-plugin-kafka
./configure --bro-dist=$HOME/src/zeek-3.0.0 
sudo make -j4 install


##

sudo /usr/share/logstash/bin/logstash-plugin install logstash-output-exec logstash-input-jdbc
sudo /usr/share/logstash/bin/logstash-plugin install --no-verify
sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install ingest-geoip


cd ~/src
wget https://archive.apache.org/dist/zookeeper/zookeeper-3.5.6/apache-zookeeper-3.5.6-bin.tar.gz
tar -xvf apache-zookeeper-3.5.6-bin.tar.gz
sudo mv apache-zookeeper-3.5.6-bin /opt/zookeeper
sudo cp ~/src/Debian-GNU-Linux-Profiles/NSM/ELK/packages/zoo.cfg /opt/zookeeper/conf/
sudo cp ~/src/Debian-GNU-Linux-Profiles/NSM/ELK/packages/zookeeper.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable zookeeper
sudo systemctl start zookeeper

##
#sudo cp ~/src/Debian-GNU-Linux-Profiles/NSM/ELK/packages/kafka_2.12-1.0.0.tgz ~/src
wget https://www-us.apache.org/dist/kafka/2.3.0/kafka_2.12-2.3.0.tgz
sudo tar -xvf kafka_2.12-2.3.0.tgz
sudo mv kafka_2.12-2.3.0/ /opt/kafka
sudo sed -i '/^log.dirs/{s/=.*//;}' /opt/kafka/config/server.properties
sudo sed -i 's/^log.dirs/log.dirs=\/var\/lib\/kafka/' /opt/kafka/config/server.properties
sudo mv ~/src/Debian-GNU-Linux-Profiles/NSM/ELK/packages/kafka.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable kafka
sudo systemctl start kafka

sudo apt-get install libgeoip-dev -y
cd ~/src
wget https://www-us.apache.org/dist/spark/spark-2.4.3/spark-2.4.3-bin-hadoop2.7.tgz
sudo tar -xvf spark-2.4.3-bin-hadoop2.7.tgz
sudo mv spark-2.4.3-bin-hadoop2.7 /opt/spark
