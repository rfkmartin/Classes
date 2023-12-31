/* implement a simple  grid world domain */

#include "grid-world.h"

/* deterministic grid world transition */

STATE next_state(STATE olds, ACTION action)
{
  STATE news;

  switch (action) {
  case WEST: 
    if (olds.col == 0)
      return (olds);
    else { news.col = olds.col-1;
	   news.row = olds.row;
	   return(news);}
    break;
  case EAST:
    if (olds.col == SIZE-1)
      return (olds);
    else { news.col = olds.col+1;
	   news.row = olds.row;
	   return(news);}
    break;
  case NORTH:
    if (olds.row == 0)
      return (olds);
    else { news.col = olds.col;
	   news.row = olds.row-1;
	   return(news);}
    break;
  case SOUTH:
    if (olds.row == SIZE-1)
      return (olds);
    else { news.col = olds.col;
	   news.row = olds.row+1;
	   return(news);}
    break;
  };
};

/* at goal? */

int at_goal(STATE state, STATE goal)
{
  return(state.row == goal.row && state.col == goal.col);
}


/* reward function */

double get_reward(STATE news, STATE goal)
{
  if (at_goal(news,goal))  /* reward transition into goal state */
    return (GOAL_REWARD);
  else return(PENALTY);
}


