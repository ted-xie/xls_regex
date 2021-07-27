CXX ?= g++
CXXFLAGS ?= -Werror -O3
BISONFLAGS=-Werror -v

regex.tab.h: regex.y
	bison -d ${BISONFLAGS} $<

regex.tab.c: regex.y
	bison ${BISONFLAGS} $<

lex.yy.c: regex.l  regex.tab.h
	flex $<

lex: lex.yy.c regex.tab.h
	${CXX} ${CXXFLAGS} $< -o $@

parser: lex.yy.c regex.tab.c
	${CXX} ${CXXFLAGS} $^ -o $@

