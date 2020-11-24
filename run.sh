#!/bin/bash
#run this script as root

docker stop $(docker ps -a -q) ; docker rm $(docker ps -a -q)
docker build -t spagnuolocarmine/docker-mpi .
docker volume rm data
docker volume create data

export VOLUME=/var/lib/docker/volumes/data/_data
cp set_ssh.sh /var/lib/docker/volumes/data/_data
cp start_app.sh /var/lib/docker/volumes/data/_data
cp -r mpi-app /var/lib/docker/volumes/data/_data

pushd /var/lib/docker/volumes/data/_data
ssh-keygen -t rsa -f id_rsa -N ''
popd

../pox/pox.py forwarding.l2_multi openflow.discovery --eat-early-packets openflow.spanning_tree --no-flood --hold-down &> /dev/null &
sleep 3

# python3 fattree-connet.py
cat <<EOF | python3 fattree-connet.py
h001 /data/start_app.sh
EOF

cp $VOLUME/exec_time exec_time &> /dev/null
kill %
