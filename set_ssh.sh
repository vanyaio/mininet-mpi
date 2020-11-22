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

cat << EOF >> /etc/hosts
10.0.0.251 d1
10.0.0.252 d2
EOF


if test "$1" = "start" ; then
	/usr/sbin/sshd -D &
fi
