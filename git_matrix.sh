#!/bin/bash

#
# Commands Definition
#
ECHO="echo -e"

#
# Variables Definition
#
ENV_BRANCHES=(develop master)
NUM_BRANCHES=${#ENV_BRANCHES[@]}

#
# Initial checks and preparations
#

# Change position to the global project root folder
cd $(dirname $0)/../

# Get the application submodules configured in the global project
APPL_SUBMODULES=$(git submodule status |awk '{print $2}')

# Check if the global project is a multirepo project
if [[ -z $APPL_SUBMODULES ]]
then
   $ECHO "\n$(tput bold)The project has not any application submodule$(tput sgr0)\n"
   exit 1
fi

# Update the environment branches of each application submodule
for SUBMODULE in $APPL_SUBMODULES
do
   cd $SUBMODULE

   $ECHO "\n$(tput bold)Update the environment branches of '$SUBMODULE' submodule:$(tput sgr0)"
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
   $ECHO "\n$(tput bold)The project active branch is '${ENV_BRANCHES[0]}', therefore each application submodule is directly pointed to HEAD of his '${ENV_BRANCHES[0]}' branch:$(tput sgr0)"
   for SUBMODULE in $APPL_SUBMODULES
   do
      cd $SUBMODULE

      $ECHO "\n$(tput bold)'$SUBMODULE' submodule:$(tput sgr0)"
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
         $ECHO "\n$(tput bold)The project active branch is '$PROJECT_BRANCH'. Do merge from the '${ENV_BRANCHES[${i}-1]}' branch belonging to the previous environment:$(tput sgr0)"
         git merge ${ENV_BRANCHES[${i}-1]}
      fi
   done

   for SUBMODULE in $APPL_SUBMODULES
   do
      cd $SUBMODULE
      $ECHO "\n$(tput bold)Current commit of '$SUBMODULE' submodule in '$PROJECT_BRANCH' branch of the project:$(tput sgr0)"
      git branch -v |grep "^*"

      $ECHO "\n$(tput bold)Environment branches of '$SUBMODULE' submodule:$(tput sgr0)"
      typeset -i OPTION=1
      for BRANCH in ${ENV_BRANCHES[@]}
      do
         BRANCH_INFO=$(git branch -v |sed "s/^..//g" |awk -v "branch=$BRANCH" '$1 == branch')
         [[ $BRANCH == $PROJECT_BRANCH ]] && DEF_OPTION=$OPTION
         $ECHO "${OPTION}) $BRANCH_INFO"
         OPTION=${OPTION}+1
      done
      $ECHO "${OPTION}) Keep the current commit"

      $ECHO "\n$(tput bold)Select the number of branch to activate:$(tput sgr0) [$DEF_OPTION] \c" 
      read SELECTION
      if [[ -z $SELECTION || $SELECTION -lt 1 || $SELECTION -gt $OPTION ]]
      then
         SELECTION=$DEF_OPTION
      fi

      for ((i=1; i<$OPTION; i++))
      do
         [[ $SELECTION -eq $i ]] && git checkout ${ENV_BRANCHES[${i}-1]}
      done

      for FOLDER in $(echo $SUBMODULE |sed "s/\// /g")
      do
         cd ..
      done
   done
fi

for SUBMODULE in $APPL_SUBMODULES
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
   $ECHO "\n$(tput bold)List of updates to commit in '$PROJECT_BRANCH' branch of the project:$(tput sgr0)"
   $ECHO "$COMMIT_MSG\n"
   git commit -m "$COMMIT_MSG"
fi
