#
# MySQL and Kafka on DenseIO 32 OCPU
#

# Assumptions:
# OL7.9 on DenseIO-32
# Two regions peered together
# Ports 22, 7000 (cassandra), 3306 (mysql)

#
# docker install
#
sudo yum update -y
sudo yum -y install docker

#
# grow oci root partition
#
sudo /usr/libexec/oci-growfs -y

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
sudo mkfs.ext4 -b 4096 /dev/md0
sudo mkdir /u01
sudo mount /dev/md0 /u01
sudo chown -R opc:opc /u01
echo "/dev/md0    /u01  ext4    defaults    0 0" | sudo tee -a /etc/fstab > /dev/null

#
# Run MySQL
# https://phoenixnap.com/kb/mysql-docker-container
#
# To test config variables get picked up:
# 1. sudo yum -y install mysql
# 2. mysql -uroot -p$DB_PASSWORD -h127.0.0.1 -P3306 -e 'show global variables';
#
mkdir /u01/mysql-data
mkdir /u01/mysql-config

cat << EOF > /u01/mysql-config/my.cnf
[mysqld]                                                                                                                                                                                                                           
innodb_buffer_pool_size=10737418240
innodb_flush_method=O_DIRECT
max_prepared_stmt_count=1048576
innodb_doublewrite=1
innodb_redo_log_capacity=128000000000

# log settings
#user=mysql
#log_error=mysqld.log

# nicolas settings
#innodb_buffer_pool_size=450G
#innodb_change_buffering=none
#innodb_doublewrite_pages=128
#innodb_flush_neighbors=0
#innodb_io_capacity=2000
#innodb_io_capacity_max=2000
#innodb_log_buffer_size=67108864
#innodb_max_purge_lag=0
#innodb_use_fdatasync=ON
EOF

export DB_PASSWORD=YourTopSecretPassword

sudo docker run --name mysql -d -p 3306:3306 --cpuset-cpus=0:7 --memory=17g  -e MYSQL_ROOT_PASSWORD=$DB_PASSWORD -v /u01/mysql-config:/etc/mysql/conf.d:rw -v /u01/mysql-data:/var/lib/mysql:rw docker.io/mysql:8

#
# Run Cassandra
# https://hub.docker.com/_/cassandra
#
mkdir /u01/cassandra-data

# first host in ring - replace PRIVATEIP with IP of instance
#sudo docker run --name cassandra -d -p 7000:7000 --cpus=24 --memory=50g -e CASSANDRA_BROADCAST_ADDRESS=PRIVATEIP -v /u01/cassandra-data:/var/lib/cassandra cassandra:3.0.27

# each additional host in ring -- replace PRIVATEIP with IP of instance and FIRSTIP with IP of first host in ring
#sudo docker run --name cassandra -d -p 7000:7000 --cpus=24 --memory=50g -e CASSANDRA_BROADCAST_ADDRESS=PRIVATEIP -e CASSANDRA_SEEDS=FIRSTIP -v /u01/cassandra-data:/var/lib/cassandra cassandra:3.0.27



