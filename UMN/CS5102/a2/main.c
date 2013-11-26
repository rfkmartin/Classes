#include "main.h"

static void childHandler(int);

char actualPath[MAXCMDLEN];

static void childHandler(int signo)
{
        int status;

        wait(&status);
}


int main(int argc, char *argv[])
{
	char lineInput[MAXLNLEN];
	char tmplineInput[MAXLNLEN];
	char *commandLine[MAXCMDLEN];
	char Argv[MAXARGS][MAXCMDLEN];
	char *argv[MAXCMDLEN];
	char temp[MAXCMDLEN];
	char file[MAXCMDLEN];
	char *ptr;
	int Argc;
	int commandCounter = 0;
	int numCmd; /* Number of commands in command line */
	int cmdcnt;
	int tmpCmd;
	int pidBack[MAXARGS];
	int cmdBack[MAXARGS];
	int cntBack;
	int isBackground;
	int inputIsRedirected;
	int outputIsRedirected;
	int errorIsRedirected;
	int appendYes;
	int fd[2];
	int tempfd[2];
	int pid;
	int inputFileDes;
	int outputFileDes;
	int i;
	int j = 0;

	struct sigaction act, oact;

	act.sa_handler = childHandler;
	sigemptyset(&act.sa_mask);
	act.sa_flags = 0;
	sigaction(SIGCHLD, &act, &oact);

	while (1)
	{
		/* Reset all variables for each command line */
		i = 0;
		tmpCmd = 0;
		isBackground = FALSE;
		cntBack = 0;
		numCmd = 1; /*There is always at least one command on the line */

		displayPrompt(commandCounter++);
		gets(lineInput);
		strcpy(tmplineInput, lineInput);

		/* parse command line by whitespace into array */
		commandLine[i++] = strtok(tmplineInput, WHITE);
		while ((ptr = strtok(NULL, WHITE)) != NULL)
			commandLine[i++] = ptr;
		commandLine[i] = NULL;
		cmdcnt = i;


		/* Check for background process */
		if (strcmp(commandLine[cmdcnt - 1], BACKG) == 0)
			{
			isBackground = TRUE;
			cmdcnt--;
			}

		printf("cc=%d\n",cmdcnt);

		/* Make commands and argument lists */
		for (j = 0; j<cmdcnt; j++)
		{
			strcpy(Argv[tmpCmd++], commandLine[j++]);
			printf("j = %d Argv=%s\n", j, Argv[tmpCmd - 1]);

			if (j == cmdcnt) /* end of commands? */
				break;

			if ((strcmp(commandLine[j], PIPE) == 0) || (strcmp(commandLine[j], PIPE_ERR) == 0))
				{
				if ((tmpCmd % 2) != 0) tmpCmd++;
				strcpy(Argv[tmpCmd - 1], "");
				continue; /* skip if next command is PIPE */
				}

			while((strcmp(commandLine[j], PIPE) != 0) && (strcmp(commandLine[j], PIPE_ERR) != 0))
			{
				strcat(temp, commandLine[j++]);
				strcat(temp, " ");
				if (j == cmdcnt) break; /* end of commands? */
			}
			strcpy(Argv[tmpCmd], temp);
			strcpy(temp, "\0");
			tmpCmd++;
		}

		if ((tmpCmd %2) != 0)
			{
			tmpCmd++;
			strcpy(Argv[tmpCmd - 1], "");
			}

		//printf("In between\n");

		for (j = 0; j < tmpCmd; j += 2)
		{
			inputIsRedirected = FALSE;
			outputIsRedirected = FALSE;
			errorIsRedirected = FALSE;
			appendYes = FALSE;

			if (j > 0)
				{
				tempfd[0] = fd[0];
				tempfd[1] = fd[1];
				close(fd[1]);
				}

			if (tmpCmd - j > 3)
				pipe(fd); /* create pipe  */
			else if ((tmpCmd > 2) && (tmpCmd - j > 3))
				close(tempfd[1]);

			//printf("Argv[%d]=%s\nArgv[%d]=%s\n", j, Argv[j], j + 1, Argv[j + 1]);

			if (isPipeIn(Argv[j], commandLine, PIPE_ERR, cmdcnt))
				{
				inputIsRedirected = TRUE;
				inputFileDes = tempfd[0];
				//printf("input %d\n", inputFileDes);
				}

			if (isPipeOut(Argv[j], commandLine, PIPE_ERR, cmdcnt))
				{
				outputIsRedirected = TRUE;
				errorIsRedirected = TRUE;
				outputFileDes = fd[1];
				//printf("output %d\n", outputFileDes);
				}

			if (isPipeIn(Argv[j], commandLine, PIPE, cmdcnt))
				{
				inputIsRedirected = TRUE;
				inputFileDes = tempfd[0];
				//printf("input %d\n", inputFileDes);
				}

			if (isPipeOut(Argv[j], commandLine, PIPE, cmdcnt))
				{
				outputIsRedirected = TRUE;
				outputFileDes = fd[1];
				//printf("output %d\n", outputFileDes);
				}

			if (Redirect(Argv[j + 1], REDIR_IN))
			{
				inputIsRedirected = TRUE;
				strcpy(file, getFileName(Argv[j + 1], REDIR_IN));
				inputFileDes = open(file, O_RDONLY | O_CREAT, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
				//printf("input %d\n", inputFileDes);
			}

			if (Redirect(Argv[j + 1], REDIR_ERR_APP))
				{
                outputIsRedirected = TRUE;
				errorIsRedirected = TRUE;
				appendYes = TRUE;
				strcpy(file, getFileName(Argv[j + 1], REDIR_ERR_APP));
				outputFileDes = open(file, O_WRONLY | O_APPEND, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
				//printf("output %d\n", outputFileDes);
			}

			if (Redirect(Argv[j + 1], REDIR_OUT_APP))
				{
				outputIsRedirected = TRUE;
				appendYes = TRUE;
				strcpy(file, getFileName(Argv[j + 1], REDIR_OUT_APP));
				outputFileDes = open(file, O_WRONLY | O_APPEND, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
				//printf("output %d\n", outputFileDes);
				}

			if (Redirect(Argv[j + 1], REDIR_ERR))
				{
                outputIsRedirected = TRUE;
				errorIsRedirected = TRUE;
				strcpy(file, getFileName(Argv[j + 1], REDIR_ERR));
				outputFileDes = open(file, O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
				//printf("output %d\n", outputFileDes);
				}

            if (Redirect(Argv[j + 1], REDIR_OUT))
				{
				outputIsRedirected = TRUE;
				strcpy(file, getFileName(Argv[j + 1], REDIR_OUT));
				outputFileDes = open(file, O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
				//printf("output %d\n", outputFileDes);
				}

			//printf("input %d output %d error %d append %d\n", inputIsRedirected, outputIsRedirected, errorIsRedirected, appendYes);
			//printf("Argv = %s file = %s\n", Argv[j + 1], file);

			if (isBuiltin(Argv[j]))
				{
				doBuiltin(Argv[j], Argv[j + 1]);
				break;
				}
			if (doesExist(Argv[j]))
				{
				pid = fork();
				if (pid == 0)
					{
					i = 0;

					if (isBackground)
						{ /*ignore interrupt and quit signals if background process */
						signal(SIGINT, SIG_IGN);
						signal(SIGQUIT, SIG_IGN);
						}

					//printf("in %d out %d\n", inputFileDes, outputFileDes);
					if (inputIsRedirected)
						{
						close(tempfd[1]);
						//printf("STDIN from %d\n", inputFileDes);
						//printf("STDOUT from %d\n", outputFileDes);
						dup2(inputFileDes, STDIN_FILENO);
						}
					else
						close(fd[0]);

					if (outputIsRedirected)
						{
						//printf("STDOUT to %d\n", outputFileDes);
						dup2(outputFileDes, STDOUT_FILENO);
						}
					else
						close(fd[1]);

					if (errorIsRedirected)
						{
						//printf("STDERR to %d\n", outputFileDes);
						dup2(outputFileDes, STDERR_FILENO);
						}

					argv[i++] = Argv[j];
					argv[i++] = strtok(Argv[j + 1], WHITE);
					while ((ptr = strtok(NULL, WHITE)) != NULL)
						argv[i++] = ptr;
					argv[i] = NULL;
					execve(actualPath, argv, environ); 

					exit(0);
					}
				if (!isBackground)
					; /*do nothing */
				else
					{
					printf("  [%d]  %d\n", commandCounter, getpid());
					pidBack[cntBack] = getpid();
					cmdBack[cntBack++] = commandCounter;
					}

		//printf("j %d tmpCmd %d\n", j, tmpCmd);
		if (tmpCmd - j < 2)
			{//printf("Closing\n");
			close(fd[1]);
			}
				}

		}

	}
}
