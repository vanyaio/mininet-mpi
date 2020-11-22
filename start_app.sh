#!/bin/bash
cd /data/mpitutorial/tutorials/mpi-hello-world/code
make
echo 'end of make'

cd /data/mpitutorial/tutorials
cat << EOF > host_file
d2
EOF

alias mpirun='mpirun -x LD_PRELOAD=libmpich.so'
mpirun -np 1 --allow-run-as-root -host d2,d1 ./mpi-hello-world/code/mpi_hello_world
cat host_file
# export MPI_HOSTS=host_file
# ./run.py mpi_hello_world
