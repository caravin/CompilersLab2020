intcode_gen:	intcode_gen.l intcode_gen.y first_pass2.c first_pass1.c
	bison -d intcode_gen.y
	flex intcode_gen.l
	g++ -o $@ intcode_gen.tab.c lex.yy.c first_pass2.c first_pass1.c
clean:	intcode_gen intcode_gen.tab.c intcode_gen.tab.h lex.yy.c
	rm intcode_gen intcode_gen.tab.c intcode_gen.tab.h lex.yy.c