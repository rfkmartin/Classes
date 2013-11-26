#include "main.h"
#include "child.h"

static void childHandler(int signo)
{
	int status;

	wait(&status);
}
