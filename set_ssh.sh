#!/bin/bash
mkdir /root/.ssh
cp /data/id_rsa* /root/.ssh
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
mkdir -p /var/run/sshd

cat << EOF >> /etc/ssh/ssh_config
Host *
	StrictHostKeyChecking no
	UserKnownHostsFile=/dev/null
EOF

cat /data/etc_hosts >> /etc/hosts

if test "$1" = "start" ; then
	/usr/sbin/sshd -D &
fi
