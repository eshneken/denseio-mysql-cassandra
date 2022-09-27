##
## Run these on clients and servers to disable services which may 
##

## turn off audit and other services
##
/bin/bash disable_services.sh

##
## turn off spectre/meltdown optimizations
##
sudo vi /etc/sysconfig/grub

## MANUAL STEP
## 
## add cgroup.memory=nokmem mitigations=off to end of GRUB_CMDLINE_LINUX
##

sudo grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg

## reboot server
sudo reboot

## verify mitigations=off
cat /proc/cmdline

##
## Move docker from block to local storage.  Do this only on the database server
##
## https://linuxconfig.org/how-to-move-docker-s-default-var-lib-docker-to-another-directory-on-ubuntu-debian-linux
##
sudo systemctl stop docker.service
sudo systemctl stop docker.socket
sudo vi /lib/systemd/system/docker.service

## MANUAL STEP
##
## Modify ExecStart line to read:  ExecStart=/usr/bin/dockerd -g /u01/docker-home -H fd:// --containerd=/run/containerd/containerd.sock
##

sudo mkdir -p /u01/docker-home
sudo rsync -aqxP /var/lib/docker/ /u01/docker-home/
sudo systemctl daemon-reload
sudo systemctl start docker
sudo docker start mysql
sudo docker ps

## 
## apply sysctl changes
##
## https://www.cyberciti.biz/faq/howto-set-sysctl-variables/
##
sudo cp sysctl.txt /etc/sysctl.d/99-custom.conf
sudo sysctl -p /etc/sysctl.d/99-custom.conf

## Verify blocksize and make sure it is 4K
sudo tune2fs -l /dev/md0 | grep -i 'block size'

## Watch iostat on server while test is running.  Make all r/w goes to /dev/md0 and not /dev/sda
iostat -xd 5 -g total


