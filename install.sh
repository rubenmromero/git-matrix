#!/bin/bash

if [[ ! $(which wget) ]]
then
   [[ $(which apt-get) ]] && sudo apt-get install wget
   [[ $(which yum) ]] && sudo yum install wget
   [[ $(which zypper) ]] && sudo zypper install wget
fi

mkdir -p ./bin
wget -P ./bin https://raw.githubusercontent.com/rubenmromero/git-matrix/master/git_matrix.sh
chmod 755 ./bin/git_matrix.sh
