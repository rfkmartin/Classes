
#ifndef _decl_r_h_
#define _decl_r_h_

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include "grid-world.h"
#include "display.h"
#include "krandom.h"

#define ITERATIONS 10000000

#define GRAPHICS 1

#define TRIALS 1

#define STEP_SIZE 2000

#define  BETA_BASE 0.1

#define ALPHA_BASE 0.01

#ifndef RAND_MAX
#define RAND_MAX 2147483000
#endif

#define MBIG 1000000000
#define MSEED 161803398
#define MZ 0
#define FAC (1.0/ MBIG)

#define GAMMA 0.99

double qvalues[SIZE][SIZE][NUM_ACTIONS];

double trial_data[TRIALS][ITERATIONS/STEP_SIZE]; 

void init_qvalues();

void init_state_action_recencies();

double best_qvalue(STATE state);

ACTION best_qvalue_action(STATE state);

void display_state_statistics(STATE s);

void update_qvalues(STATE olds,STATE news,ACTION action,double reward);

void update_qvalues(STATE olds,STATE news,ACTION action,double reward); 

ACTION choose_best_action(STATE state,int step);

ACTION recency_choose_best_action(STATE state,int step);

void run_trials();

void record_data(int j, int trial,double cum_reward);

void write_trial_data();

char *action_name(ACTION bestact);

void print_policy();

#endif 
