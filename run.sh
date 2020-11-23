#!/bin/bash
#run this script as root
# mn --custom fattree.py --topo fattree,4 --link tc

docker stop $(docker ps -a -q) ; docker rm $(docker ps -a -q)
docker build -t spagnuolocarmine/docker-mpi .
docker volume rm data
docker volume create data

export VOLUME=/var/lib/docker/volumes/data/_data
cp set_ssh.sh /var/lib/docker/volumes/data/_data
cp start_app.sh /var/lib/docker/volumes/data/_data
cp -r ../mpitutorial /var/lib/docker/volumes/data/_data

pushd /var/lib/docker/volumes/data/_data
ssh-keygen -t rsa -f id_rsa -N ''
popd

# cd ../containernet
# python3 containernet_example.py
# cat <<EOF |  python3 containernet_example.py
# d1 /data/set_ssh.sh start
# d2 /data/set_ssh.sh start
# d1 /data/start_app.sh
# EOF

# python3 fattree-cont.py
../pox/pox.py forwarding.l2_multi openflow.discovery --eat-early-packets openflow.spanning_tree --no-flood --hold-down &> /dev/null &
python3 fattree-connet.py

# python3 containernet_example.py
# cat <<EOF |  python3 containernet_example.py
# d1 /data/start_app.sh
# EOF

# mpirun -n 4 -f host_file ./mpi-hello-world/code/mpi_hello_world
#mpirun -np 4 -hosts d2 ./mpi-hello-world/code/mpi_hello_world
#mpirun -np 4 -hosts d2 /data/mpitutorial/tutorials/mpi-hello-world/code/mpi_hello_world
