#!/bin/bash
cd /data/mpi-app
make
if test $? -ne 0; then exit 1; fi
echo 'end of success make'

cat /data/mpi_hosts_file > host_file

alias mpirun='mpirun -x LD_PRELOAD=libmpich.so'
mpirun --allow-run-as-root --hostfile host_file \
		./mpi_hello_world
