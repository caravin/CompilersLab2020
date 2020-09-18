grp14_3_2:	grp14_3_2.l grp14_3_2.y
		bison -d grp14_3_2.y
		flex grp14_3_2.l
		gcc -o $@ grp14_3_2.tab.c lex.yy.c -lfl
		
clean:	grp14_3_2 grp14_3_2.tab.c grp14_3_2.tab.h lex.yy.c
		rm grp14_3_2 grp14_3_2.tab.c grp14_3_2.tab.h lex.yy.c