#!/bin/bash

#
# Commands Definition
#
ECHO="echo -e"
TPUT_BOLD="tput bold"
TPUT_OFF="tput sgr0"

#
# Variables Definition
#
ENV_BRANCHES=(develop master)
NUM_BRANCHES=${#ENV_BRANCHES[@]}

#
# Function for print the script execution mode
#
print_exec_mode ()
{
   $ECHO "\n\tEXECUTION MODE =>\t$0 [-h|--help] [-k|--keep]"
   $ECHO "\n\tOptions:"
   $ECHO "\t\t-h, --help\tShow this help message and exit"
   $ECHO "\t\t-k, --keep\tKeep the current commit of each submodule"
   $ECHO "\t\t\t\t(no effect on the first environment branch of the project)\n"
}

#
# Check the execution procedure used
#
if [[ $1 == '-h' || $1 == '--help' ]]
then
   print_exec_mode
   exit 0
fi

if [[ $1 == '-k' || $1 == '--keep' ]]
then
   UPDATE_SUBMODULES=0
else
   UPDATE_SUBMODULES=1
fi

#
# Initial checks and provisions
#

# Change position to the project root directory
cd $(dirname $0)/../

$ECHO "\n$($TPUT_BOLD)Update the active local branch of the project and submodules status:$($TPUT_OFF)"
git pull
git submodule init
git submodule update

# Get the submodules configured in the project
SUBMODULES=$(git submodule status |awk '{print $2}')

# Check if the project has any submodule
if [[ -z $SUBMODULES ]]
then
   $ECHO "\n$($TPUT_BOLD)The project has not any submodule$($TPUT_OFF)\n"
   exit 1
fi

# Update the environment branches of each submodule
for SUBMODULE in $SUBMODULES
do
   cd $SUBMODULE

   $ECHO "\n$($TPUT_BOLD)Update the environment branches of '$SUBMODULE' submodule:$($TPUT_OFF)"
   git fetch -p
   for BRANCH in ${ENV_BRANCHES[@]}
   do
      git checkout $BRANCH
      [[ $(git diff origin/$BRANCH --exit-code) ]] && git pull origin $BRANCH
   done

   for FOLDER in $(echo $SUBMODULE |sed "s/\// /g")
   do
      cd ..
   done

   # Restore the submodule status to the currently pointed commit in the project
   git submodule update $SUBMODULE
done

PROJECT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

#
# Main
#
if [[ $PROJECT_BRANCH == ${ENV_BRANCHES[0]} ]]
then
   $ECHO "\n$($TPUT_BOLD)The project active branch is '${ENV_BRANCHES[0]}', therefore each submodule is directly pointed to HEAD of his '${ENV_BRANCHES[0]}' branch:$($TPUT_OFF)"
   for SUBMODULE in $SUBMODULES
   do
      cd $SUBMODULE

      $ECHO "\n$($TPUT_BOLD)'$SUBMODULE' submodule:$($TPUT_OFF)"
      git checkout ${ENV_BRANCHES[0]}
      git branch -av

      for FOLDER in $(echo $SUBMODULE |sed "s/\// /g")
      do
         cd ..
      done
   done
else
   for ((i=1; i<$NUM_BRANCHES; i++))
   do
      if [[ $PROJECT_BRANCH == ${ENV_BRANCHES[$i]} ]]
      then
         $ECHO "\n$($TPUT_BOLD)The project active branch is '$PROJECT_BRANCH'. Do merge from '${ENV_BRANCHES[${i}-1]}' branch belonging to the previous environment:$($TPUT_OFF)"
         git checkout ${ENV_BRANCHES[${i}-1]}
         git pull origin ${ENV_BRANCHES[${i}-1]}
         git checkout ${ENV_BRANCHES[$i]}
         git merge ${ENV_BRANCHES[${i}-1]}
      fi
   done

   for SUBMODULE in $SUBMODULES
   do
      cd $SUBMODULE
      $ECHO "\n$($TPUT_BOLD)Current commit of '$SUBMODULE' submodule in '$PROJECT_BRANCH' branch of the project:$($TPUT_OFF)"
      git branch -v |grep "^*"

      $ECHO "\n$($TPUT_BOLD)Environment branches of '$SUBMODULE' submodule:$($TPUT_OFF)"
      typeset -i OPTION=1
      for BRANCH in ${ENV_BRANCHES[@]}
      do
         BRANCH_INFO=$(git branch -v |sed "s/^..//g" |awk -v "branch=$BRANCH" '$1 == branch')
         [[ $BRANCH == $PROJECT_BRANCH ]] && DEF_OPTION=$OPTION
         $ECHO "${OPTION}) $BRANCH_INFO"
         OPTION=${OPTION}+1
      done

      if [[ $UPDATE_SUBMODULES -eq 1 ]]
      then
         $ECHO "${OPTION}) Keep the current commit"

         $ECHO "\n$($TPUT_BOLD)Select the number of branch to activate:$($TPUT_OFF) [$DEF_OPTION] \c"
         read SELECTION
         if [[ -z $SELECTION || $SELECTION -lt 1 || $SELECTION -gt $OPTION ]]
         then
            SELECTION=$DEF_OPTION
         fi

         for ((i=1; i<$OPTION; i++))
         do
            [[ $SELECTION -eq $i ]] && git checkout ${ENV_BRANCHES[${i}-1]}
         done
      fi

      for FOLDER in $(echo $SUBMODULE |sed "s/\// /g")
      do
         cd ..
      done
   done
fi

for SUBMODULE in $SUBMODULES
do
   # Check if the submodule commit has changed
   if [[ $(git diff --exit-code $SUBMODULE) ]]
   then
      git add $SUBMODULE

      cd $SUBMODULE
      ACTIVE_BRANCH=$(git rev-parse --abbrev-ref HEAD)
      for FOLDER in $(echo $SUBMODULE |sed "s/\// /g")
      do
         cd ..
      done

      if [[ -z $COMMIT_MSG ]]
      then
         if [[ $ACTIVE_BRANCH == 'HEAD' ]]
         then
            COMMIT_MSG="* Keep '$SUBMODULE' submodule in the previous commit of this branch"
         else
            COMMIT_MSG="* Update '$SUBMODULE' submodule to HEAD of '$ACTIVE_BRANCH' branch"
         fi
      else
         if [[ $ACTIVE_BRANCH == 'HEAD' ]]
         then
            COMMIT_MSG=$($ECHO "${COMMIT_MSG}\n* Keep '$SUBMODULE' submodule in the previous commit of this branch")
         else
            COMMIT_MSG=$($ECHO "${COMMIT_MSG}\n* Update '$SUBMODULE' submodule to HEAD of '$ACTIVE_BRANCH' branch")
         fi
      fi
   fi
done

# Commit changes if exists commit message
if [[ ! -z $COMMIT_MSG ]]
then
   $ECHO "\n$($TPUT_BOLD)List of updates to commit in '$PROJECT_BRANCH' branch of the project:$($TPUT_OFF)"
   $ECHO "$COMMIT_MSG\n"
   git commit -m "$COMMIT_MSG"
fi

if [[ $(git diff --exit-code origin/$PROJECT_BRANCH --) ]]
then
   $ECHO "\n$($TPUT_BOLD)Final status of project branches:$($TPUT_OFF)"
   git branch -av
   cat <<_EOF

To publish the local commits use:

	git push origin $PROJECT_BRANCH

To revert the local commits to HEAD of remote branch execute:

	git reset --hard origin/$PROJECT_BRANCH
_EOF
fi

$ECHO
