#include "builtin.h"
#include "main.h"

int isBuiltin(char *arg)
{

	if (strcmp(arg, "cd") == 0)
		return 1;
	else if (strcmp(arg, "pwd") == 0)
		return 1;
	else
		return 0;
}

int doBuiltin(char *arg, char *arg2, char *envp[])
{
	static char temp[MAXCMDLEN];
	static char temp2[MAXCMDLEN];
	char *tmp;

	if (strcmp(arg, "cd") == 0)
		{ /* No error checking; assuming directory exists */
		strcpy(temp, arg2);
		if (temp[0] == '/') /* absolute pathname ? */
			{
			temp[strlen(temp) - 1] = '\0';
			chdir(temp);
			strcpy(temp2, PATHIS);
			strcat(temp2, temp);
			putenv(temp2);
			}
		else if (strcmp(temp, "") ==0)
			{
			strcpy(temp, getenv("HOME"));
			chdir(temp);
			strcpy(temp2, PATHIS);
			strcat(temp2, temp);
			putenv(temp2);
			}
		else 
			{
			tmp = malloc(MAXLNLEN);
			getcwd(tmp, MAXLNLEN);
			strcpy(temp2, tmp);
			strcat(temp2, "/");
			strcat(temp2, temp);
			chdir(temp2);
			strcpy(temp, PATHIS);
			strcat(temp, temp2);
			putenv(temp);
			}
		return 1; /* successful cd */
		}

	if (strcmp(arg, "pwd") == 0)
		{
		strcpy(temp, getenv("PWD"));
		strcat(temp, "\n");
		write(STDOUT_FILENO, temp, strlen(temp));
		return 1;
		}
}
