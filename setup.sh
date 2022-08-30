
#
# MySQL and Kafka on DenseIO 32 OCPU
#

# Assumptions:
# OL7.9 on DenseIO-32
# Two regions peered together
# Ports 22, 7000 (cassandra), 3

#
# docker install
#
sudo yum -y install docker

#
# disable linux firewall
#
sudo service firewalld stop
sudo systemctl disable firewalld

#
# start docker
#
sudo systemctl enable --now docker

#
# RAID and mount FS
# https://docs.oracle.com/en/learn/ol-mdadm/index.html
#
sudo mdadm --create /dev/md0 --raid-devices=4 --level=0 /dev/nvme0n1 /dev/nvme1n1 /dev/nvme2n1 /dev/nvme3n1
sudo mkfs.ext4 -F /dev/md0
sudo mkdir /u01
sudo mount /dev/md0 /u01
echo "/dev/md0    /u01  ext4    defaults    0 0" | sudo tee -a /etc/fstab > /dev/null

#
# Run MySQL
#
sudo mkdir /u01/mysql-data
sudo chown opc /u01/mysql-data/
sudo chgrp opc /u01/mysql-data/
sudo docker run --name mysql -d -p 3306:3306 --cpus=8 --memory=16g  -e MYSQL_ROOT_PASSWORD=BoedyPoCPwd123! -v /u01/mysql-data:/var/lib/mysql:rw docker.io/mysql:8

#
# Run Cassandra
# https://hub.docker.com/_/cassandra
#
sudo mkdir /u01/cassandra-data
sudo chown opc /u01/cassandra-data/
sudo chgrp opc /u01/cassandra-data/

# first host in ring
#sudo docker run --name cassandra -d -p 7000:7000 --cpus=24 --memory=50g -e CASSANDRA_BROADCAST_ADDRESS=10.0.0.145 -v /u01/cassandra-data:/var/lib/cassandra cassandra:3.0.27

# each additional host in ring -- replace PRIVATEIP with IP of instance
#sudo docker run --name cassandra -d -p 7000:7000 --cpus=24 --memory=50g -e CASSANDRA_BROADCAST_ADDRESS=PRIVATEIP -e CASSANDRA_SEEDS=10.0.0.145 cassandra:3.0.27



