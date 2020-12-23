PROGRAM		= mlisp
OBJS		= mlisp.tab.o lex.yy.o node.o messages.o
SRCS		= mlisp.tab.cpp lex.yy.c node.cpp messages.cpp
CC			= g++
# CPPFLAGS	= -Og -std=c++17 -g
CPPFLAGS	= -O2 -std=c++17
# BISONFLAGS	= -dvt --debug
BISONFLAGS	= -d

all:		$(PROGRAM)

.c.o:
			$(CC) -c $(CFLAGS) $(CPPFLAGS) -o $@ $<

.cpp.o:
			$(CC) -c $(CFLAGS) $(CPPFLAGS) -o $@ $<

mlisp.tab.cpp mlisp.tab.hpp:	mlisp.y
								bison mlisp.y -o mlisp.tab.cpp $(BISONFLAGS)

lex.yy.c:						mlisp.l
								flex -I mlisp.l

mlisp:							$(OBJS)
								$(CC) $(CPPFLAGS) $(OBJS) -o $@

clean:
								rm -f $(OBJS) mlisp.tab.cpp mlisp.tab.hpp lex.yy.c mlisp.output