#!/bin/bash

mkdir -p ./bin
read -p "Enter the ordered list of environment branches to manage, separated by spaces: [develop master] " BRANCHES
if [[ -z $BRANCHES ]]
then
   curl --silent --output ./bin/git_matrix.sh https://raw.githubusercontent.com/rubenmromero/git-matrix/master/git_matrix.sh
else
   curl --silent https://raw.githubusercontent.com/rubenmromero/git-matrix/master/git_matrix.sh |sed "s/ENV_BRANCHES=(.*)/ENV_BRANCHES=($BRANCHES)/g" >./bin/git_matrix.sh
fi
chmod 755 ./bin/git_matrix.sh

echo -e "\nFanfare! Git-Matrix has been configured in your project!"
echo -e "\nExecution Method:\n"
set -o verbose
./bin/git_matrix.sh --help
