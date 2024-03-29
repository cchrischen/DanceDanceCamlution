# DDR - Installation Guide
1. Begin by installing the necessary OPAM packages for this project.
    ```shell
    opam update
    opam upgrade
    opam install raylib batteries
    ```
2. Run the program
    ```shell
    dune build
    dune exec bin/main.exe
    ```