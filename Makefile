kek: kek.y
	bison -d kek.y
	flex kek.l
	g++ kek.tab.c lex.yy.c -lfl -o kek