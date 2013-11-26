#include "main.h"
#include "display.h"

void displayPrompt(int cmdCnt)
{
	struct utsname uStruct;

	uname(&uStruct);
	printf("gosh %s [%d] :", uStruct.nodename, cmdCnt);

}
