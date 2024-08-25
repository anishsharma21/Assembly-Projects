# EarlyLangs

## Introduction

This repository is dedicated to exploring early programming languages, starting with x86 assembly language and moving on to ARM64 assembly with the RISC ISA. The goal is to understand the fundamentals of low-level programming and the architecture of different processors. By learning at a lower level of abstraction, I hope to gain a deeper understanding of how computers work, how programming languages operate, and the hardware that underpins everything.

Learning at this level provides a source of creativity and a different perspective, allowing me to understand where modern programming comes from and how it has evolved. By tracing the timeline from the earliest forms of programming, I hope to follow the leaps of understanding and see why certain decisions were made, rather than jumping straight into high-level abstractions. This approach ensures that I am not just learning at the leaves and twigs of the tree of knowledge, but understanding the trunk and following along chronologically to grasp the progression of computer science.

## Project Overview

### x86 Assembly

Initially, the project focused on x86 assembly language for the GNU/Linux environment. To facilitate development and ensure a consistent environment, the x86 assembly programs were containerised using Docker. This allowed for easy setup and execution of the programs on any machine with Docker installed... or so I thought. The reality was that unless I was using an emulator like `qemu`, I couldn't write assembly programs targetting x86 architecture (with 32 bit registers) on an ARM64 machine, or at least not as seamlessly as with ARM64 assembly.

### ARM64 Assembly

The project has now transitioned to exploring ARM64 assembly language with the RISC ISA. Since I am developing on a ARM64 based Mac (M3 chip), I can use the xcode tools and specifically `clang` to both assemble and link my assembly programs, making the process of writing and executing assembly programs much easier. Resources for ARM64 assembly are pretty scarce or quite terse, so its a solid challenge overall - but, I found [this really good video](https://www.youtube.com/watch?v=rg6kU42LQcY) that will get anyone with an M-chip mac up to scratch with ARM64 assembly programming on their mac's.
