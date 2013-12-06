/* main file for Q/R learning technique */

#include "qlearner.h"

double beta = BETA_BASE; 

int seed;   /* for ran3 */

double freq_constant = (double) SIZE; 

int state_action_recency[SIZE][SIZE][NUM_ACTIONS];

double gain = 0.0;  /* average reward */

double EXPLORATION_THRESHOLD = 0.7; /* exploration level */

STATE goal;

void init_qvalues()
{
  int r,c,a;

  for (r=0;r<= (SIZE-1);r++)
    for (c=0;c<= (SIZE-1);c++)
      for (a=NORTH;a<=WEST;a++)
	qvalues[r][c][a] = 0.0;
}

void init_state_action_recencies()
{
  int r,c,a;

  for (r=0;r<= (SIZE-1);r++)
    for (c=0;c<= (SIZE-1);c++)
      for (a=NORTH;a<=WEST;a++)
	state_action_recency[r][c][a] = 0;
}

void display_state_statistics(STATE s)
{
  ACTION a;

  printf("Qvalues: ");
  for (a=NORTH;a<=WEST;a++)
    printf("%s: %4.2f ", action_name(a),qvalues[s.row][s.col][a]);
  printf("\n");

  /*for (a=NORTH;a<=WEST;a++)
    printf("%s: %d ", action_name(a),state_action_recency[s.row][s.col][a]);*/
  
  printf("\n");
  printf("\n");
}



double best_qvalue(STATE state)
{
	double best_val = -1000000.0;
	int a;

	for (a=NORTH;a<=WEST;a++)
	  {
	    if (qvalues[state.row][state.col][a] > best_val)
	      {
		best_val = qvalues[state.row][state.col][a];
	      }
	  }
	return (best_val);
}

ACTION best_qvalue_action(STATE state)
{
	double best_val = -100000.0;
	ACTION act,a;

	for (a=NORTH;a<=WEST;a++)
	  {
	    if (qvalues[state.row][state.col][a] > best_val)
	      {
		best_val = qvalues[state.row][state.col][a];
		act = a;
	      }
	  }
	return (act);
}
/* Q-learning */
void update_qvalues(STATE olds,STATE news,ACTION action,double r)
{
	double best_new_qval, qval;
	
	best_new_qval = best_qvalue(news);

	qval = qvalues[olds.row][olds.col][action];
	
	qvalues[olds.row][olds.col][action] = 
	    (1 - beta)*qval + beta*(r + GAMMA*best_new_qval);
	
}

 
/* simple epsilon-greedy exploration */ 
ACTION choose_best_action(STATE state,int step)
{
  double rvalue;
  double count,curr_val,best_val = -1000000.0;
   
  int a,act;

  rvalue = choose_random_value();

  if (rvalue > EXPLORATION_THRESHOLD)
    act = choose_random_int_value(NUM_ACTIONS);
  else 
    for (a=NORTH;a<=WEST;a++)
      {
	curr_val = qvalues[state.row][state.col][a];
	if (curr_val > best_val)
	  {
	    best_val = curr_val;
	    act = a;
	  }
      }
  return (act);
} 

void run_trials()
{ 
  double r,cum_reward;
  STATE olds, news;
  ACTION a;
  int ngoals,trial,j;

  int val, reached_goal=0;

  for (trial=0;trial<=(TRIALS-1);trial++)
    
    {
      
      printf("starting trial %d...\n", trial);

      olds.row = choose_random_int_value(SIZE-1); 
      olds.col = choose_random_int_value(SIZE-1) ;

      printf("from %d %d", olds.row, olds.col);
      
      gain = 0.0;
      cum_reward = 0.0;
      
      beta = BETA_BASE;
      
      init_state_action_recencies();

      init_qvalues(); 

      for (j=0;j<= (ITERATIONS-1);j++)
	{ 

	  a = choose_best_action(olds,j);

	  state_action_recency[olds.row][olds.col][a] = j;

	  news = next_state(olds,a);

	  r = get_reward(news,goal);

	  cum_reward = cum_reward + r;

	  update_qvalues(olds,news,a,r);  /* q-learning */
	
	  if ((j % STEP_SIZE) == 0)
	    record_data(j,trial,cum_reward);
	  
	  if (at_goal(news,goal))
	    {
	      reached_goal++;
	      olds.row = choose_random_int_value(SIZE-1); 
	      olds.col = choose_random_int_value(SIZE-1); 
	    }
	  else
	    {
	      olds.row = news.row;
	      olds.col = news.col;}
	}
      
    }
  
}




void record_data(int j, int trial,double cum_reward)
{
  /*   trial_data[trial][j/STEP_SIZE] = gain;*/
     trial_data[trial][j/STEP_SIZE] = cum_reward; 
}

void write_trial_data()
{

  FILE *run;
  int j, trial;
  char fname[20];
   
  for (trial=0; trial<TRIALS; trial++)
    {

      sprintf(fname, "cum-reward-%d", trial);
      run = fopen(fname, "w");

      for (j=0;j<= (ITERATIONS-1)/STEP_SIZE;j++)	
	fprintf(run,"%f\n", trial_data[trial][j]);
      fclose(run);
    }
}

char *action_name(ACTION bestact)
{
  char *c;
  
  switch(bestact) {
  case NORTH: c = "N";break;
  case SOUTH: c = "S";break;
  case EAST: c = "E";break;
  case WEST: c = "W";break;
  }
  return(c);
}

void print_policy()
{
  double val,best;
  int r,a,c,bestact;
  FILE *run;
  STATE s;
  
  run = fopen("policy-file", "w");
  
  for (r=0;r<= (SIZE-1);r++)
    {
      for (c=0;c<= (SIZE-1);c++)
	{

	  if ((goal.row == r) && (goal.col == c))
	    fprintf(run," G ");
	  else
	    {
	      s.row=r; 
	      s.col = c;
	      bestact = best_qvalue_action(s);
	      fprintf(run," %s ",action_name(bestact));
	    }
	}
      
      fprintf(run,"\n");
    }
  
  fclose(run);
}


void main()
{

  printf("enter large negative seed:");
  scanf("%d", &seed);

  goal = start_display();

  run_trials();

  write_trial_data();

  print_policy();

  if (GRAPHICS) display_policy(goal);

}      
		
		

		
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
