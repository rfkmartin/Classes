#include "redirect.h"
#include "main.h"

int Redirect(char *cmdLine, char *token)
{
	if (strstr(cmdLine, token) == NULL) /* does token appear in cmdLine? */
		return 0;
	else
		return 1;
}

int isPipeIn(char *cmd, char *commLine[256], char *token, int cmdcnt)
{
	int i;
	char temp[MAXCMDLEN];

	for (i = 0; i < cmdcnt; i++)
	{
		strcpy(temp, commLine[i]);
		if (strcmp(cmd, temp) == 0) /*found command */
		{
			if (i == 0) return 0; /*Can't have pipe first */

			strcpy(temp, commLine[i - 1]);
			if (strcmp(temp, token) == 0)
				return 1;
			else
				return 0;
		}
	}
}

int isPipeOut(char *cmd, char *commLine[256], char *token, int cmdcnt)
{
	int i;
	char temp[MAXCMDLEN];

	for (i = 0; i < cmdcnt; i++)
	{
	strcpy(temp, commLine[i]);
	if (strcmp(cmd, temp) == 0) /*found command */
	{
		while (i < cmdcnt)
		{
		strcpy(temp, commLine[i]);
		if (strcmp(temp, token) == 0)
			return 1;
		i++;
		}
	}
	}
return 0;
}

char *getFileName(char *arg, char *token)
{
	char *temp;
	char *temptemp;

	temp = strtok(arg, token);
	temptemp = temp;

	if ((temp = strtok(NULL, token)) != NULL)
	{
		temp = strtok(temp, WHITE); /* get rid of leading whitespace */
		return temp;
	}
	else
	{
		temptemp = strtok(temptemp, WHITE);
		*arg = NULL; /* No arguments so Argv[j + 1] is 0 */
		return temptemp;
	}
}
