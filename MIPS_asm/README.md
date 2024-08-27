# How to run MIPS Assembly on Apple Silicon MacOS

## Prerequisites

Ensure you have `spim` installed. `spim` allows you to simulate the execution of MIPS programs.

```sh
brew install spim
```

## Writing a MIPS program

Here's a simple example that starts and then immediately exits:

```mips
    .data         # data section

    .text         # code section

main:
    li $v0, 10    # syscall 10 is exit
    syscall       # call the kernel
```

Save this file as `exit.asm`.

## Running the MIPS program

Run the following command:

```sh
spim -file exit.asm
```

This will run the file, and since it only exits, nothing will happen (which is good).

Here's an example MIPS program that prints something to the console:

```mips
    .data

helloworld: .asciiz "Hello, World!\n"     # declare a string

    .text
    .globl main                           # make the main function globally accessible

main:
    li $v0, 4                             # syscall 4 is print_str
    la $a0, helloworld                    # load the address of the string into $a0
    syscall                               # call the kernel

    li $v0, 10                            # syscall 10 is exit
    syscall                               # call the kernel
```

Running this program should print "Hello, World!" to the terminal.

You can also run the `spim` simulator in its environment, i.e. not in the default terminal environment by just running the command `spim`. After this, you can run the command `load "{filename}"`, or in this case, `load "exit.asm"` and then `run` to start running the program. You can use the command `step` to step through the program. You can use `print $reg` to print specific registers, e.g. `print $0` to print the first register. You can see all the registers using `print_all_regs`. [This link](https://course.ccs.neu.edu/csu4410/spim_documentation.pdf) is a 25 page breakdown of how to use SPIM, and [this link](https://pages.cs.wisc.edu/~larus/spim.pdf) is a 2 page concise summary.