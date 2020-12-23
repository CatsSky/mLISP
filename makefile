PROGRAM		= mlisp
OBJS		= mlisp.tab.o lex.yy.o node.o messages.o
SRCS		= mlisp.tab.cpp lex.yy.c node.cpp messages.cpp
CC			= g++
CPPFLAGS	= -Og -std=c++17 -g

all:		$(PROGRAM)

.c.o:
			$(CC) -c $(CFLAGS) $(CPPFLAGS) -o $@ $<

.cpp.o:
			$(CC) -c $(CFLAGS) $(CPPFLAGS) -o $@ $<

mlisp.tab.cpp mlisp.tab.hpp:	mlisp.y
								bison -dv mlisp.y -o mlisp.tab.cpp --debug -t

lex.yy.c:						mlisp.l
								flex -I mlisp.l

mlisp:							$(OBJS)
								$(CC) $(CPPFLAGS) $(OBJS) -o $@

clean:
								rm -f $(OBJS) mlisp.tab.cpp mlisp.tab.hpp lex.yy.c mlisp.output