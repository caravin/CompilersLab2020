change present working directory to firstPass perform a make.

cd firstPass
make

This creates files intermediate.txt and symtab.txt which contains intermediatee code and symbol table respectively.
now navigate to secondPass directory as follows

cd ../secondPass

now perform the following command to create the executable file.

make

now to see the mips instructions code of a testcase from the input subdirectory of firstPass type the following

cd ../firstPass
./execute.sh input-bubblesort.c 

where input-bubblesort.c is a name of a file from input folder.
The intermediate code,symbol table and mips instructions are stored in output folder of main directory.