#ifndef _decl_display_h_
#define _decl_display_h_

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "graphics.h" /* include graphics header file */
#include "grid-world.h"


#define MAX_COLORS 100  /* lots of colors */

#define WINDOW_WIDTH 600
#define WINDOW_HEIGHT 600
#define GRID_X 0
#define GRID_Y 0
#define GRID_SIZE WINDOW_WIDTH
#define ROW_SIZE GRID_SIZE/SIZE
#define OFFSET ROW_SIZE/2

static jwin *WINDOW = NULL;/* define a global variable for the window */

static int COLORS[MAX_COLORS];/* define an array for storing colors */

void init_win(int wd, int ht);

void draw_columns();

void draw_rows();

void draw_world(); /* draw grid world */

int state_x_location(STATE s);

int state_y_location(STATE s);

void draw_goal(STATE g);

void draw_direction(ACTION a, STATE s);

void display_policy(STATE g);

void start_up_window();

int convert_xloc_to_row(int x);

int convert_yloc_to_col(int y);

STATE get_goal_from_user();

STATE start_display();

#endif
