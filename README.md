Emulation of MPI cluster with fat-tree topology using Containernet.

Проект выполнен в рамках курса "Основы Grid и Cloud вычислений", СПбГУ,
факультет ПМ-ПУ.
## Installation
Project relies on the specific environment, described below

1. Get Containernet sources:

```
$ git clone https://github.com/containernet/containernet.git
$ cd containernet
```

2. Get POX networking software platform and checkout to branch DART:

```
$ git clone https://github.com/noxrepo/pox
$ cd pox
$ git checkout remotes/origin/dart
$ cd ..
```

3. Clone this repository:

```
$ git clone https://github.com/vanyaio/mininet-mpi
```

Please note that you must end up with the following tree structure:

```
├── containernet
│   ├── mininet-mpi
│   └── pox
```

The last dependency is Vagrant: https://www.vagrantup.com/docs/installation

## Usage

Put your MPI application to mininet-mpi/mpi-app with its Makefile or stay
with example broadcasting application.

For single cluster run change directory to containernet and ssh Vagrant box:

```
$ vagrant up
$ vagrantup ssh
vagrant@ubuntu$ cd /home/ubuntu/containernet/mininet-mpi
```

You may export following environment variables:
PODS - number of pods in fat-tree topology, default value 4\
DENSITY - density of fat-tree topology (nubmer of nodes for each edge switch), default value 1\
PACKET_LOSS - percentage of broken links with packets loss, default is 0

Run:

```
vagrant@ubuntu$ cd /home/ubuntu/containernet/mininet-mpi
vagrant@ubuntu$ sudo -E ./run.sh
```

And finally see application output.

To gather statics you can use stats_run.sh script, which runs app with
0%, 5%,..., 30% broken links 5 times, producing all_exec_times file
with time statistics of these runs and drawing their graph.

Log out Vagrang box if you are in it:

```
vagrant@ubuntu$ logout
```

And run this script from host machine:

```
$ ./stats_run.sh
```

## Architecture

![alt text](arch.png?raw=true)

The main script is run.sh that makes these steps:
1. Build Docker image required for running MPI on each node.
2. Create shared storage with Docker volumes mechanism.
3. Copy script for SSH configuration of containers and script for
running MPI application into volume and generate ssh keys in it.
4. Run POX controller and python program creating fat-tree
topology, dumping various information about nodes and running SSH config 
on each node.
5. Make one of the nodes MPI master which starts application.
6. Kill pox controller daemon and optionally grab execution time.

Script for gathering statistics - stats_run.sh - mostly relies on run.sh.
Currently on each run it forces VM to reload due to some buggy unstable
behavior of POX/Containernet or author's misconfiguraton of some of them
and starts run.sh with ssh, accumulating execution time of each run in
all_exec_times file and drawing graph with draw_python.py.

## Useful links
The following links are helpful if you decide to dig into sources:\
http://mininet.org - Mininet network emulator.\
https://containernet.github.io - fork of the Mininet which allows to use Docker containers as hosts.\
https://mpitutorial.com/tutorials - great resource with MPI installation and related
tutorials.\
https://noxrepo.github.io/pox-doc/html - networking software platform.\
https://www.docker.com - software for creating containers.\
https://www.vagrantup.com - allows to run VM in easy way.\
https://linuxcommand.org/tlcl.php - The Linux Command Line by William Shotts is
a great resource for learning shell scripting.\
https://docs.python.org/3/tutorial - tutorial for Python programming language used
by both Mininet and Containernet.\
https://www.cs.cornell.edu/courses/cs5413/2014fa/lectures/08-fattree.pdf - description of fat-tree topology.
