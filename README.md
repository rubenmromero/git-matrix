# Git-Matrix

Script to manage Git projects with multiple submodules and multiple environment branches per repository.

## What is a Git-Matrix?

If you have several initialized submodules in your project, and you handle several environment branches both in the project as in the related submodules, then you have a Git-Matrix case:

                            -------------------------------------
                            |  B  |  B  |  B  |  B  |     |  B  |
                            |  R  |  R  |  R  |  R  |     |  R  |
                            |  A  |  A  |  A  |  A  |     |  A  |
                            |  N  |  N  |  N  |  N  | ... |  N  |
                            |  C  |  C  |  C  |  C  |     |  C  |
                            |  H  |  H  |  H  |  H  |     |  H  |
                            |  1  |  2  |  3  |  4  |     |  X  |
    ------------------------|-----|-----|-----|-----|-----|-----|
    |  S U B M O D U L E 1  |     |     |     |     |     |  X  |
    |-----------------------|-----|-----|-----|-----|-----|-----|
    |  S U B M O D U L E 2  |  G  |     |     |     |  I  |     |
    |-----------------------|-----|-----|-----|-----|-----|-----|
    |  S U B M O D U L E 3  |     |  I  |     |  R  |     |     |
    |-----------------------|-----|-----|-----|-----|-----|-----|
    |  S U B M O D U L E 4  |     |     |  T  |     |     |     |
    |-----------------------|-----|-----|-----|-----|-----|-----|
    |         . . .         |     |  A  |     |     |     |     |
    |-----------------------|-----|-----|-----|-----|-----|-----|
    |  S U B M O D U L E Y  |  M  |     |     |     |     |     |
    -------------------------------------------------------------

## How does it work?

You directly move across the project environment branches using the usual Git commands such as `git checkout <branch>` or any other similar.

Being positioned at the branch you want to update, you can directly run the `./bin/git_matrix.sh` script from the project root folder, which performs the following tasks:

* Updates the active local branch (`git pull`) and submodules status (`git submodule init` & `git submodule update`).
* Updates all environment branches of each submodule.
* If the active branch is the first environment branch (the branch defined in the first position), the script directly does the following actions:
    * Positions each submodule in the last commit (HEAD) of its first environment branch.
    * Commits the produced changes by the previous action, in the event that there are, including as commit message the list of updates done by the script.
* If the active branch is any other different from the first, there are the following execution alternatives:
    * If the script has been executed with the `[-k|--keep]` optional parameter,it directly perfoms the following actions:
        * Merges the previous environment branch in order to propagate the commited and pushed changes made in the previous environment/s of the project.
