# Git-Matrix

Script to manage Git projects with multiple submodules and multiple branches per repository.

## What is Git-Matrix?

If you have several initialized submodules in your project, and you handle several branches both in the project as in the related submodules, then you have a Git-Matrix case:

                 =======================================
                 ||          B R A N C H E S          ||
                 ---------------------------------------
                 ||  1  |  2  |  3  |  4  | ... |  X  ||
    ====================================================
    ||  S  |  1  ||     |     |     |     |     |  X  ||
    ||  U  |--------------------------------------------
    ||  B  |  2  ||  G  |     |     |     |  I  |     ||
    ||  M  |--------------------------------------------
    ||  O  |  3  ||     |  I  |     |  R  |     |     ||
    ||  D  |--------------------------------------------
    ||  U  |  4  ||     |     |  T  |     |     |     ||
    ||  L  |--------------------------------------------
    ||  E  | ... ||     |  A  |     |     |     |     ||
    ||  S  |--------------------------------------------
    ||     |  Y  ||  M  |     |     |     |     |     ||
    ====================================================

## How does it work?
