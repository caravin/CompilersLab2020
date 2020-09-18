#!/bin/sh

rm output/intermediate.txt 
rm output/symtab.txt
rm ../secondPass/mips.s 
sleep 1

./intcode_gen < "input/"$1
cd ../secondPass
./inter < ../firstPass/output/intermediate.txt
cat mips.s >../output/mips.s
cd ../firstPass/output/
cp intermediate.txt ../../output/intermediatecode.txt
cp symtab.txt ../../output/symboltable.txt
echo "\n SymbolTable generated \n"
echo "the MIPS code is as follows: \n"
cat ../../output/mips.s
cd ..