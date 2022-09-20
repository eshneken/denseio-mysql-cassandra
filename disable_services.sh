#!/bin/bash

##
## Script to disable any uncessary services which may impact performance
##

sudo setenforce 0
echo "SELINUX=disabled" | sudo tee -a /etc/sysconfig/selinux

sudo rm -f /etc/cron.*/*
for i in ocarun oracle-cloud-agent oswatcher.service tuned.service crond; do
	sudo systemctl stop $i
	sudo systemctl disable $i
done
sudo rpm -e oracle-cloud-agent
sudo systemctl stop firewalld
sudo /sbin/service auditd stop
sudo /sbin/service auditd disable