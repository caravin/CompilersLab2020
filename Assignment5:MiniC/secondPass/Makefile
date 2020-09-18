inter:	intcode_proc.l intcode_proc.y secondpass_parser.c
	bison -d intcode_proc.y
	flex intcode_proc.l
	 g++ --std=c++11 -o $@ intcode_proc.tab.c lex.yy.c
clean:	inter intcode_proc.tab.c intcode_proc.tab.h lex.yy.c
	rm inter intcode_proc.tab.c intcode_proc.tab.h lex.yy.c