# 🏛️ EarlyLangs

## Summary and Highlights

* Text editor of choice: ![Vim](https://img.shields.io/badge/-Vim-333333?style=flat&logo=vim)&nbsp;
* Brief work in `x86` and `ARMv8` assembly
* Over 30 `MIPS` assembly programs - wrote the following in `MIPS` assembly:
    * Recursive factorial & fibonnaci (stack pointer manipulation)
    * Bubble sort, insertion sort, binary search
    * Sieve of Eratosthenes
    * Linked List
    * `malloc` and `free` in assembly (in progress)

## Introduction

Modern software development is complex and chaotic. Junior's (like myself) are taught serverless deployment of dockerised container SPA applications running in a JIT compiled environment, using a non-blocking, event-loop driven language... before we're even taught the basics of boolean logic. I had no clue how a web server actually worked, where computers came from, why 1's and 0's represent instructions and memory - I knew none of that - not even how my little Python scripts get turned into executable programs. So, I wanted to return to first principles and learn computer science from the ground up, from the lowest layers of abstraction. I wanted to see how things fit into the bigger picture. Hence, this repo. I start with some assembly programming, then early programming languages, and finish up with some C/C++. After laying this foundation, I'll be able to tackle compilers, operating systems, networking, concurrency, and so much more - and it'll all just make more sense :)

It should be noted though that even assembly programming isn't the lowest level of abstraction - that would be digital logic and microarchitecture. If you're keen on diving deeper into that, I highly recommend *CODE: The Hidden Language of Computer Hardware and Software* by Charles Petzold. It's a fantastic, beginner-friendly book that takes you from lightbulbs and switches to a fully functioning processor, similar in capability to one of the first commercially available computers to hackers in the 70's - the Altair 8800. You can even create your own breadboard computer and custom assembly language! Check out my [Memory Map Emulator](https://github.com/anishsharma21/Memory-Map-Emulator) inspired by this book.

This repo doesn't assume prior knowledge of digital logic or microarchitecture, but having that foundation helps. Each directory in this repo relates to a different programming language, with README files to help you set up your environment - at least if you're on macOS (I'm running Apple Silicon with macOS Sonoma). If you're on a different OS, steps might vary, and you'll need to do some investigating. If you find solutions or mistakes, feel free to open an issue! With these guides, you can write and run programs, enjoy low-level programming, and gain a deep understanding of how the field has evolved too.

## Project Logs

### x86 Assembly

Initially, the project focused on x86 assembly language for the GNU/Linux environment. To facilitate development and ensure a consistent environment, the x86 assembly programs were containerised using Docker. This allowed for easy setup and execution of the programs on any machine with Docker installed... or so I thought. The reality was that unless I was using an emulator like `qemu`, I couldn't write assembly programs targetting x86 architecture (with 32 bit registers) on an ARM64 machine, or at least not as seamlessly as with ARM64 assembly.

### ARM64 Assembly

The project then transitioned to exploring ARM64 assembly language with a RISC (reduced instruction set computing) ISA. Since I am developing on a ARM64 based Mac (M3 chip), I can use the xcode tools and specifically `clang` to both assemble and link my assembly programs, making the process of writing and executing assembly programs much easier. Resources for ARM64 assembly are pretty scarce or quite terse, so its a solid challenge overall - but, I found [this really good video](https://www.youtube.com/watch?v=rg6kU42LQcY) that will get anyone with an M-chip mac up to scratch with ARM64 assembly programming on their mac's.

### MIPS Assembly

While the resources for ARM64 assembly language were better for my set up (MacOS + Apple silicon), there were still lofty barriers in the way of exploring more complex concepts like procedures, heap + stack allocation, or even writing systems software. As a result, I decided to look into MIPS - which stands for Microprocessor without Interlocked Pipeline Stages. Like ARM, its also a RISC architecture, and was made also for education purposes, so there were plenty of resources to learn from. Additionally, I was working through the book *Computer Organization and Design: The Hardware/Software Interface*, which uses MIPS as its main assembly language to illustrate concepts and programs - so being able to write MIPS on my mac made following along with this book much more effective. In particular, I was using the `SPIM` simulator/cross-assembler (which I installed using `brew install spim`) to assemble my MIPS programs and run them with a set of `spim` commands.
Had the most fun and experience with MIPS - asked AI to give me 20 beginner, intermediate, and advanced exercises, and completed them in order - super useful tactic to learn the language, cover the basics, and build/apply your knowledge. I spent a lot of time programming in MIPS and learnt a lot of useful, fundamental programming concepts like memory allocation, the stack, the heap, recursion, loops, branching, conditional flow, etc.
