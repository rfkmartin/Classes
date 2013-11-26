#include "main.h"
#include "search.h"

int doesExist(char *arg)
{

	char temp[MAXLNLEN];
	char temp2[MAXLNLEN];
	char *path[MAXCMDLEN];
	char *ptr;
	int i;
	int found = FALSE;
	int execute = FALSE;
	int pathCnt;

	strcpy(temp, getenv("PATH"));
	strcpy(temp2, arg);

	pathCnt = 0;

	if (temp2[0] != '/')
	{ /* does not specify absolute path */

	if (strtok(temp, PATHDEL) == NULL)
		return -1;
	path[pathCnt++] = temp;

	while ((ptr = strtok(NULL, PATHDEL)) != NULL)
		path[pathCnt++] = ptr;

	path[pathCnt++]= getenv("PWD");

	for (i = 0; i < pathCnt; i++)
		{
		strcpy(temp2, path[i]);
		strcat(temp2,"/");
		strcat(temp2, arg);
		if (access(temp2, F_OK) == 0)
			{
			found = TRUE;
			strcpy(actualPath, temp2);
			break;
			}
		}
	}
	else
	{
	if (access(temp2, F_OK) == 0)
		found = TRUE;
	}

	if (!found)
		{
		write(STDERR_FILENO, arg, strlen(arg));
		write(STDERR_FILENO, NOFINDERR, strlen(NOFINDERR));
		return 0;
		}

	if (access(temp2, X_OK) != 0)
		{
		write(STDERR_FILENO, arg, strlen(arg));
		write(STDERR_FILENO, NOEXECERR, strlen(NOEXECERR));
		return 0;
		}

	return 1;
}

