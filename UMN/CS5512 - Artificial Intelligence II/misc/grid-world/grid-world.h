/* grid world domain dynamics */

#ifndef _grid_h_
#define _grid_h_

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#define SIZE 20

#define GOAL_REWARD 10.0
#define PENALTY -1.0

#ifndef RAND_MAX
#define RAND_MAX 2147483000
#endif

#define NUM_ACTIONS 4

typedef struct {int row; int col;} STATE;

typedef enum  {NORTH=0,EAST,SOUTH,WEST} ACTION;

STATE next_state(STATE olds, ACTION action);

double get_reward(STATE news, STATE goal);

#endif 
