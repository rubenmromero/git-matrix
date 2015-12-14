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

The `git_matrix.sh` script works in the following way:

* You directly move across the project environment branches using the usual Git commands such as `git checkout <branch>` or any other similar.
* Being positioned at the branch you want to update, you can directly run the `./bin/git_matrix.sh` script from the project root folder, witch in a first step updates the active local branch (`git pull`) and submodules status (`git submodule init` & `git submodule update`).
* If the active branch is the environment branch defined in the first position, the script directly do the following actions:
    * 
