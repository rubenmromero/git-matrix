# Git-Matrix

Script to manage Git projects with multiple submodules and multiple branches per repository.

## What is Git-Matrix?

If you have several initialized submodules in your project, and you handle several branches both in the project as in the related submodules, then you have a Git-Matrix case:

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
