#!/bin/bash

mkdir -p ./bin
echo -e "\nSpecify the environment branches to manage in your project: \c"
read BRANCHES
curl --silent https://raw.githubusercontent.com/rubenmromero/git-matrix/master/git_matrix.sh |sed "s/ENV_BRANCHES=(.*)/ENV_BRANCHES=($BRANCHES)/g" >./bin/git_matrix.sh
chmod 755 ./bin/git_matrix.sh
