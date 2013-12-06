.SUFFIXES: .o .c
EXEC = grid-world
CC = gcc

CFLAGS = -O2 -I/usr/dt/share/include/
INCLUDE = -I/usr/openwin/share/include/X11/


LIBS = -L/opt/lib/ -L/usr/dt/lib/ -lXm -lXt -lX11 -lm -lnsl  -lsocket -lgen
LIBS2 = -L/usr/openwin/lib/ -lXm -lXt -lX11 -lm -lnsl  -lsocket -lgen

.c.o:
	$(CC) $(CFLAGS) -c $*.c

all: grid_world

grid_world:  grid-world.o graphics.o qlearner.o display.o krandom.o
#
#
	$(CC) -O2 -o grid_world krandom.o grid-world.o graphics.o qlearner.o display.o  $(CFLAGS) $(INCLUDE) $(LIBS) $(LIBS2)

display.o:		display.h
graphics.o:		graphics.h
grid-world.o:		grid-world.h
qlearner.o:		qlearner.h
krandom.o:		krandom.c

##
##
##      end of make file
##
clean:
	rm -f *.o *.a *~



