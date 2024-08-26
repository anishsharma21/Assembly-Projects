# How to compile and execute FORTRAN code

If you have the delight to be programming in FORTRAN, you'll probably want to compile and execute the code you have written. I write all my programs on the MacOS, so these instructions are for MacOS users.
First, you can use the following command to check whether you have `gcc` installed locally:

```sh
gcc --version
```

The `gcc` is the GNU Compiler Collection and has a number of tools and, well, compilers that allow you to turn your programs into executable machine code for your CPU. If you do not have `gcc` installed, you can use the following command on MacOS to install it:

```sh
brew install gcc
```

Of course, this assumes you also have `brew` insalled locally. If you don't, just search it up and run the command - its pretty simple :).

Now, it might take a while, but you should have `gcc` installed. You can write a little program, something like the following:

```fortran
program hello
    print *, "Hello, World!"
end program hello
```

Then use the following command to compile it:

```sh
gfortran -o hello hello.f90
```

Yep, the file extension is `.f90` - pretty cool. Anyways, you should have a file called `hello` sitting in the same directory - this is your executable file. 

Now you can just type in `./hello` and see your first program run!
