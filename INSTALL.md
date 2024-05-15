# DDC - Installation Guide
The respective OCaml and Python package installers, opam and pip, are assumed prerequisites for this installation.

1. Begin by installing the necessary OPAM packages for this project.
    ```shell
    opam update
    opam upgrade
    opam install raylib batteries raygui csv
    ```
2. Install the python packages.
    ```shell
    pip install -r lib/beatmap-python/requirements.txt
    ```
3. Run the program
    ```shell
    dune build
    dune exec bin/main.exe
    ```
