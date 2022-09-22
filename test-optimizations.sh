##
## Run these on clients and servers to disable services which may 
##

## turn off audit and other services
##
/bin/bash disable_services.sh

##
## turn off spectre/meltdown optimizations
##
##[root@a1-160-3 vulnerabilities]# cat /etc/sysconfig/grub 
##GRUB_TIMEOUT=5
##GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
##GRUB_DEFAULT=saved
##GRUB_DISABLE_SUBMENU=true
##GRUB_DISABLE_RECOVERY="true"
##GRUB_ENABLE_BLSCFG=true
##GRUB_TERMINAL="console"
##GRUB_CMDLINE_LINUX="crashkernel=auto LANG=en_US.UTF-8 console=ttyAMA0 console=ttyAMA0,115200 rd.luks=0 rd.md=0 rd.dm=0 rd.lvm.vg=ocivolume rd.lvm.lv=ocivolume/root rd.net.timeout.carrier=5 netroot=iscsi:169.254.0.2:::1:iqn.2015-02.oracle.boot:uefi rd.iscsi.param=node.session.timeo.replacement_timeout=6000 net.ifnames=1 nvme_core.shutdown_timeout=10 ipmi_si.tryacpi=0 ipmi_si.trydmi=0 libiscsi.debug_libiscsi_eh=1 loglevel=4 ip=single-dhcp crash_kexec_post_notifiers cgroup.memory=nokmem mitigations=off"

sudo vi /etc/sysconfig/grub
## add cgroup.memory=nokmem mitigations=off to end of GRUB_CMDLINE_LINUX

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


