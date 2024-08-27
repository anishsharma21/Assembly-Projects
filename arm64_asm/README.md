# How to Assemble and Link ARM64 RISC Assembly Programs on Apple Silicon MacOS

## Prerequisites

- Ensure you have `clang` installed. Check by typing:
```sh
clang -v
```

## Writing an ARM64 Assembly Program

Write your program in ARM64 assembly. Here's an example:

```nasm
.global _main

_main:
  mov x0, #1
  mov x16, #1
  svc #0
```

Save this file as `exit.asm`.

## Program Explanation

This program sets the exit code to `1` in register `x0`, and prepares for the exit syscall by moving `1` into the `x16` register. Note that:

- `x0` - `x30` are general purpose registers.
- `x30` also serves as the return address register for function calls.
- `SP` and `PC` are registers for the stack pointer and program counter, respectively.

## Assembling and Linking

Assembling converts human-readable assembly code into machine code specific to the ISA (Instruction Set Architecture) of the machine (in this case, ARM64). This process creates an object file (`.o` or `.obj`), which is then linked into an executable.

### One-Step Assembly and Linking with `clang`

If `clang` is installed, you can assemble and link your program in one step:

```sh
clang -o exit exit.asm -arch arm64
```

This command produces an executable file named `exit`.

### Running your program

To run the executable, use the command:

```sh
./exit
```

This program will start and immediately exit as intended.

### Debugging with `lldb`

You can debug your program using `lldb`. To start debugging, run:

```sh
lldb exit
```

### Basic `lldb` Commands

Set a breakpoint at `main`:

```sh
b main
```

Run the program:

```sh
run
```

Read the current state of registers:

```sh
register read
```

Step through the program one instructoin at a time:

```sh
si
```

Continue execution until the next breakpoint:

```sh
c
```

Quit the debugger:

```sh
quit
```

### Listing symbols

If you're unsure of the symbol names, use:

```sh
image dump symtab filename
```

## Example Program for Debugging

The following program is more suitable for debugging (called `simple_add.asm` under the `simple_add_asm` directory):

```nasm
.global _main

_main:
  mov x0, #5
  mov x1, #3
  add x2, x1, x0
  mov x16, #1
  mov x0, #0
  svc #0
```

This program adds two numbers together and then exits. You can check the register values to confirm that it runs correctly.
