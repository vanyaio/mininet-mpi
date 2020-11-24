#!/bin/bash
#run this script as root

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

for PACKET_LOSS in 5 20 25 ; do
	echo "$PACKET_LOSS :" >> all_exec_times
	for i in 1 2 3 4 5 ; do
		rm exec_time
		pushd ..
		vagrant halt --force ; vagrant up
		vagrant ssh -c "export PACKET_LOSS=$PACKET_LOSS ; cd /home/ubuntu/containernet/mininet-mpi ; sudo -E ./run.sh" | read_b4_match
		popd
		# while test ! -f exec_time ; do sleep 1 ; done
		cat exec_time >> all_exec_times
		if test ! -f exec_time ; then echo inf >> all_exec_times ; fi
	done
done

rm exec_time

# cat all_exec_times > python3 draw_graph.py
