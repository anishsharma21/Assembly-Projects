# EarlyLangs

## Introduction

This repository is dedicated to exploring early programming languages, starting with assembly language for the x86 architecture on GNU/Linux.

## Getting Started

### Prerequisites

- Docker installed on your machine. You can download and install Docker from [here](https://www.docker.com/products/docker-desktop).

### Building the Docker Image

1. Clone this repository to your local machine:

    ```sh
    git clone https://github.com/anishsharma21/EarlyLangs
    cd EarlyLangs
    ```

2. Build the Docker image:

    ```sh
    docker build -t earlylang-env .
    ```

### Running the Docker Container

1. Run the Docker container:

    ```sh
    docker run -it --rm -v "$(pwd)":/usr/src/app earlylang-env
    ```

    This command will:
    - `-it`: Run the container in interactive mode with a terminal.
    - `--rm`: Automatically remove the container when it exits.
    - `-v "$(pwd)":/usr/src/app`: Mount the current directory to `/usr/src/app` in the container.
    - `earlylang-env`: The name of the Docker image.

2. You will now be inside the Docker container. You can compile and run your assembly code here.

### Accessing the Running Container from Another Terminal

1. Find the Container ID:

    ```sh
    docker ps
    ```

    Note the `CONTAINER ID` of the running container.

2. Attach to the running container:

    ```sh
    docker exec -it <CONTAINER_ID> /bin/bash
    ```

    Replace `<CONTAINER_ID>` with the actual ID of your running container.

## Example Assembly Program

You can create an assembly file, for example `hello.asm`, in your repository:

```asm
section .data
    hello db 'Hello, world!',0

section .text
    global _start

_start:
    ; write our string to stdout
    mov eax, 4
    mov ebx, 1
    mov ecx, hello
    mov edx, 13
    int 0x80

    ; exit
    mov eax, 1
    xor ebx, ebx
    int 0x80
