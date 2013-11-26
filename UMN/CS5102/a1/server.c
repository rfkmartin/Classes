/************************************************************************/
/*                                                                      */
/* Name: Robert F.K. Martin                                             */
/* ID#:  1505151                                                        */
/* Class: Csci 5102                                                     */
/*                                                                      */
/* Assignment #1                                                        */
/*                                                                      */
/************************************************************************/

#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/wait.h>
#include <signal.h>
#include <string.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>

int get_file_size(char *filename);
int create_socket(u_short *port);
int accept_connection(int sd);
void webServe(int new_sockServ);
void fireman(int sigerror);
int dataRead(int srvSock, char *buf, int n_byte);
int dataWrite(int srvSock, char *buf, int n_byte);


main()
{
int srvSock,new_srvSock;
u_short portNum;


if ((srvSock = create_socket(&portNum)) < 0)
{
   perror("create_socket");
   exit(1);
}

signal(SIGCHLD, fireman);

while(1)
{
   if ((new_srvSock = accept_connection(srvSock)) < 0)
   {
      if (errno == EINTR)
	 continue;
      perror("accept_connection");
      exit(1);
   }

   switch(fork())
   {
      case -1:
	 perror("fork");
	 close(srvSock);
	 close(new_srvSock);
	 exit(1);

      case 0:
	 close(srvSock);
	 webServe(new_srvSock);
	 exit(0);

      default:
	 close(new_srvSock);
	 continue;
   }
}


}

int get_file_size(char *filename)
{
/************************************************************************/
/* Created by Bruce Hartung						*/
/* function: get_file_size(char *filename);				*/
/* This function takes a string, which is the name of a file, and 	*/
/* returns the length in bytes (the number of characters) in the file	*/
/* If the file does not exist, or of there is some other problem	*/
/* accessing the file, -1 is returned.					*/
/************************************************************************/
 
   int size;			/* The size of the file in bytes	*/
   struct stat file_stats;	/* A structure to hold file info	*/

   if (stat(filename, &file_stats)<0)/*grab file info* and handle errors*/
   {
	perror("get_file_size");    
        return(-1);
   }

   size = (int)file_stats.st_size;	/* cast the size to an int	*/
   return size;				/* return the size of the file	*/
}

int create_socket(u_short *in_port)
{
/************************************************************************/
/* Modified by Bruce Hartung						*/
/* function: int create_socket(u_short *in_port)			*/	
/* This function handles most of the mess of creating a socket.		*/
/* It returns an integer socket descriptor which is similar to a file	*/
/* descriptor in that it may be written to and read from.  The only	*/
/* parameter is a pointer to a port number.  It is unimportant what 	*/
/* value is sent, but upon return, the contents will be modified to be	*/ 
/* the port number on which the socket will listen for connections.	*/
/* You should output this value to stdout so that you will know which	*/
/* port to enter in the URL address of the browser.			*/
/************************************************************************/
 
    struct sockaddr_in servaddr;
    u_short port;
    int sd;			/* The socket descriptor		*/

    /* figure out the name of our host */
    char myhost[128];
    gethostname(myhost, sizeof(myhost));

    /* open a tcp socket */
    sd = socket(AF_INET, SOCK_STREAM, 0);
    if (sd < 0)
    {
        perror("socket");
        exit(1);
    }

    /* bind the socket to our address */
    bzero((char *) &servaddr, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr = htonl(INADDR_ANY);

    /* look for an unused port */
    port = IPPORT_RESERVED;
    servaddr.sin_port = htons(port);
    while (bind(sd, (struct sockaddr *) &servaddr, sizeof(servaddr)) < 0)
    {
        port++;
        servaddr.sin_port = htons(port);
    }

    /* write the port number to stdout */
    printf("Use port number %d\n", (int)port);


    /* listen for connections on the socket */
    listen(sd, 5);
     
     puts("about to return from create_socket");
     return sd;
}

int accept_connection(int sd)
{
/************************************************************************/
/* modified and documented by Bruce Hartung
/* function : int accept_connection(int sd);                            */
/* This function will accept the connection from a client process (for  */
/* example, a web browser).  It may only be used after a socket has been*/
/* created.  The parameter is a socket descriptor (very similar to a    */
/* file descriptor) such as is returned by create_socket.  The return   */
/* value is another socket descriptor, which you may write into.        */
/* NOTE: You may call accept_connection many times for each one time you*/
/* call create_socket!  For this asssignment, you need only call        */
/* create_socket once, but you may connect to it many times, by repeated*/
/* calls to accept_socket.  You should close() the new socket descriptor*/
/* in the parent process, as the parent will not be writing to it.	*/
/************************************************************************/

   struct sockaddr_in cliaddr;  /*clients address                       */
   int clilen,new_sd;           /* cliaddr size and the new socket desc */

   clilen = sizeof(cliaddr);    /* get the size off the clients address */
   /* accept a connection on the socket, and store the new socket descr */
   new_sd = accept(sd, (struct sockaddr *) &cliaddr, &clilen);

   return new_sd;               /* return the new socket descriptor     */
}

/***************************************************
*
* function: void webServe(int srvSock)
*
* This is the function that handles
* valid connections to a Web browser.
*
***************************************************/
void webServe(int srvSock)
{
   char buffer[80];
   char send_buf[80];
   char fileName[80];
   int fileSize;
   int n = 0;
   FILE *fp;

   while(dataRead(srvSock, buffer, 80) > 0)
   {

   printf("%s", buffer);

/**************************************
*  parse input to get requested filename
**************************************/
   if (strncmp("GET", buffer, 3) == 0)
   {
      while(buffer[n + 5] != ' ')
      {
	 fileName[n] = buffer[n + 5];
	 n++;
      } 

      fileName[n] = NULL; /*Terminate string */
   }

   }

   if ((fp = fopen(fileName, "r")) != NULL)
      { /* If file exists, send headers and contents of file */
      fileSize = get_file_size(fileName);

      strcpy(send_buf, "HTTP/1.0 200 OK\n");
      dataWrite(srvSock, send_buf, strlen(send_buf));
      strcpy(send_buf, "Server: cs5102-server/0.1\n");
      dataWrite(srvSock, send_buf, strlen(send_buf));
      sprintf(send_buf, "Content-length: %d\n", fileSize);
      dataWrite(srvSock, send_buf, strlen(send_buf));
      strcpy(send_buf, "Content-type: text/html\n");
      dataWrite(srvSock, send_buf, strlen(send_buf));
      strcpy(send_buf, "Connection: keep-alive\n\n");
      dataWrite(srvSock, send_buf, strlen(send_buf));

      while (fgets(send_buf, 80, fp) != 0)
         dataWrite(srvSock, send_buf, strlen(send_buf));

      }
   else /* send headers and contents of errorFile.html */
      {
      fileSize = get_file_size("errorFile.html");
      fp = fopen("errorFile.html", "r");

      strcpy(send_buf, "HTTP/1.0 404 Not Found\n");
      dataWrite(srvSock, send_buf, strlen(send_buf));
      strcpy(send_buf, "Server: cs5102-server/0.1\n");
      dataWrite(srvSock, send_buf, strlen(send_buf));
      sprintf(send_buf, "Content-length: %d\n", fileSize);
      dataWrite(srvSock, send_buf, strlen(send_buf));
      strcpy(send_buf, "Content-type: text/html\n");
      dataWrite(srvSock, send_buf, strlen(send_buf));
      strcpy(send_buf, "Connection: keep-alive\n\n");
      dataWrite(srvSock, send_buf, strlen(send_buf));

      while (fgets(send_buf, 80, fp) != 0)
         dataWrite(srvSock, send_buf, strlen(send_buf));
      }

}

/***************************************************
*
* function: void fireman(int signo)
* 
* This catches dying child processes
* so we can avoid zombies.
*
***************************************************/

void fireman(int signo)
{
   wait(NULL);
}

/***************************************************
*
* function: int dataRead(int srvSock, char *buf, int n_byte)
* 
* This reads data coming in off the socket.
*
***************************************************/
int dataRead(int srvSock, char *buf, int n_byte)
{
   int r_byte = 0; /*bytes read */
   int c_byte = 0; /*bytes counted */

   while(c_byte < n_byte)
   {
   r_byte = read(srvSock, buf, n_byte);
   if(r_byte > 0)
      {
      c_byte += r_byte;
      buf += r_byte;
      }
   
   if (r_byte < 0 || r_byte < n_byte)
      return(-1);
   }
   return(c_byte);
}


/***************************************************
*
* function: int dataWrite(int srvSock, char *buf, int n_byte)
* 
* This writes data to the socket.
*
***************************************************/
int dataWrite(int srvSock, char *buf, int n_byte)
{
   int w_byte = 0; /*bytes written */
   int c_byte = 0; /*bytes counted */

   while(c_byte < n_byte)
   {
   w_byte = write(srvSock, buf, n_byte);
   if (w_byte > 0)
      {
      c_byte += w_byte;
      buf += w_byte;
      }
   else
      return(-1);
   }
   return(c_byte);
}
