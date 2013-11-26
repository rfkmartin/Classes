#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/utsname.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <signal.h>

#define TRUE 1
#define FALSE 0
#define PRINTF 0

#define WHITE " \t"
#define PIPE "|"
#define PIPE_ERR "|&"
#define REDIR_IN "<"
#define REDIR_OUT ">"
#define REDIR_OUT_APP ">>"
#define REDIR_ERR ">&"
#define REDIR_ERR_APP ">>&"
#define BACKG "&"
#define PATHDEL ":"

#define MAXLNLEN 2050
#define MAXCMDLEN 259
#define MAXCMD 30
#define MAXARGS 50

#define NODIR "No such file or directory\n"
#define NOFINDERR ":  Command Not Found.\n"
#define NOEXECERR ":  Permission Denied.\n"
#define PATHIS "PWD="

extern int isBackground;
extern int inputIsRedirected;
extern int outputIsRedirected;
extern int errorIsRedirected;
extern int appendYes;

extern char **environ;
extern char actualPath[MAXCMDLEN];
