assn4:	assn4.l assn4.y
		bison -d assn4.y
		flex assn4.l
		gcc -o $@ assn4.tab.c lex.yy.c -lfl
		
clean:	assn4 assn4.tab.c assn4.tab.h lex.yy.c
		rm assn4 assn4.tab.c assn4.tab.h lex.yy.c ans.cpp a.out
