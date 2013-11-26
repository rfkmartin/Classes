/*****************************************************************
*                                                                *
*   CSci 5102 - Assignment 3                                     *
*                                                                *
*   Student: Robert Martin                                       *
*   ID#: 1505151                                                 *
*                                                                *
*****************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <dirent.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#include <time.h>

#define FALSE 0 
#define TRUE 1
#define MAXLEN 256

void printFileInfo(char *, int);

void main(int argc, char *argv[])
{
	int longFormOutput = FALSE;
	int numArgs;
	int i;
	char *tempDir;
	DIR *dp;
	struct dirent *dirp;

	if ((argc > 1) && ((argv[1][0] == '-') && (argv[1][1] != 'l')))
	{
		printf("usage: ls [-l] [files]\n");
		exit(0);
	} /* end if */

	if ((argc > 1) && (strcmp(argv[1], "-l") == 0))
	{
		longFormOutput = TRUE;
		numArgs = argc - 2;
	} /* end if */
	else
		numArgs = argc - 1;

	if (numArgs > 0)
	{
		for (i = 0; i < numArgs; i++)
			printFileInfo(argv[i + 1 + longFormOutput], longFormOutput);
	} /* end if */

	if (numArgs == 0)
	{
		tempDir = malloc(MAXLEN);
		getcwd(tempDir, MAXLEN);
		dp = opendir(tempDir);
		/*Ought to do some error checking */

		while ((dirp = readdir(dp)) != NULL)
			printFileInfo(dirp->d_name, longFormOutput);
	} /*end if */

} /* end main */

void printFileInfo(char *fileName, int longFormOutput)
{
	char *tempFile;
	static char *monthList[12] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
	char month[4];
	char timeField[11];
	static char filePerm[10];
	int day;
	int hour;
	int min;
	int year;
	int curHour;
	int curMin;
	int curYear;
	time_t curTimeV;
	struct stat fileInfo;
	struct tm *fileTime;
	struct tm *curTime;

	if ((strcmp(fileName, ".") == 0) || (strcmp(fileName, "..") == 0))
		return; /* skip current and parent directories */

	/* Check for absolute or relative pathnames */
	if (fileName[0] != '/')
	{
		/* Get full path name and check file existence */
		tempFile = malloc(MAXLEN);
		getcwd(tempFile, MAXLEN);
		strcat(tempFile, "/");
		strcat(tempFile, fileName);
	} /* end if */
	else
	{
		tempFile = malloc(MAXLEN);
		strcpy(tempFile, fileName);
	}

	if (access(tempFile, F_OK) < 0)
	{
		printf("%s: not found.\n", fileName);
		return;
	} /* end if */

	if (!longFormOutput)
	{
		printf("%s\n", fileName);
		return;
	} /* end if */
	else
	{
		strcpy(filePerm, "----------");
		lstat(tempFile, &fileInfo);
		time(&curTimeV); /* Get current time */

		/* get time values of file */
		fileTime = gmtime(&(fileInfo.st_ctime));
		year = fileTime->tm_year;
		day = fileTime->tm_mday;
		hour = fileTime->tm_hour;
		min = fileTime->tm_min;
		strcpy(month, monthList[fileTime->tm_mon]);

		curTime = gmtime(&curTimeV);
		curYear = curTime->tm_year;
		curHour = curTime->tm_hour;
		curMin = curTime->tm_min;

		/* If file is older than this year, print year only */
		if ((curYear - year) > 0)
			sprintf(timeField, " %d", 1900 + year); /* susceptible to Y2K problem */
		else /* otherwise print time */
			sprintf(timeField, "%02d:%02d", hour, min);

		/* get type of file */
		if (S_ISDIR(fileInfo.st_mode))
			filePerm[0] = 'd';
		else if (S_ISCHR(fileInfo.st_mode))
			filePerm[0] = 'c';
		else if (S_ISBLK(fileInfo.st_mode))
			filePerm[0] = 'b';
		else if (S_ISLNK(fileInfo.st_mode))
			filePerm[0] = 'l';
		else if (S_ISFIFO(fileInfo.st_mode))
			filePerm[0] = 'p';

		/* Set permissions */
		if (((fileInfo.st_mode)&S_IRUSR) == 00400)
			filePerm[1] = 'r';
		if (((fileInfo.st_mode)&S_IWUSR) == 00200)
			filePerm[2] = 'w';
		if (((fileInfo.st_mode)&S_IXUSR) == 00100)
			filePerm[3] = 'x';
		if (((fileInfo.st_mode)&S_IRGRP) == 00040)
			filePerm[4] = 'r';
		if (((fileInfo.st_mode)&S_IWGRP) == 00020)
			filePerm[5] = 'w';
		if (((fileInfo.st_mode)&S_IXGRP) == 00010)
			filePerm[6] = 'x';
		if (((fileInfo.st_mode)&S_IROTH) == 00004)
			filePerm[7] = 'r';
		if (((fileInfo.st_mode)&S_IWOTH) == 00002)
			filePerm[8] = 'w';
		if (((fileInfo.st_mode)&S_IXOTH) == 00001)
			filePerm[9] = 'x';

		printf("%s %3d %-8d %-8d %6d %s %2d %s GMT %s\n", filePerm, (int)fileInfo.st_nlink, (int)fileInfo.st_uid, (int)fileInfo.st_gid, (int)fileInfo.st_size, month, day , timeField, fileName);
	} /* end else */

} /* end printFileInfo */
