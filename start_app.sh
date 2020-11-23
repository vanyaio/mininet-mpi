#!/bin/bash
cd /data/mpitutorial/tutorials/mpi-hello-world/code
make
echo 'end of make'

cd /data/mpitutorial/tutorials
# cat << EOF > host_file
# d2
# EOF
cat /data/mpi_hosts_file > host_file

alias mpirun='mpirun -x LD_PRELOAD=libmpich.so'
#TODO: care with np option!
# mpirun -np 1 --allow-run-as-root -host d1,d2 host_file \
		# ./mpi-hello-world/code/mpi_hello_world
mpirun -np 2 --allow-run-as-root --hostfile host_file \
		./mpi-hello-world/code/mpi_hello_world


# mpirun -np 1 --allow-run-as-root -host d1,d2 ./mpi-hello-world/code/mpi_hello_world
# export MPI_HOSTS=host_file
# ./run.py mpi_hello_world
