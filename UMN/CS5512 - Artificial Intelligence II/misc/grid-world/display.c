#include "display.h"

void init_win (int wd, int ht) /* Make window and allocate colors.     */
{
  jwin *w;
  char name[10];
  int i;

  printf("Creating window ...");   /* make some size of window */
  fflush(stdout);
  WINDOW = j_make_window(wd, ht, NULL, NULL, NULL, 1);

  printf("\nAllocating colors ..."); /* allocate gray values */
  fflush(stdout);
  for (i=0; i <= MAX_COLORS-1; i++)
    {
      sprintf(name, "gray%d", (MAX_COLORS - 1) - i);
      COLORS[i] = (int) find_color_val(name, WINDOW);
    } 
  printf("\n");

}

void draw_columns()
{
  int i,start_x,start_y,end_x,end_y;

  for (i=1; i<=SIZE-1; i++)
    {
      start_x = GRID_X + i*ROW_SIZE;
      start_y = GRID_Y;
      end_x = start_x;
      end_y = GRID_Y + GRID_SIZE;
      j_draw_line(start_x,start_y,end_x,end_y,COLORS[60],3,0,0,WINDOW);
    }
}

void draw_rows()
{
  int i,start_x,start_y,end_x,end_y;

  for (i=1; i<= SIZE-1; i++)
    {
      start_x = GRID_X;
      start_y = GRID_X + i*ROW_SIZE;
      end_x = start_x + GRID_SIZE;
      end_y = start_y;
      j_draw_line(start_x,start_y,end_x,end_y,COLORS[60],3,0,0,WINDOW);
    }
}

void draw_world() /* draw grid world */
{
  j_draw_rectangle(GRID_X,GRID_Y,GRID_X+GRID_SIZE,GRID_Y+GRID_SIZE,
		   COLORS[20],1,0,WINDOW); /* borders */
  draw_columns();
  draw_rows();
}

int state_x_location(STATE s)
{
  return(GRID_X + s.col*ROW_SIZE);
}

int state_y_location(STATE s)
{
  return(GRID_Y + s.row*ROW_SIZE);
}

void draw_goal(STATE g)
{
  int goal_x,goal_y;

  goal_x = state_x_location(g);
  goal_y = state_y_location(g);

  j_draw_rectangle(goal_x,goal_y,ROW_SIZE, ROW_SIZE,
		   COLORS[5],0,1,WINDOW); 
}

void draw_direction(ACTION a, STATE s)
{
  int start_x, start_y;

  start_x = state_x_location(s);
  start_y = state_y_location(s);

  switch (a) {
  case NORTH: 
    j_draw_line(start_x+5,start_y+25,start_x+15,start_y+5,COLORS[60],3,0,0,WINDOW);
    j_draw_line(start_x+15,start_y+5,start_x+25,start_y+25,COLORS[60],3,0,0,WINDOW);
    break;
  case EAST: 
    j_draw_line(start_x+5,start_y+5,start_x+25,start_y+15,COLORS[60],3,0,0,WINDOW);
    j_draw_line(start_x+5,start_y+25,start_x+25,start_y+15,COLORS[60],3,0,0,WINDOW);
    break;
  case WEST: 
    j_draw_line(start_x+25,start_y+5,start_x+5,start_y+15,COLORS[60],3,0,0,WINDOW);
    j_draw_line(start_x+25,start_y+25,start_x+5,start_y+15,COLORS[60],3,0,0,WINDOW);
    break;
  case SOUTH: 
    j_draw_line(start_x+5,start_y+5,start_x+15,start_y+25,COLORS[60],3,0,0,WINDOW);
    j_draw_line(start_x+25,start_y+5,start_x+15,start_y+25,COLORS[60],3,0,0,WINDOW);
    break;
  }
}

void display_policy(STATE g)
{

  XEvent event;
  int r,c,x,y;
  STATE s;
  ACTION a;

  for (r=0;r<SIZE; r++)
    for (c=0; c<SIZE; c++)
      {
	s.row = r;
	s.col = c;
	a = best_qvalue_action(s);
	if ((g.row != r) || (g.col !=c))
	  draw_direction(a,s);
      }
  while (1) {
    XNextEvent(WINDOW->disp,&event);    
    switch (event.type) {
    case ButtonPress: 
      x = event.xbutton.x; 
      y = event.xbutton.y;  
      s.row = convert_xloc_to_row(y);
      s.col = convert_xloc_to_row(x);
      display_state_statistics(s); 
      break;
    }    
  }
} 

int convert_xloc_to_row(int y)
{
  int rs;
  rs = ROW_SIZE;
  return(y/rs);
}

int convert_yloc_to_col(int x)
{
  int rs;
  rs = ROW_SIZE;
  return(x/rs);
}
  

STATE get_goal_from_user()
{
  XEvent event;
  int x,y,done=0;
  STATE goal;

  printf("click on square to indicate goal\n");
  while (!done) {
    XNextEvent(WINDOW->disp,&event);    
    switch (event.type) {
    case ButtonPress: done=1; x= event.xbutton.x; y = event.xbutton.y; break;
    }
  }
/*  printf("clicked on x: %d y: %d\n", x, y); */
  goal.row = convert_xloc_to_row(y);
  goal.col = convert_yloc_to_col(x);
  printf("goal row: %d col: %d\n", goal.row, goal.col);
  return(goal);
}
  
	
STATE start_display()
{

  XEvent event;
  STATE g;

  init_win(WINDOW_WIDTH,WINDOW_HEIGHT); /* pop up a window to draw world */

  draw_world();

  XFlush(WINDOW->disp);

  XSelectInput(WINDOW->disp,WINDOW->win,
	   ButtonPressMask|ButtonMotionMask|ButtonReleaseMask|ExposureMask);

  j_name_window(WINDOW, "Grid World");

  g = get_goal_from_user();

  draw_goal(g);

  return(g);
}



