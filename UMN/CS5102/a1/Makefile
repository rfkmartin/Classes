MAKEFILE = ./Makefile

DEBUG		= 
ANSI		= -Aa
CFLAGS	= -I./ -I../include -I/usr/include -I/usr/include/sys \
				-I/usr/include/netinet -D_INCLUDE_HPUX_SOURCE \
				-D_INCLUDE_XOPEN_SOURCE -D_INCLUDE_POSIX_SOURCE \
				$(DEBUG) $(ANSI) $(PF)
LIBS		= -lsocket -lnsl
LIBINET	=
DELOBJ	= 

batch:	server

server:	server.c $(MAKEFILE)
	$(CC) $(CFLAGS) server.c $(LIBS) -o $@
	$(DELOBJ)
