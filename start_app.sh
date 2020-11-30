#!/bin/bash
cd /data/mpi-app
make
if test $? -ne 0; then exit 1; fi
echo 'end of success make'

cat /data/mpi_hosts_file > host_file

alias mpirun='mpirun -x LD_PRELOAD=libmpich.so'
mpirun --mca orte_base_help_aggregate 0 --allow-run-as-root --hostfile host_file \
		./mpi_hello_world
