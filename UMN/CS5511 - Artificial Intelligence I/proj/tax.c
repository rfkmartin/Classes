#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define TRUE 1
#define FALSE 0
#define BFSHVAL 1
#define DFSHVAL 1
#define ASTAR1CON 15
#define ASTAR2CON 4
#define SPECIES 8
#define TRAITS 3
#define CHAR 14
#define RANDER SPECIES * rand() / 32768;


struct Species {
	char trait[TRAITS];
	char name[5];
};

struct tState {
	struct Species	*spec[SPECIES];
	int				hval;
	int				level;
};

struct openList {
	struct openList *prev;
	struct tState  *node;
	struct openList *next;
};

/* Global Variables */
struct tState *tSglob;


/* Funtion prototypes */
int goalCheck(struct tState *);
int Astar1(struct tState *);
int Astar2(struct tState *);
int tUnion(struct Species *, struct Species *);
int tUnion4(struct Species *, struct Species *, struct Species *, struct Species *);
int tDelta(struct Species *, struct Species *);
int tDelta4(struct Species *, struct Species *, struct Species *, struct Species *);
struct tState *randomState();
void printNode(struct tState *);
void Initialize(struct openList *);
int IsEmpty(struct openList *);
struct openList *Put(struct tState *, struct openList *);
struct openList *Get(struct openList *);
int StackIsEmpty(struct openList *);
struct openList *Push(struct tState *, struct openList *);
struct openList *Pop(struct openList *);

/* Main Function */
void main()
{
	int i;
	unsigned int tm;
	struct openList *head;
	struct openList *next, *prev;
	struct tState *tS;
	struct Species *sp1, *sp2, *sp3, *sp4, *sp5, *sp6, *sp7, *sp8;
	
	sp1 = (struct Species *) malloc(sizeof(struct Species));
	sp2 = (struct Species *) malloc(sizeof(struct Species));
	sp3 = (struct Species *) malloc(sizeof(struct Species));
	sp4 = (struct Species *) malloc(sizeof(struct Species));
	sp5 = (struct Species *) malloc(sizeof(struct Species));
	sp6 = (struct Species *) malloc(sizeof(struct Species));
	sp7 = (struct Species *) malloc(sizeof(struct Species));
	sp8 = (struct Species *) malloc(sizeof(struct Species));
	tS = (struct tState *) malloc(sizeof(struct tState));
	tSglob = (struct tState *) malloc(sizeof(struct tState));
	head = (struct openList *) malloc(sizeof(struct openList));

	/* Seed Random Number Generator with system clock */
	srand((int) time(NULL));

	/* Filling a list using the Queue structure */
	Initialize(head);
	next = head->next;
	
	for (i = 0; i < 1000; i++)
		{
		tS = randomState();

		if (goalCheck(tS))
			{
			next = Put(tS, next);
    		printf("Astar2 = %d\n", Astar2(tS));
    		printf("Astar1 = %d\n", Astar1(tS));
			}
	}
	
	while (!IsEmpty(head))
		{
		head = Get(head);
		
		/* Can't figure out way other than global variable
		*  to pass back a new head ptr and the tState
		*  struct.
		*/
		printNode(tSglob);
		}

	/* Filling a list using the Stack structure */
	Initialize(head);
	next = head->next;
	
	for (i = 0; i < 1000; i++)
		{
		tS = randomState();

		if (goalCheck(tS))
			{
			next = Put(tS, next);
    		printf("Astar2 = %d\n", Astar2(tS));
    		printf("Astar1 = %d\n", Astar1(tS));
			}
	}
	
	while (!IsEmpty(head))
		{
		head = Get(head);
		
		/* Can't figure out way other than global variable
		*  to pass back a new head ptr and the tState
		*  struct.
		*/
		printNode(tSglob);
		}

	/* do breadth-first search */

	/* do depth-first search */

	/* do 1st heuristic seach */

	/* do 2nd heursitic search */

	/* report results */

	/* end of loop */
}

int goalCheck(struct tState *current)
{
	int delta12, delta34, delta56, delta13, delta15;

	delta12 = tDelta(current->spec[0], current->spec[1]);
	delta34 = tDelta(current->spec[2], current->spec[3]);
	delta13 = tDelta(current->spec[0], current->spec[2]);
	delta56 = tDelta(current->spec[4], current->spec[5]);
	delta15 = tDelta(current->spec[0], current->spec[4]);

	if ((delta12 == 2) && (delta34 == 2) && (delta56 == 2) && (delta13 == 4) &&
	(delta15 == 6))
		return 1;
	else
		return 0;
}

int Astar1(struct tState *current)
{
	int i, j, k;
	int traits;
	int total = 0, temp = 0;
	
	for (i = 0; i < SPECIES; i += 2)
		{
		total += tDelta(current->spec[i], current->spec[i + 1]);
		}

	return total + tUnion4(current->spec[0], current->spec[1],
	current->spec[2], current->spec[3]) - ASTAR1CON;
}


int Astar2(struct tState *current)
{
	return tDelta4(current->spec[0], current->spec[1],
	current->spec[2], current->spec[3]) - ASTAR2CON;
}


int tUnion(struct Species *sp1, struct Species *sp2)
{
	char traits[6];
	int traitcnt[6];
	int i,j;
	int traitnum = 0;
	int match;


	for (i = 0; i < TRAITS; i++)
		{
		traits[i] = sp1->trait[i];
		traitcnt[i] = 1;
		traitnum++;
		}

	for (i = 0; i < TRAITS; i++)
		{
		match = 0;
		for (j = 0; j < traitnum; j++)
			{
			if (sp2->trait[i] == traits[j])
				{
				traitcnt[j]++;
				match = 1;
				}
			}
		if (!match)
			{
			traits[traitnum] = sp2->trait[i];
			traitcnt[traitnum++]++;
			}
		}
		
	return traitnum;
}

int tUnion4(struct Species *sp1, struct Species *sp2, struct Species *sp3, struct
Species *sp4)
{
	char traits[12];
	int traitcnt[12];
	int i,j;
	int traitnum = 0;
	int match;


	for (i = 0; i < TRAITS; i++)
		{
		traits[i] = sp1->trait[i];
		traitcnt[i] = 1;
		traitnum++;
		}

	for (i = 0; i < TRAITS; i++)
		{
		match = 0;
		for (j = 0; j < traitnum; j++)
			{
			if (sp2->trait[i] == traits[j])
				{
				traitcnt[j]++;
				match = 1;
				}
			}
		if (!match)
			{
			traits[traitnum] = sp2->trait[i];
			traitcnt[traitnum++]++;
			}
		}

	for (i = 0; i < TRAITS; i++)
		{
		match = 0;
		for (j = 0; j < traitnum; j++)
			{
			if (sp3->trait[i] == traits[j])
				{
				traitcnt[j]++;
				match = 1;
				}
			}
		if (!match)
			{
			traits[traitnum] = sp3->trait[i];
			traitcnt[traitnum++]++;
			}
		}

	for (i = 0; i < TRAITS; i++)
		{
		match = 0;
		for (j = 0; j < traitnum; j++)
			{
			if (sp4->trait[i] == traits[j])
				{
				traitcnt[j]++;
				match = 1;
				}
			}
		if (!match)
			{
			traits[traitnum] = sp4->trait[i];
			traitcnt[traitnum++]++;
			}
		}
			
	return traitnum;
}


int tDelta(struct Species *sp1, struct Species *sp2)
{
	char traits[6];
	int traitcnt[6];
	int i,j;
	int traitnum = 0;
	int match;
	int unique = 0;


	for (i = 0; i < TRAITS; i++)
		{
		traits[i] = sp1->trait[i];
		traitcnt[i] = 1;
		traitnum++;
		}

	for (i = 0; i < TRAITS; i++)
		{
		match = 0;
		for (j = 0; j < traitnum; j++)
			{
			if (sp2->trait[i] == traits[j])
				{
				traitcnt[j]++;
				match = 1;
				}
			} /* end j loop */
		if (!match)
			{
			traits[traitnum] = sp2->trait[i];
			traitcnt[traitnum++] = 1;
			}
		}

	for (i = 0; i < traitnum; i++)
		{
		if (traitcnt[i] == 1)
			unique++;
		}
		
	return unique;
}


int tDelta4(struct Species *sp1, struct Species *sp2, struct Species *sp3, struct Species *sp4)
{
	char traits[12];
	int traitcnt[12];
	int i,j;
	int traitnum = 0;
	int match;
	int unique = 0;


	for (i = 0; i < TRAITS; i++)
		{
		traits[i] = sp1->trait[i];
		traitcnt[i] = 1;
		traitnum++;
		}

	for (i = 0; i < TRAITS; i++)
		{
		match = 0;
		for (j = 0; j < traitnum; j++)
			{
			if (sp2->trait[i] == traits[j])
				{
				traitcnt[j]++;
				match = 1;
				}
			}
		if (!match)
			{
			traits[traitnum] = sp2->trait[i];
			traitcnt[traitnum++] = 1;
			}
		}

	for (i = 0; i < TRAITS; i++)
		{
		match = 0;
		for (j = 0; j < traitnum; j++)
			{
			if (sp3->trait[i] == traits[j])
				{
				traitcnt[j]++;
				match = 1;
				}
			}
		if (!match)
			{
			traits[traitnum] = sp3->trait[i];
			traitcnt[traitnum++] = 1;
			}
		}

	for (i = 0; i < TRAITS; i++)
		{
		match = 0;
		for (j = 0; j < traitnum; j++)
			{
			if (sp4->trait[i] == traits[j])
				{
				traitcnt[j]++;
				match = 1;
				}
			}
		if (!match)
			{
			traits[traitnum] = sp4->trait[i];
			traitcnt[traitnum++] = 1;
			}
		}

	for (i = 0; i < traitnum; i++)
		{
		if (traitcnt[i] == 1)
			unique++;
		}

	return unique;
}


struct tState *randomState()
{
	int i, j, k, l, m, n, o, p;
	int start, startchar;
	char name[4];
	struct tState *current;

	current = (struct tState *) malloc(sizeof(struct tState));

	start = rand();
	for (i = 0; i < SPECIES; i++)
		{
		current->spec[i] = (struct Species *) malloc(sizeof(struct Species));
		sprintf(name, "sp%d", (start + i) % SPECIES);
		strcpy(current->spec[i]->name, name);
		}

	startchar = 'a' + (int) CHAR * rand() / 32768;

	i = (int) RANDER;
	j = (int) RANDER;
	while ( i == j)
		j = (int) RANDER;

	current->spec[i]->trait[0] = startchar;
	current->spec[i]->trait[2] = startchar + 1;
	current->spec[j]->trait[0] = startchar;
	current->spec[j]->trait[2] = startchar + 1;
	current->spec[i]->trait[1] = startchar + 2;
	current->spec[j]->trait[1] = startchar + 3;

	k = (int) RANDER;
	while ((k == i) || (k == j))
		k = (int) RANDER;

	l = (int) RANDER;
	while ((l == i) || (l == j) || (l == k))
		l = (int) RANDER;

    current->spec[k]->trait[0] = startchar;
    current->spec[k]->trait[2] = startchar + 4;
    current->spec[l]->trait[0] = startchar;
    current->spec[l]->trait[2] = startchar + 4;
    current->spec[k]->trait[1] = startchar + 5;
    current->spec[l]->trait[1] = startchar + 6;

    m = (int) RANDER;
    while ((m == i) || (m == j) || (m == k) || (m == l))
        m = (int) RANDER;

    n = (int) RANDER;
    while ((n == i) || (n == j) || (n == k) || (n == l) || (n == m))
        n = (int) RANDER;

    current->spec[m]->trait[0] = startchar + 7;
    current->spec[m]->trait[2] = startchar + 8;
    current->spec[n]->trait[0] = startchar + 7;
    current->spec[n]->trait[2] = startchar + 8;
    current->spec[m]->trait[1] = startchar + 9;
    current->spec[n]->trait[1] = startchar + 10;

    o = (int) RANDER;
    while ((o == i) || (o == j) || (o == k) || (o == l) || (o == m) || (o == n))
        o = (int) RANDER;

    p = (int) RANDER;
    while ((p == i) || (p == j) || (p == k) || (p == l) || (p == m) || (p ==n) || (p == o))
        p = (int) RANDER;

    current->spec[o]->trait[0] = startchar + 7;
    current->spec[o]->trait[2] = startchar + 11;
    current->spec[p]->trait[0] = startchar + 7;
    current->spec[p]->trait[2] = startchar + 11;
    current->spec[o]->trait[1] = startchar + 12;
    current->spec[p]->trait[1] = startchar + 13;

	return current;
}



void printNode(struct tState *current)
{
	int i, j;
	
	printf("Node order:\n");
	for (i = 0; i < SPECIES; i++)
		printf("%s ", current->spec[i]->name);

	printf("\n");
	
	printf("Species traits:\n");
	for (i = 0; i < SPECIES; i++)
		{
		printf("%s:", current->spec[i]->name);
		for (j = 0; j < TRAITS; j++)
			{
			printf(" %c", current->spec[i]->trait[j]);
			}
		printf("\n");
		}
}


void Initialize(struct openList *head)
{

	head->prev = NULL;
	head->node = NULL;
	head->next = head;

	return;
}


int IsEmpty(struct openList *oL)
{
	if (oL->next == NULL)
		return TRUE;
	else
		return FALSE;
}
   
   
struct openList *Put(struct tState *tS, struct openList *oL)
{
	if (oL->prev == NULL)
		{
		oL->node = tS;
		oL->next = (struct openList *) malloc(sizeof(struct openList));
		oL->next->next = NULL;
		}
	else
		{
		oL->next = (struct openList *) malloc(sizeof(struct openList));
		oL->prev = oL;
		oL->node = tS;
		oL->next->next = NULL;
		}
	return oL->next;
}


struct openList *Get(struct openList *oL)
{

	if (oL == NULL)
		{
		printf ( "Error!\n" );
		exit (1);
		}
	else
		{
		tSglob = oL->node;
		oL = oL->next;
		return oL;
		}
}


int StackIsEmpty(struct openList *oL)
{
	if (oL->prev == NULL)
		return TRUE;
	else
		return FALSE;
}
   
   
struct openList *Push(struct tState *tS, struct openList *oL)
{
	if (oL->prev == NULL)

   oL->next = (struct openList *) malloc(sizeof(struct openList));
   oL->prev = 
   
   Elt->E    = E;
   Elt->Next = Stack;
   
   Stack     = Elt;
}
   
   
struct tState *Pop(struct openList *S)
{
   struct tState *node;
 
   if ( S == NULL )
   {
      printf ( "Error!\n" );
      exit (1);
   }
   else
   {
       node   = Stack->node;
       Stack = Stack->next;
       return node;
   }
   
   return node;
}
*/
