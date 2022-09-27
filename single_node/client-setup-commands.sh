##
## client machine setup
##

## set server IP and DB_PASSWORD
export DB_PRIVATE_IP=x.x.x.x
export DB_PASSWORD=YourTopSecretPassword

## update client libs
sudo yum update -y
sudo yum -y install make git automake libtool pkg-config libaio-dev libmysqlclient-dev libssl-dev mysql-devel libssl-devel mysql

## verify mysql install
mysql -uroot -p$DB_PASSWORD -h$DB_PRIVATE_IP -P3306 -e 'show global variables';

## get and build sysbench
mkdir mysql-benchmark
cd mysql-benchmark/
git clone https://github.com/akopytov/sysbench.git
cd sysbench/
./autogen.sh
./configure
sudo make install

## add local sysbench to path
export PATH=/home/opc/mysql-benchmark/sysbench/src:$PATH
echo "export PATH=/home/opc/mysql-benchmark/sysbench/src:$PATH" >> ~/.bash_profile

## enter testing directory
cd ../
git clone https://github.com/ovaistariq/benchmark_automation.git

## create sysbench user in DB
mysql -uroot -p$DB_PASSWORD -h$DB_PRIVATE_IP -P3306 -e 'CREATE DATABASE IF NOT EXISTS sysbench;'
mysql -uroot -p$DB_PASSWORD -h$DB_PRIVATE_IP -P3306 -e 'CREATE USER IF NOT EXISTS sysbench IDENTIFIED BY "sysbench";'
mysql -uroot -p$DB_PASSWORD -h$DB_PRIVATE_IP -P3306 -e 'GRANT all ON sysbench.* TO "sysbench"@"%";'
mysql -uroot -p$DB_PASSWORD -h$DB_PRIVATE_IP -P3306 -e 'set global max_prepared_stmt_count=1048576;'

##
## update verbosity in /benchmark_wrappers/run_sbmysql.sh b/benchmark_wrappers/run_sbmysql.sh from 0 to 3
##

## run on client
time _TESTS_DIR=~/mysql-benchmark/sysbench/src/lua _COLLECT_VMSTAT=yes _EXP_NAME="highio" _TESTS=oltp_read_write _THREADS="1 16 64 128" _TABLES=128 _SIZE=1000000 _MYSQL_USER=sysbench _MYSQL_PASSWORD=sysbench _MYSQL_HOST=$DB_PRIVATE_IP _DURATION=1800 benchmark_automation/benchmark_wrappers/run_sbmysql.sh --mysql-db=sysbench --rand-type=pareto --rand-pareto-h=0.5 --percentile=99