#!/bin/bash

read_b4_match () {
	match="ORTE was unable to reliably start one or more daemons"
	while true; do
		read line
		if test -z "$line"; then break ; fi
		if test -z "$(echo "$line" | grep "$match")" ; then
			echo $line
		else
			echo "MPI hangs - restart"
			vagrant halt --force
			break
		fi
	done
}

rm all_exec_times

if test -z "$1" ; then
	packets_loss=(0 5 10 15 20 25 30)
	runs=(1 2 3 4 5)
elif test "$1" = "single" ; then
	packets_loss=(0)
	runs=(1)
else
	echo "Unknown option"
	exit 1
fi

for PACKET_LOSS in ${packets_loss[@]}; do
	echo "$PACKET_LOSS :" >> all_exec_times
	for i in ${runs[@]} ; do
		rm exec_time
		pushd ..
		vagrant halt --force ; vagrant up
		vagrant ssh -c "export PACKET_LOSS=$PACKET_LOSS ; cd /home/ubuntu/containernet/mininet-mpi ; sudo -E ./run.sh" | read_b4_match
		popd
		cat exec_time >> all_exec_times
		if test ! -f exec_time ; then echo inf >> all_exec_times ; fi
	done
done

rm exec_time

cat all_exec_times | python3 draw_graph.py
