#!/bin/bash

repository_dir=$PWD

echo -e "\e[33mInstall containernet\e[0m"
cd ..
git clone https://github.com/containernet/containernet.git

echo -e "\e[33mMove repository\e[0m"
mv $repository_dir ./containernet/mininet-mpi

echo -e "\e[33mInstall pox\e[0m"
cd containernet
git clone https://github.com/noxrepo/pox
cd pox
git checkout remotes/origin/dart
cd ..

# echo -e "\e[33mReturn to repository\e[0m"
# cd mininet-mpi
