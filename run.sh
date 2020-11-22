#!/bin/bash
#run this script as root
# mn --custom fattree.py --topo fattree,4 --link tc

docker volume rm data
docker volume create data

cp set_ssh.sh /var/lib/docker/volumes/data/_data
cp start_app.sh /var/lib/docker/volumes/data/_data
cp -r ../mpitutorial /var/lib/docker/volumes/data/_data

pushd /var/lib/docker/volumes/data/_data
ssh-keygen -t rsa -f id_rsa -N ''
popd

cd ../containernet

# python3 examples/containernet_example.py
cat <<EOF |  python3 examples/containernet_example.py
d1 /data/set_ssh.sh start
d2 /data/set_ssh.sh start
d1 /data/start_app.sh
EOF
#d2 ssh d1

# mpirun -n 4 -f host_file ./mpi-hello-world/code/mpi_hello_world
#mpirun -np 4 -hosts d2 ./mpi-hello-world/code/mpi_hello_world
#mpirun -np 4 -hosts d2 /data/mpitutorial/tutorials/mpi-hello-world/code/mpi_hello_world
