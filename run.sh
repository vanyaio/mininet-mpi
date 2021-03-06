#!/bin/bash
#run this script as root
# Accept following variants of topology: 'fattree', 'dragonfly'. Default 'fattree'
# Accept following env variables for 'fattree':
# - PACKET_LOSS, default value 0
# - PODS, default value 4
# - DENSITY, default value 1
# Accept following env variables for 'dragonfly':
# - PACKET_LOSS, default value 0
# - NUM_GROUPS, default value 4
# - NUM_SW_IN_GROUP, default value 3
# - NUM_HOSTS_FOR_SW, default value 1
# - NUM_INTER_LINKS, default value 1

TOPO="fattree"
if test $# -lt 2 ; then
    if test "$1" = "fattree" || test "$1" = "dragonfly"; then
        TOPO="$1"
    elif test "$1" = "" ; then
        :
    else
        echo -e "\e[1;31m\"$1\" is not correct name of topology\e[0m"
        exit 1
    fi
else
    echo -e "\e[1;31mNot correct number of arguments\e[0m"
    exit 1
fi
echo -e "\e[32mUsed '$TOPO' topology\e[0m"

docker ps -a | awk '{ print $1,$2 }' | grep spagnuolocarmine/docker-mpi | awk '{print $1 }' | xargs -I {} docker stop {}
docker ps -a | awk '{ print $1,$2 }' | grep spagnuolocarmine/docker-mpi | awk '{print $1 }' | xargs -I {} docker rm {}
#TODO: cluster failed to build this image, now its tar in $HOME
if test "$CLUSTER" != "yes" ; then docker build -t spagnuolocarmine/docker-mpi . ; fi
docker volume rm data
docker volume create data

export VOLUME=$(docker volume inspect --format '{{ .Mountpoint }}' data)
cp set_ssh.sh $VOLUME 
cp start_app.sh $VOLUME
cp -r mpi-app $VOLUME 

pushd $VOLUME 
ssh-keygen -t rsa -f id_rsa -N ''
popd

../pox/pox.py forwarding.l2_pairs openflow.discovery --eat-early-packets openflow.spanning_tree --no-flood --hold-down &

if test "$TOPO" = "fattree" ; then
    export PACKET_LOSS
    export PODS
    export DENSITY
    if test "$PACKET_LOSS" = ""; then PACKET_LOSS=0; fi
    if test "$PODS" = ""; then PODS=4; fi
   # if test "$DENSITY" = ""; then DENSITY=13; fi
    if test "$DENSITY" = ""; then DENSITY=1; fi
#     cat <<EOF | python3 fattree-connet.py
#     sh sleep 3
#     pingall
# EOF
#     python3 fattree-connet.py
    cat <<EOF | python3 fattree-connet.py
    sh sleep 3
    h001 /data/start_app.sh
EOF
elif test "$TOPO" = "dragonfly" ; then
    export PACKET_LOSS
    export NUM_GROUPS
    export NUM_SW_IN_GROUP
    export NUM_HOSTS_FOR_SW
    export NUM_INTER_LINKS
    if test "$PACKET_LOSS" = ""; then PACKET_LOSS=0; fi
    if test "$NUM_GROUPS" = ""; then NUM_GROUPS=4; fi
    if test "$NUM_SW_IN_GROUP" = ""; then NUM_SW_IN_GROUP=3; fi
    if test "$NUM_HOSTS_FOR_SW" = ""; then NUM_HOSTS_FOR_SW=10; fi
    if test "$NUM_INTER_LINKS" = ""; then NUM_INTER_LINKS=1; fi
#     cat <<EOF | python3 dragonfly-connet.py
#     sh sleep 3
#     pingall
# EOF
#   python3 dragonfly-connet.py
    cat <<EOF | python3 dragonfly-connet.py
    sh sleep 3
    h001 /data/start_app.sh
EOF
fi

cp $VOLUME/exec_time exec_time &> /dev/null
kill %
